# SuiteCard.jl — Suite.jl Card Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; SuiteCard(SuiteCardHeader(SuiteCardTitle("Title")), SuiteCardContent("..."))
# Usage via extract: include("components/Card.jl"); SuiteCard(...)
#
# Reference: shadcn/ui Card — https://ui.shadcn.com/docs/components/card

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteCard, SuiteCardHeader, SuiteCardTitle, SuiteCardDescription,
       SuiteCardContent, SuiteCardFooter

"""
    SuiteCard(children...; class, kwargs...) -> VNode

A container card with rounded corners, border, and shadow.
Equivalent to shadcn/ui's Card component.

# Examples
```julia
SuiteCard(
    SuiteCardHeader(
        SuiteCardTitle("Card Title"),
        SuiteCardDescription("Card description"),
    ),
    SuiteCardContent(P("Card body content")),
    SuiteCardFooter(SuiteButton("Save")),
)
```
"""
function SuiteCard(children...; class::String="", kwargs...)
    classes = cn("rounded-xl border border-warm-200 dark:border-warm-700 bg-warm-100 dark:bg-warm-900 text-warm-800 dark:text-warm-300 shadow-sm flex flex-col gap-6 py-6 text-sm overflow-hidden", class)
    Div(:class => classes, kwargs..., children...)
end

"""
    SuiteCardHeader(children...; class, kwargs...) -> VNode

Header section of a SuiteCard containing title and description.
"""
function SuiteCardHeader(children...; class::String="", kwargs...)
    classes = cn("flex flex-col gap-1.5 px-6", class)
    Div(:class => classes, kwargs..., children...)
end

"""
    SuiteCardTitle(children...; class, kwargs...) -> VNode

Title text inside a SuiteCardHeader.
"""
function SuiteCardTitle(children...; class::String="", kwargs...)
    classes = cn("text-lg font-semibold leading-none tracking-tight", class)
    Div(:class => classes, kwargs..., children...)
end

"""
    SuiteCardDescription(children...; class, kwargs...) -> VNode

Description text inside a SuiteCardHeader.
"""
function SuiteCardDescription(children...; class::String="", kwargs...)
    classes = cn("text-sm text-warm-600 dark:text-warm-500", class)
    Div(:class => classes, kwargs..., children...)
end

"""
    SuiteCardContent(children...; class, kwargs...) -> VNode

Main content area of a SuiteCard.
"""
function SuiteCardContent(children...; class::String="", kwargs...)
    classes = cn("px-6", class)
    Div(:class => classes, kwargs..., children...)
end

"""
    SuiteCardFooter(children...; class, kwargs...) -> VNode

Footer section of a SuiteCard, typically containing action buttons.
"""
function SuiteCardFooter(children...; class::String="", kwargs...)
    classes = cn("flex items-center px-6", class)
    Div(:class => classes, kwargs..., children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Card,
        "Card.jl",
        :styling,
        "Container card with header, content, and footer",
        Symbol[],
        Symbol[],
        [:SuiteCard, :SuiteCardHeader, :SuiteCardTitle, :SuiteCardDescription,
         :SuiteCardContent, :SuiteCardFooter],
    ))
end
