# Slider.jl — Suite.jl Slider Component
#
# Tier: js_runtime (requires suite.js for drag + keyboard interaction)
# Suite Dependencies: none (leaf component)
# JS Modules: Slider
#
# Usage via package: using Suite; Slider(default_value=50)
# Usage via extract: include("components/Slider.jl"); Slider(...)
#
# Behavior:
#   - Range slider with track, fill range, and draggable thumb
#   - JS discovers via data-suite-slider attribute
#   - Pointer capture API for drag interaction
#   - Keyboard: Arrow keys ±step, Home/End min/max, PageUp/Down ±10×step
#   - ARIA: role=slider on thumb with aria-valuenow/min/max/orientation
#   - Supports horizontal and vertical orientation
#   - Fires suite:slider:change custom event on value change
#
# Reference: shadcn/ui Slider — https://ui.shadcn.com/docs/components/slider
# Reference: Radix UI Slider — https://www.radix-ui.com/primitives/docs/components/slider
# Reference: WAI-ARIA Slider — https://www.w3.org/WAI/ARIA/apg/patterns/slider/

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Slider

"""
    Slider(; min, max, step, default_value, orientation, disabled, class, kwargs...) -> VNode

An input where the user selects a value from within a given range.

Requires `suite_script()` in your layout for JS behavior.

# Props
- `min`: Minimum value (default `0`)
- `max`: Maximum value (default `100`)
- `step`: Step increment (default `1`)
- `default_value`: Initial value (default `0`)
- `orientation`: `"horizontal"` or `"vertical"` (default `"horizontal"`)
- `disabled`: Disable the slider (default `false`)

# Examples
```julia
Slider()
Slider(default_value=50, min=0, max=100)
Slider(step=10, default_value=30)
Slider(orientation="vertical")
Slider(disabled=true, default_value=40)
```
"""
function Slider(; min::Real=0, max::Real=100, step::Real=1,
                  default_value::Real=0, orientation::String="horizontal",
                  disabled::Bool=false, theme::Symbol=:default,
                  class::String="", kwargs...)
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
        Symbol("data-suite-slider") => "",
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
        # Track
        Span(Symbol("data-suite-slider-track") => "",
             Symbol("data-orientation") => orientation,
             :class => track_classes,
            # Range (fill)
            Span(Symbol("data-suite-slider-range") => "",
                 Symbol("data-orientation") => orientation,
                 :class => range_classes,
                 :style => range_style),
        ),
        # Thumb
        Span(Symbol("data-suite-slider-thumb") => "",
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

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Slider,
        "Slider.jl",
        :js_runtime,
        "Range slider with drag and keyboard interaction",
        Symbol[],
        [:Slider],
        [:Slider],
    ))
end
