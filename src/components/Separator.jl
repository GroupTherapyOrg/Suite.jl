# SuiteSeparator.jl — Suite.jl Separator Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; SuiteSeparator()
# Usage via extract: include("components/Separator.jl"); SuiteSeparator()
#
# Reference: shadcn/ui Separator — https://ui.shadcn.com/docs/components/separator

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteSeparator

"""
    SuiteSeparator(; orientation, decorative, class, kwargs...) -> VNode

A visual divider between content sections.
Equivalent to shadcn/ui's Separator component.

# Options
- `orientation`: `"horizontal"` (default) or `"vertical"`
- `decorative`: `true` (default) — if true, hidden from accessibility tree

# Examples
```julia
SuiteSeparator()
SuiteSeparator(orientation="vertical")
SuiteSeparator(decorative=false)
```
"""
function SuiteSeparator(; orientation::String="horizontal", decorative::Bool=true,
                         class::String="", kwargs...)
    orientation_classes = if orientation == "vertical"
        "h-full w-px"
    else
        "h-px w-full"
    end

    classes = cn("shrink-0 bg-warm-200 dark:bg-warm-700", orientation_classes, class)

    role_attrs = if decorative
        (:role => "none",)
    else
        (:role => "separator", :aria_orientation => orientation)
    end

    Div(:class => classes, role_attrs..., kwargs...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Separator,
        "Separator.jl",
        :styling,
        "Visual divider between content sections",
        Symbol[],
        Symbol[],
        [:SuiteSeparator],
    ))
end
