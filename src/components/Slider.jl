# Slider.jl — Suite.jl Slider Component
#
# Tier: island + widget (Wasm interactivity + @bind protocol)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage:
#   Slider(; min=0, max=100, default_value=50)   # Island mode → VNode
#   Slider(1:100)                                  # Widget mode → SliderWidget
#   Slider(1:100; default=50, show_value=true)     # Widget mode with options
#
# Island behavior (Thaw-style inline Wasm):
#   - Range slider with track, fill range, and draggable thumb
#   - Inline Wasm: pointer capture for drag, keyboard for arrow/Home/End
#   - ARIA: role=slider on thumb with aria-valuenow/min/max/orientation
#   - Supports horizontal and vertical orientation
#
# Widget behavior (@bind protocol):
#   - SliderWidget struct with index-mapped HTML rendering
#   - Bond protocol: initial_value, possible_values, transform_value, validate_value
#   - HTML <input type="range"> with inline JS for .value + input event
#
# Architecture: Monolithic @island (manual registration for multiple dispatch)
#   - Single island handles 2 signals + 4 event handlers
#   - Signal 0: dragging (Int32, 0 or 1)
#   - Signal 1: value (Int32, percentage * 100, range 0-10000)
#   - Handler 0: on_pointerdown — capture pointer, compute value, set dragging=1
#   - Handler 1: on_pointermove — if dragging, recompute value
#   - Handler 2: on_pointerup — release pointer, set dragging=0
#   - Handler 3: on_keydown — arrows ±step, Home/End min/max
#
# Element IDs (v2 hydration skips therapy-island wrapper):
#   0: root Span, 1: track Span, 2: range Span, 3: thumb Span
#
# Reference: Thaw Slider — github.com/thaw-ui/thaw
# Reference: WAI-ARIA Slider — https://www.w3.org/WAI/ARIA/apg/patterns/slider/

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Island Render Function (replaces @island macro expansion) ---

