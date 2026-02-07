# Skeleton.jl — Suite.jl Skeleton Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Skeleton(class="h-4 w-[250px]")
# Usage via extract: include("components/Skeleton.jl"); Skeleton(...)
#
# Reference: shadcn/ui Skeleton — https://ui.shadcn.com/docs/components/skeleton

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Skeleton

"""
    Skeleton(; class, kwargs...) -> VNode

A placeholder loading skeleton with pulse animation.
Equivalent to shadcn/ui's Skeleton component.

# Examples
```julia
Skeleton(class="h-4 w-[250px]")
Skeleton(class="h-12 w-12 rounded-full")
Skeleton(class="h-4 w-[200px]")
```
"""
function Skeleton(; class::String="", theme::Symbol=:default, kwargs...)
    # Note: shadcn's bg-accent is a muted bg color, NOT our accent purple.
    # Maps to warm-100/warm-900 (neutral loading placeholder bg)
    classes = cn("animate-pulse rounded-md bg-warm-200 dark:bg-warm-800", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    Div(:class => classes, kwargs...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Skeleton,
        "Skeleton.jl",
        :styling,
        "Placeholder loading skeleton with pulse animation",
        Symbol[],
        Symbol[],
        [:Skeleton],
    ))
end
