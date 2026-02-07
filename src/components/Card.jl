# Card.jl — Suite.jl Card Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Card(CardHeader(CardTitle("Title")), CardContent("..."))
# Usage via extract: include("components/Card.jl"); Card(...)
#
# Reference: shadcn/ui Card — https://ui.shadcn.com/docs/components/card

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Card, CardHeader, CardTitle, CardDescription,
       CardContent, CardFooter

"""
    Card(children...; class, kwargs...) -> VNode

A container card with rounded corners, border, and shadow.
Equivalent to shadcn/ui's Card component.

# Examples
```julia
Card(
    CardHeader(
        CardTitle("Card Title"),
        CardDescription("Card description"),
    ),
    CardContent(P("Card body content")),
    CardFooter(Button("Save")),
)
```
"""
function Card(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("rounded-xl border border-warm-200 dark:border-warm-700 bg-warm-100 dark:bg-warm-900 text-warm-800 dark:text-warm-300 shadow-sm flex flex-col gap-6 py-6 text-sm overflow-hidden", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    Div(:class => classes, kwargs..., children...)
end

"""
    CardHeader(children...; class, kwargs...) -> VNode

Header section of a Card containing title and description.
"""
function CardHeader(children...; class::String="", kwargs...)
    classes = cn("flex flex-col gap-1.5 px-6", class)
    Div(:class => classes, kwargs..., children...)
end

"""
    CardTitle(children...; class, kwargs...) -> VNode

Title text inside a CardHeader.
"""
function CardTitle(children...; class::String="", kwargs...)
    classes = cn("text-lg font-semibold leading-none tracking-tight", class)
    Div(:class => classes, kwargs..., children...)
end

"""
    CardDescription(children...; class, kwargs...) -> VNode

Description text inside a CardHeader.
"""
function CardDescription(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("text-sm text-warm-600 dark:text-warm-500", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    Div(:class => classes, kwargs..., children...)
end

"""
    CardContent(children...; class, kwargs...) -> VNode

Main content area of a Card.
"""
function CardContent(children...; class::String="", kwargs...)
    classes = cn("px-6", class)
    Div(:class => classes, kwargs..., children...)
end

"""
    CardFooter(children...; class, kwargs...) -> VNode

Footer section of a Card, typically containing action buttons.
"""
function CardFooter(children...; class::String="", kwargs...)
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
        [:Card, :CardHeader, :CardTitle, :CardDescription,
         :CardContent, :CardFooter],
    ))
end