function _island_render_Slider(; min::Real=0, max::Real=100, step::Real=1,
                  default_value::Real=0, orientation::String="horizontal",
                  disabled::Bool=false, theme::Symbol=:default,
                  class::String="", kwargs...)
    # Signal 0: dragging state (0=not dragging, 1=dragging)
    dragging, set_dragging = create_signal(Int32(0))
    # Signal 1: value as percentage * 100 (0-10000 for 0%-100%)
    # Initial value from prop _v (alphabetically: _s=0, _v=1)
    value, set_value = create_signal(compiled_get_prop_i32(Int32(1)))

    # SSR-only: compute display percentage for inline styles
    clamped = clamp(default_value, min, max)
    pct = max > min ? (clamped - min) / (max - min) * 100 : 0

    is_vertical = orientation == "vertical"

    # Root classes
    root_classes = cn(
        "relative flex touch-none select-none items-center",
        is_vertical ? "h-full min-h-44 w-auto flex-col" : "w-full",
        disabled ? "opacity-50 pointer-events-none" : "",
        class,
    )

    # Track classes
    track_classes = cn(
        "relative grow overflow-hidden rounded-full bg-accent-600/20 dark:bg-accent-600/30",
        is_vertical ? "h-full w-1.5" : "h-1.5 w-full",
    )

    # Range (fill) classes + inline style for initial position
    range_classes = cn(
        "absolute bg-accent-600 rounded-full",
        is_vertical ? "w-full" : "h-full",
    )
    range_style = if is_vertical
        "bottom: 0; height: $(pct)%;"
    else
        "left: 0; width: $(pct)%;"
    end

    # Thumb classes
    thumb_classes = cn(
        "block size-4 shrink-0 rounded-full border border-accent-600 bg-warm-50 dark:bg-warm-950",
        "shadow-sm cursor-pointer transition-[color,box-shadow]",
        "hover:ring-4 hover:ring-accent-600/20",
        "focus-visible:ring-4 focus-visible:ring-accent-600/50 focus-visible:outline-hidden",
    )
    thumb_style = if is_vertical
        "position: absolute; left: 50%; bottom: $(pct)%; transform: translate(-50%, 50%);"
    else
        "position: absolute; top: 50%; left: $(pct)%; transform: translate(-50%, -50%);"
    end

    if theme !== :default
        t = get_theme(theme)
        root_classes = apply_theme(root_classes, t)
        track_classes = apply_theme(track_classes, t)
        range_classes = apply_theme(range_classes, t)
        thumb_classes = apply_theme(thumb_classes, t)
    end

    # Root data attributes
    root_attrs = Pair{Symbol,Any}[
        Symbol("data-slider") => "",
        Symbol("data-orientation") => orientation,
        Symbol("data-min") => string(min),
        Symbol("data-max") => string(max),
        Symbol("data-step") => string(step),
        Symbol("data-value") => string(clamped),
        :class => root_classes,
    ]
    if disabled
        push!(root_attrs, Symbol("data-disabled") => "")
        push!(root_attrs, :aria_disabled => "true")
    end

    Span(root_attrs..., kwargs...,
        # Handler 0: pointerdown — capture pointer, compute value from position
        # NOTE: All Float64 arithmetic — WasmTarget cannot compile Int32(Float64)
        # NOTE: No conditional reassignment — WasmTarget phi nodes are broken.
        # CSS naturally clips values outside 0-100% range.
        :on_pointerdown => () -> begin
            el = Int32(0)
            capture_pointer(el)
            set_dragging(Int32(1))
            track_el = Int32(1)
            rx = get_bounding_rect_x(track_el)
            rw = get_bounding_rect_w(track_el)
            px = get_pointer_x()
            pct = (px - rx) * Float64(100) / rw
            set_style_percent(Int32(2), Int32(2), pct)
            set_style_percent(Int32(3), Int32(0), pct)
        end,
        # Handler 1: pointermove — if dragging, update position
        :on_pointermove => () -> begin
            if dragging() == Int32(1)
                track_el = Int32(1)
                rx = get_bounding_rect_x(track_el)
                rw = get_bounding_rect_w(track_el)
                px = get_pointer_x()
                pct = (px - rx) * Float64(100) / rw
                set_style_percent(Int32(2), Int32(2), pct)
                set_style_percent(Int32(3), Int32(0), pct)
            end
        end,
        # Handler 2: pointerup — release pointer, stop dragging
        :on_pointerup => () -> begin
            el = Int32(0)
            release_pointer(el)
            set_dragging(Int32(0))
        end,
        # Handler 3: keydown — arrows ±1%
        # NOTE: Each key case is self-contained (no conditional reassignment)
        # because WasmTarget phi nodes are broken for if-block reassignment.
        :on_keydown => () -> begin
            key = get_key_code()
            cur = value()
            # ArrowRight (39) = +1%
            if key == Int32(39)
                nv1 = cur + Int32(100)
                set_value(nv1)
                p1 = Float64(nv1) / Float64(100)
                set_style_percent(Int32(2), Int32(2), p1)
                set_style_percent(Int32(3), Int32(0), p1)
            end
            # ArrowUp (38) = +1%
            if key == Int32(38)
                nv2 = cur + Int32(100)
                set_value(nv2)
                p2 = Float64(nv2) / Float64(100)
                set_style_percent(Int32(2), Int32(2), p2)
                set_style_percent(Int32(3), Int32(0), p2)
            end
            # ArrowLeft (37) = -1%
            if key == Int32(37)
                nv3 = cur - Int32(100)
                set_value(nv3)
                p3 = Float64(nv3) / Float64(100)
                set_style_percent(Int32(2), Int32(2), p3)
                set_style_percent(Int32(3), Int32(0), p3)
            end
            # ArrowDown (40) = -1%
            if key == Int32(40)
                nv4 = cur - Int32(100)
                set_value(nv4)
                p4 = Float64(nv4) / Float64(100)
                set_style_percent(Int32(2), Int32(2), p4)
                set_style_percent(Int32(3), Int32(0), p4)
            end
        end,
        # Track
        Span(Symbol("data-slider-track") => "",
             Symbol("data-orientation") => orientation,
             :class => track_classes,
            # Range (fill)
            Span(Symbol("data-slider-range") => "",
                 Symbol("data-orientation") => orientation,
                 :class => range_classes,
                 :style => range_style),
        ),
        # Thumb
        Span(Symbol("data-slider-thumb") => "",
             Symbol("data-orientation") => orientation,
             :role => "slider",
             :tabindex => disabled ? "-1" : "0",
             :aria_valuenow => string(clamped),
             :aria_valuemin => string(min),
             :aria_valuemax => string(max),
             :aria_orientation => orientation,
             :class => thumb_classes,
             :style => thumb_style),
    )
