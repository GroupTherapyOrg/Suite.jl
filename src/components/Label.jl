# Label.jl — Suite.jl Label Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Label("Email", :for => "email")
# Usage via extract: include("components/Label.jl"); Label(...)
#
# Reference: shadcn/ui Label — https://ui.shadcn.com/docs/components/label

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Label

"""
    Label(children...; class, kwargs...) -> VNode

A styled form label.
Equivalent to shadcn/ui's Label component.

# Examples
```julia
Label("Email", :for => "email")
Label("Username")
```
"""
function Label(children...; class::String="", kwargs...)
    classes = cn(
        "flex items-center gap-2 text-sm leading-none font-medium select-none",
        "peer-disabled:cursor-not-allowed peer-disabled:opacity-50",
        class,
    )

    Therapy.Label(:class => classes, kwargs..., children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Label,
        "Label.jl",
        :styling,
        "Styled form label",
        Symbol[],
        Symbol[],
        [:Label],
    ))
end
