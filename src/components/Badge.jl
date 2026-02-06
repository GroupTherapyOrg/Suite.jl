# SuiteBadge.jl — Suite.jl Badge Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; SuiteBadge("New")
# Usage via extract: include("components/Badge.jl"); SuiteBadge("New")
#
# Reference: shadcn/ui Badge — https://ui.shadcn.com/docs/components/badge

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteBadge

"""
    SuiteBadge(children...; variant, class, kwargs...) -> VNode

A small status indicator badge/pill.
Equivalent to shadcn/ui's Badge component.

# Variants
- `"default"`: Primary accent background (purple)
- `"secondary"`: Warm neutral background
- `"destructive"`: Red/danger tint
- `"outline"`: Bordered, transparent background

# Examples
```julia
SuiteBadge("New")
SuiteBadge(variant="destructive", "Error")
SuiteBadge(variant="outline", "v2.0")
```
"""
function SuiteBadge(children...; variant::String="default", class::String="", kwargs...)
    base = "inline-flex items-center justify-center w-fit whitespace-nowrap shrink-0 rounded-full border border-transparent px-2 py-0.5 text-xs font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600"

    variant_classes = Dict(
        "default"     => "bg-accent-600 text-white hover:bg-accent-700",
        "secondary"   => "bg-warm-100 dark:bg-warm-900 text-warm-800 dark:text-warm-300 hover:bg-warm-200 dark:hover:bg-warm-800",
        "destructive" => "bg-accent-secondary-600/10 dark:bg-accent-secondary-600/20 text-accent-secondary-600 dark:text-accent-secondary-400 hover:bg-accent-secondary-600/20",
        "outline"     => "border-warm-200 dark:border-warm-700 text-warm-800 dark:text-warm-300 hover:bg-warm-100 dark:hover:bg-warm-900",
    )

    vc = get(variant_classes, variant, variant_classes["default"])
    classes = cn(base, vc, class)

    Span(:class => classes, kwargs..., children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Badge,
        "Badge.jl",
        :styling,
        "Small status indicator badge/pill",
        Symbol[],
        Symbol[],
        [:SuiteBadge],
    ))
end