end

# --- Body expression for Wasm v2 compilation ---
# Captured as Expr (same as what @island QuoteNode(body) would produce)
const _SLIDER_BODY_EXPR = quote
    dragging, set_dragging = create_signal(Int32(0))
    value, set_value = create_signal(compiled_get_prop_i32(Int32(1)))
    clamped = clamp(default_value, min, max)
    pct = max > min ? (clamped - min) / (max - min) * 100 : 0
    is_vertical = orientation == "vertical"
    root_classes = cn("relative flex touch-none select-none items-center", is_vertical ? "h-full min-h-44 w-auto flex-col" : "w-full", disabled ? "opacity-50 pointer-events-none" : "", class)
    track_classes = cn("relative grow overflow-hidden rounded-full bg-accent-600/20 dark:bg-accent-600/30", is_vertical ? "h-full w-1.5" : "h-1.5 w-full")
    range_classes = cn("absolute bg-accent-600 rounded-full", is_vertical ? "w-full" : "h-full")
    range_style = if is_vertical; "bottom: 0; height: $(pct)%;"; else; "left: 0; width: $(pct)%;"; end
    thumb_classes = cn("block size-4 shrink-0 rounded-full border border-accent-600 bg-warm-50 dark:bg-warm-950", "shadow-sm cursor-pointer transition-[color,box-shadow]", "hover:ring-4 hover:ring-accent-600/20", "focus-visible:ring-4 focus-visible:ring-accent-600/50 focus-visible:outline-hidden")
    thumb_style = if is_vertical; "position: absolute; left: 50%; bottom: $(pct)%; transform: translate(-50%, 50%);"; else; "position: absolute; top: 50%; left: $(pct)%; transform: translate(-50%, -50%);"; end
    if theme !== :default; t = get_theme(theme); root_classes = apply_theme(root_classes, t); track_classes = apply_theme(track_classes, t); range_classes = apply_theme(range_classes, t); thumb_classes = apply_theme(thumb_classes, t); end
    root_attrs = Pair{Symbol,Any}[Symbol("data-slider") => "", Symbol("data-orientation") => orientation, Symbol("data-min") => string(min), Symbol("data-max") => string(max), Symbol("data-step") => string(step), Symbol("data-value") => string(clamped), :class => root_classes]
    if disabled; push!(root_attrs, Symbol("data-disabled") => ""); push!(root_attrs, :aria_disabled => "true"); end
    Span(root_attrs..., kwargs...,
        :on_pointerdown => () -> begin; el = Int32(0); capture_pointer(el); set_dragging(Int32(1)); track_el = Int32(1); rx = get_bounding_rect_x(track_el); rw = get_bounding_rect_w(track_el); px = get_pointer_x(); pct = (px - rx) * Float64(100) / rw; set_style_percent(Int32(2), Int32(2), pct); set_style_percent(Int32(3), Int32(0), pct); end,
        :on_pointermove => () -> begin; if dragging() == Int32(1); track_el = Int32(1); rx = get_bounding_rect_x(track_el); rw = get_bounding_rect_w(track_el); px = get_pointer_x(); pct = (px - rx) * Float64(100) / rw; set_style_percent(Int32(2), Int32(2), pct); set_style_percent(Int32(3), Int32(0), pct); end; end,
        :on_pointerup => () -> begin; el = Int32(0); release_pointer(el); set_dragging(Int32(0)); end,
        :on_keydown => () -> begin; key = get_key_code(); cur = value(); if key == Int32(39); nv1 = cur + Int32(100); set_value(nv1); p1 = Float64(nv1) / Float64(100); set_style_percent(Int32(2), Int32(2), p1); set_style_percent(Int32(3), Int32(0), p1); end; if key == Int32(38); nv2 = cur + Int32(100); set_value(nv2); p2 = Float64(nv2) / Float64(100); set_style_percent(Int32(2), Int32(2), p2); set_style_percent(Int32(3), Int32(0), p2); end; if key == Int32(37); nv3 = cur - Int32(100); set_value(nv3); p3 = Float64(nv3) / Float64(100); set_style_percent(Int32(2), Int32(2), p3); set_style_percent(Int32(3), Int32(0), p3); end; if key == Int32(40); nv4 = cur - Int32(100); set_value(nv4); p4 = Float64(nv4) / Float64(100); set_style_percent(Int32(2), Int32(2), p4); set_style_percent(Int32(3), Int32(0), p4); end; end,
        Span(Symbol("data-slider-track") => "", Symbol("data-orientation") => orientation, :class => track_classes,
            Span(Symbol("data-slider-range") => "", Symbol("data-orientation") => orientation, :class => range_classes, :style => range_style)),
        Span(Symbol("data-slider-thumb") => "", Symbol("data-orientation") => orientation, :role => "slider", :tabindex => disabled ? "-1" : "0", :aria_valuenow => string(clamped), :aria_valuemin => string(min), :aria_valuemax => string(max), :aria_orientation => orientation, :class => thumb_classes, :style => thumb_style))
