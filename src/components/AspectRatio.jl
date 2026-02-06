# SuiteAspectRatio.jl — Suite.jl AspectRatio Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; SuiteAspectRatio(ratio=16/9, Img(src="/photo.jpg"))
# Usage via extract: include("components/AspectRatio.jl"); SuiteAspectRatio(...)
#
# Reference: shadcn/ui AspectRatio — https://ui.shadcn.com/docs/components/aspect-ratio

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteAspectRatio

"""
    SuiteAspectRatio(children...; ratio, class, kwargs...) -> VNode

A container that maintains a fixed aspect ratio.
Equivalent to shadcn/ui's AspectRatio component.

# Examples
```julia
SuiteAspectRatio(ratio=16/9,
    Img(:src => "/photo.jpg", :alt => "Photo", :class => "size-full object-cover"),
)
SuiteAspectRatio(ratio=1/1,
    Div("Square content"),
)
```
"""
function SuiteAspectRatio(children...; ratio::Real=16/9, class::String="", kwargs...)
    classes = cn("relative overflow-hidden", class)
    style_val = "aspect-ratio: $(ratio);"

    Div(:class => classes, :style => style_val, kwargs..., children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :AspectRatio,
        "AspectRatio.jl",
        :styling,
        "Container that maintains a fixed aspect ratio",
        Symbol[],
        Symbol[],
        [:SuiteAspectRatio],
    ))
end
