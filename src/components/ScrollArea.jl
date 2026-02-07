# ScrollArea.jl — Suite.jl ScrollArea Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; ScrollArea(class="h-[200px]", content...)
# Usage via extract: include("components/ScrollArea.jl"); ScrollArea(...)
#
# Reference: shadcn/ui ScrollArea — https://ui.shadcn.com/docs/components/scroll-area
# Note: Phase 1 = CSS-only overflow wrapper. Custom scrollbar JS deferred to Phase 3.

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export ScrollArea

"""
    ScrollArea(children...; class, kwargs...) -> VNode

A scrollable container area.
Phase 1 implementation uses CSS overflow. Custom scrollbar styling via JS deferred.

# Examples
```julia
ScrollArea(class="h-[200px] w-[350px] rounded-md border border-warm-200 p-4",
    P("Scrollable content here..."),
)
```
"""
function ScrollArea(children...; class::String="", kwargs...)
    classes = cn("relative overflow-auto", class)
    Div(:class => classes, kwargs..., children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :ScrollArea,
        "ScrollArea.jl",
        :styling,
        "Scrollable container (CSS overflow, custom scrollbar in Phase 3)",
        Symbol[],
        Symbol[],
        [:ScrollArea],
    ))
end
