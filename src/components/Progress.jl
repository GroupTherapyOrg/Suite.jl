# Progress.jl — Suite.jl Progress Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Progress(value=60)
# Usage via extract: include("components/Progress.jl"); Progress(...)
#
# Reference: shadcn/ui Progress — https://ui.shadcn.com/docs/components/progress

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Progress

"""
    Progress(; value, class, kwargs...) -> VNode

A horizontal progress bar.
Equivalent to shadcn/ui's Progress component.

# Props
- `value`: Number 0-100 indicating progress percentage (default 0)

# Examples
```julia
Progress(value=33)
Progress(value=75, class="w-[60%]")
```
"""
function Progress(; value::Real=0, class::String="", theme::Symbol=:default, kwargs...)
    clamped = clamp(value, 0, 100)
    transform_val = "translateX(-$(100 - clamped)%)"

    root_classes = cn(
        "relative h-2 w-full overflow-hidden rounded-full",
        "bg-accent-600/20 dark:bg-accent-600/30",
        class,
    )

    indicator_classes = "bg-accent-600 h-full w-full flex-1 transition-all"

    if theme !== :default
        t = get_theme(theme)
        root_classes = apply_theme(root_classes, t)
        indicator_classes = apply_theme(indicator_classes, t)
    end

    Div(
        :role => "progressbar",
        :aria_valuenow => string(Int(round(clamped))),
        :aria_valuemin => "0",
        :aria_valuemax => "100",
        :class => root_classes,
        kwargs...,
        Div(:class => indicator_classes, :style => "transform: $transform_val;"),
    )
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Progress,
        "Progress.jl",
        :styling,
        "Horizontal progress bar",
        Symbol[],
        Symbol[],
        [:Progress],
    ))
end
