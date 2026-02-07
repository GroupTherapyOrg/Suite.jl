# SuiteBreadcrumb.jl — Suite.jl Breadcrumb Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; SuiteBreadcrumb(SuiteBreadcrumbList(...))
# Usage via extract: include("components/Breadcrumb.jl"); SuiteBreadcrumb(...)
#
# Reference: shadcn/ui Breadcrumb — https://ui.shadcn.com/docs/components/breadcrumb

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteBreadcrumb, SuiteBreadcrumbList, SuiteBreadcrumbItem,
       SuiteBreadcrumbLink, SuiteBreadcrumbPage, SuiteBreadcrumbSeparator,
       SuiteBreadcrumbEllipsis

"""
    SuiteBreadcrumb(children...; class, kwargs...) -> VNode

A navigation breadcrumb trail.
Equivalent to shadcn/ui's Breadcrumb component.

# Examples
```julia
SuiteBreadcrumb(
    SuiteBreadcrumbList(
        SuiteBreadcrumbItem(SuiteBreadcrumbLink("Home", href="/")),
        SuiteBreadcrumbSeparator(),
        SuiteBreadcrumbItem(SuiteBreadcrumbLink("Components", href="/components")),
        SuiteBreadcrumbSeparator(),
        SuiteBreadcrumbItem(SuiteBreadcrumbPage("Breadcrumb")),
    ),
)
```
"""
function SuiteBreadcrumb(children...; class::String="", kwargs...)
    Nav(:aria_label => "breadcrumb", :class => class == "" ? nothing : class, kwargs..., children...)
end

"""
    SuiteBreadcrumbList(children...; class, kwargs...) -> VNode

Ordered list container for breadcrumb items.
"""
function SuiteBreadcrumbList(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("text-warm-600 dark:text-warm-500 flex flex-wrap items-center gap-1.5 text-sm break-words", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    Ol(:class => classes, kwargs..., children...)
end

"""
    SuiteBreadcrumbItem(children...; class, kwargs...) -> VNode

Individual breadcrumb item wrapper.
"""
function SuiteBreadcrumbItem(children...; class::String="", kwargs...)
    classes = cn("inline-flex items-center gap-1.5", class)
    Li(:class => classes, kwargs..., children...)
end

"""
    SuiteBreadcrumbLink(children...; href, class, kwargs...) -> VNode

Clickable breadcrumb link.
"""
function SuiteBreadcrumbLink(children...; href::String="#", class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("cursor-pointer hover:text-warm-800 dark:hover:text-warm-300 transition-colors", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    A(:href => href, :class => classes, kwargs..., children...)
end

"""
    SuiteBreadcrumbPage(children...; class, kwargs...) -> VNode

Current page indicator (non-clickable).
"""
function SuiteBreadcrumbPage(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("text-warm-800 dark:text-warm-300 font-normal", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    Span(:role => "link", :aria_disabled => "true", :aria_current => "page",
         :class => classes, kwargs..., children...)
end

"""
    SuiteBreadcrumbSeparator(children...; class, kwargs...) -> VNode

Visual separator between breadcrumb items. Default separator is "/".
"""
function SuiteBreadcrumbSeparator(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("text-warm-400 dark:text-warm-600", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    sep_content = isempty(children) ? ("/" ,) : children
    Li(:role => "presentation", :aria_hidden => "true",
       :class => classes, kwargs..., sep_content...)
end

"""
    SuiteBreadcrumbEllipsis(; class, kwargs...) -> VNode

Ellipsis indicator for collapsed breadcrumb items.
"""
function SuiteBreadcrumbEllipsis(; class::String="", kwargs...)
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
        [:SuiteBreadcrumb, :SuiteBreadcrumbList, :SuiteBreadcrumbItem,
         :SuiteBreadcrumbLink, :SuiteBreadcrumbPage, :SuiteBreadcrumbSeparator,
         :SuiteBreadcrumbEllipsis],
    ))
end
