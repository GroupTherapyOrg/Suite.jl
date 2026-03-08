# Slider.jl — Suite.jl Slider Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Slider(default_value=50)
# Usage via extract: include("components/Slider.jl"); Slider(...)
#
# Behavior (Thaw-style inline Wasm):
#   - Range slider with track, fill range, and draggable thumb
#   - Inline Wasm: pointer capture for drag, keyboard for arrow/Home/End
#   - Pointer down: capture pointer, calculate position, update signal
#   - Pointer move: update signal from pointer position (while dragging)
#   - Pointer up: release pointer capture
#   - Keyboard: Arrow keys ±step, Home/End min/max
#   - ARIA: role=slider on thumb with aria-valuenow/min/max/orientation
#   - Supports horizontal and vertical orientation
#
# Architecture: Monolithic @island
#   - Single island handles 2 signals + 4 event handlers
#   - Signal 0: dragging (Int32, 0 or 1)
#   - Signal 1: value (Int32, percentage * 100, range 0-10000)
#   - Handler 0: on_pointerdown — capture pointer, compute value, set dragging=1
#   - Handler 1: on_pointermove — if dragging, recompute value
#   - Handler 2: on_pointerup — release pointer, set dragging=0
#   - Handler 3: on_keydown — arrows ±step, Home/End min/max
#
# Element IDs (deterministic from DOM structure):
#   0: therapy-island, 1: root Span, 2: track Span, 3: range Span, 4: thumb Span
#
# Reference: Thaw Slider — github.com/thaw-ui/thaw
# Reference: WAI-ARIA Slider — https://www.w3.org/WAI/ARIA/apg/patterns/slider/

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Slider

#   Slider(; min, max, step, default_value, orientation, disabled, class, kwargs...) -> IslandVNode
#
# An input where the user selects a value from within a given range.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# Inline Wasm behavior (Thaw-style):
#   - Pointer down on track: capture pointer, calculate value, update signal
#   - Pointer move (dragging): recalculate value from pointer position
#   - Pointer up: release pointer capture
#   - Keyboard: arrows ± step, Home = min, End = max
#
# Props:
# - `min`: Minimum value (default `0`)
# - `max`: Maximum value (default `100`)
# - `step`: Step increment (default `1`)
# - `default_value`: Initial value (default `0`)
# - `orientation`: `"horizontal"` or `"vertical"` (default `"horizontal"`)
# - `disabled`: Disable the slider (default `false`)
#
# Examples:
#   Slider()
#   Slider(default_value=50, min=0, max=100)
#   Slider(step=10, default_value=30)
#   Slider(orientation="vertical")
#   Slider(disabled=true, default_value=40)
@island function Slider(; min::Real=0, max::Real=100, step::Real=1,
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
        :on_pointerdown => () -> begin
            el = Int32(1)
            capture_pointer(el)
            set_dragging(Int32(1))
            track_el = Int32(2)
            rx = get_bounding_rect_x(track_el)
            rw = get_bounding_rect_w(track_el)
            px = get_pointer_x()
            raw_pct = (px - rx) * Float64(100) / rw
            if raw_pct < Float64(0)
                raw_pct = Float64(0)
            end
            if raw_pct > Float64(100)
                raw_pct = Float64(100)
            end
            set_style_percent(Int32(3), Int32(2), raw_pct)
            set_style_percent(Int32(4), Int32(0), raw_pct)
        end,
        # Handler 1: pointermove — if dragging, update position
        :on_pointermove => () -> begin
            if dragging() == Int32(1)
                track_el = Int32(2)
                rx = get_bounding_rect_x(track_el)
                rw = get_bounding_rect_w(track_el)
                px = get_pointer_x()
                raw_pct = (px - rx) * Float64(100) / rw
                if raw_pct < Float64(0)
                    raw_pct = Float64(0)
                end
                if raw_pct > Float64(100)
                    raw_pct = Float64(100)
                end
                set_style_percent(Int32(3), Int32(2), raw_pct)
                set_style_percent(Int32(4), Int32(0), raw_pct)
            end
        end,
        # Handler 2: pointerup — release pointer, stop dragging
        :on_pointerup => () -> begin
            el = Int32(1)
            release_pointer(el)
            set_dragging(Int32(0))
        end,
        # Handler 3: keydown — arrows ±step, Home/End
        :on_keydown => () -> begin
            key = get_key_code()
            s = compiled_get_prop_i32(Int32(0))  # _s = step as pct*100
            if s < Int32(1)
                s = Int32(100)  # default 1% step
            end
            current = value()
            new_val = current
            # ArrowRight (39) or ArrowUp (38) = increase
            if key == Int32(39)
                new_val = current + s
            end
            if key == Int32(38)
                new_val = current + s
            end
            # ArrowLeft (37) or ArrowDown (40) = decrease
            if key == Int32(37)
                new_val = current - s
            end
            if key == Int32(40)
                new_val = current - s
            end
            # Home (36) = min
            if key == Int32(36)
                new_val = Int32(0)
                prevent_default()
            end
            # End (35) = max
            if key == Int32(35)
                new_val = Int32(10000)
                prevent_default()
            end
            # Clamp
            if new_val < Int32(0)
                new_val = Int32(0)
            end
            if new_val > Int32(10000)
                new_val = Int32(10000)
            end
            if new_val != current
                set_value(new_val)
                pct_f = Float64(new_val) / Float64(100)
                set_style_percent(Int32(3), Int32(2), pct_f)
                set_style_percent(Int32(4), Int32(0), pct_f)
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