end

# --- IslandDef registration (manual — replaces @island binding) ---

const _SLIDER_ISLAND_DEF = Therapy.IslandDef(:Slider, _island_render_Slider, false, _SLIDER_BODY_EXPR)
Therapy.ISLAND_REGISTRY[:Slider] = _SLIDER_ISLAND_DEF

# --- Slider: unified function with multiple dispatch ---

export Slider

"""
    Slider(; min=0, max=100, step=1, default_value=0, ...) -> IslandVNode

Island mode: renders an interactive Wasm-powered range slider.

    Slider(values::AbstractVector; default=missing, show_value=true, ...) -> SliderWidget

Widget mode: creates a SliderWidget struct for use with `@bind` in notebooks.
Same component, two dispatch modes via Julia's multiple dispatch.

# Examples
```julia
# Island mode (keyword-only → interactive Wasm slider)
Slider(; min=0, max=100, default_value=50)

# Widget mode (positional vector → @bind struct)
@bind x Slider(1:100)
@bind y Slider(0.0:0.01:1.0; default=0.5)
```
"""
function Slider(; kwargs...)
    _SLIDER_ISLAND_DEF(; kwargs...)
end

function Slider(values::AbstractVector{T};
        default=missing, show_value::Bool=true, label::String="",
        class::String="", theme::Symbol=:default,
        max_steps::Integer=1_000) where T
    vs = _downsample(collect(values), max_steps)
    d = default === missing ? first(vs) : _closest(vs, default)
    SliderWidget{T}(vs, d, show_value, label, class, theme)
end

# --- Hydration Support ---

const _SLIDER_PROPS_TRANSFORM = (props, args) -> begin
    min_val = get(props, :min, 0)
    max_val = get(props, :max, 100)
    step_val = get(props, :step, 1)
    range_val = max_val - min_val
    # Step as percentage * 100 (e.g., step=1 on 0-100 → 100)
    step_pct_100 = range_val > 0 ? round(Int, step_val / range_val * 10000) : 100
    props[:_s] = step_pct_100
    # Initial value as percentage * 100 (e.g., default_value=50 on 0-100 → 5000)
    default_val = get(props, :default_value, 0)
    clamped = clamp(default_val, min_val, max_val)
    val_pct_100 = range_val > 0 ? round(Int, (clamped - min_val) / range_val * 10000) : 0
    props[:_v] = val_pct_100
end


# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Slider,
        "Slider.jl",
        :island,
        "Range slider with drag and keyboard interaction",
        Symbol[],
        Symbol[],
        [:Slider],
    ))
end
