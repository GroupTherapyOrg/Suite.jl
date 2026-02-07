# Breadcrumb.jl — Suite.jl Breadcrumb Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Breadcrumb(BreadcrumbList(...))
# Usage via extract: include("components/Breadcrumb.jl"); Breadcrumb(...)
#
# Reference: shadcn/ui Breadcrumb — https://ui.shadcn.com/docs/components/breadcrumb

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Breadcrumb, BreadcrumbList, BreadcrumbItem,
       BreadcrumbLink, BreadcrumbPage, BreadcrumbSeparator,
       BreadcrumbEllipsis

"""
    Breadcrumb(children...; class, kwargs...) -> VNode

A navigation breadcrumb trail.
Equivalent to shadcn/ui's Breadcrumb component.

# Examples
```julia
Breadcrumb(
    BreadcrumbList(
        BreadcrumbItem(BreadcrumbLink("Home", href="/")),
        BreadcrumbSeparator(),
        BreadcrumbItem(BreadcrumbLink("Components", href="/components")),
        BreadcrumbSeparator(),
        BreadcrumbItem(BreadcrumbPage("Breadcrumb")),
    ),
)
```
"""
function Breadcrumb(children...; class::String="", kwargs...)
    Nav(:aria_label => "breadcrumb", :class => class == "" ? nothing : class, kwargs..., children...)
end

"""
    BreadcrumbList(children...; class, kwargs...) -> VNode

Ordered list container for breadcrumb items.
"""
function BreadcrumbList(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("text-warm-600 dark:text-warm-500 flex flex-wrap items-center gap-1.5 text-sm break-words", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    Ol(:class => classes, kwargs..., children...)
end

"""
    BreadcrumbItem(children...; class, kwargs...) -> VNode

Individual breadcrumb item wrapper.
"""
function BreadcrumbItem(children...; class::String="", kwargs...)
    classes = cn("inline-flex items-center gap-1.5", class)
    Li(:class => classes, kwargs..., children...)
end

"""
    BreadcrumbLink(children...; href, class, kwargs...) -> VNode

Clickable breadcrumb link.
"""
function BreadcrumbLink(children...; href::String="#", class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("cursor-pointer hover:text-warm-800 dark:hover:text-warm-300 transition-colors", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    A(:href => href, :class => classes, kwargs..., children...)
end

"""
    BreadcrumbPage(children...; class, kwargs...) -> VNode

Current page indicator (non-clickable).
"""
function BreadcrumbPage(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("text-warm-800 dark:text-warm-300 font-normal", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    Span(:role => "link", :aria_disabled => "true", :aria_current => "page",
         :class => classes, kwargs..., children...)
end

"""
    BreadcrumbSeparator(children...; class, kwargs...) -> VNode

Visual separator between breadcrumb items. Default separator is "/".
"""
function BreadcrumbSeparator(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("text-warm-400 dark:text-warm-600", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    sep_content = isempty(children) ? ("/" ,) : children
    Li(:role => "presentation", :aria_hidden => "true",
       :class => classes, kwargs..., sep_content...)
end

"""
    BreadcrumbEllipsis(; class, kwargs...) -> VNode

Ellipsis indicator for collapsed breadcrumb items.
"""
function BreadcrumbEllipsis(; class::String="", kwargs...)
    classes = cn("flex size-9 items-center justify-center", class)
    Span(:role => "presentation", :aria_hidden => "true",
         :class => classes, kwargs...,
         "...",
         Span(:class => "sr-only", "More"),
    )
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Breadcrumb,
        "Breadcrumb.jl",
        :styling,
        "Navigation breadcrumb trail",
        Symbol[],
        Symbol[],
        [:Breadcrumb, :BreadcrumbList, :BreadcrumbItem,
         :BreadcrumbLink, :BreadcrumbPage, :BreadcrumbSeparator,
         :BreadcrumbEllipsis],
    ))
end
