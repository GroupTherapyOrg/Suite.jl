# SuitePagination.jl — Suite.jl Pagination Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: Button (uses button variant styling)
# JS Modules: none
#
# Usage via package: using Suite; SuitePagination(SuitePaginationContent(...))
# Usage via extract: include("components/Pagination.jl"); SuitePagination(...)
#
# Reference: shadcn/ui Pagination — https://ui.shadcn.com/docs/components/pagination

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuitePagination, SuitePaginationContent, SuitePaginationItem,
       SuitePaginationLink, SuitePaginationPrevious, SuitePaginationNext,
       SuitePaginationEllipsis

# Button variant classes reused for pagination links
const _PAGINATION_OUTLINE = "border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-950 hover:bg-warm-100 dark:hover:bg-warm-900 text-warm-800 dark:text-warm-300"
const _PAGINATION_GHOST = "hover:bg-warm-100 dark:hover:bg-warm-900 text-warm-800 dark:text-warm-300"
const _PAGINATION_BTN_BASE = "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600"

"""
    SuitePagination(children...; class, kwargs...) -> VNode

A pagination navigation bar.
Equivalent to shadcn/ui's Pagination component.

# Examples
```julia
SuitePagination(
    SuitePaginationContent(
        SuitePaginationItem(SuitePaginationPrevious(href="/page/1")),
        SuitePaginationItem(SuitePaginationLink("1", href="/page/1", is_active=true)),
        SuitePaginationItem(SuitePaginationLink("2", href="/page/2")),
        SuitePaginationItem(SuitePaginationLink("3", href="/page/3")),
        SuitePaginationItem(SuitePaginationEllipsis()),
        SuitePaginationItem(SuitePaginationNext(href="/page/2")),
    ),
)
```
"""
function SuitePagination(children...; class::String="", kwargs...)
    classes = cn("mx-auto flex w-full justify-center", class)
    Nav(:role => "navigation", :aria_label => "pagination",
        :class => classes, kwargs..., children...)
end

"""
    SuitePaginationContent(children...; class, kwargs...) -> VNode

Container for pagination items.
"""
function SuitePaginationContent(children...; class::String="", kwargs...)
    classes = cn("flex flex-row items-center gap-1", class)
    Ul(:class => classes, kwargs..., children...)
end

"""
    SuitePaginationItem(children...; kwargs...) -> VNode

Wrapper for individual pagination elements.
"""
function SuitePaginationItem(children...; kwargs...)
    Li(kwargs..., children...)
end

"""
    SuitePaginationLink(children...; is_active, size, href, class, kwargs...) -> VNode

A pagination page number link.
"""
function SuitePaginationLink(children...; is_active::Bool=false, size::String="icon",
                              href::String="#", class::String="", theme::Symbol=:default, kwargs...)
    size_classes = Dict(
        "default" => "h-10 px-4 py-2",
        "icon"    => "h-10 w-10",
    )

    variant_cls = is_active ? _PAGINATION_OUTLINE : _PAGINATION_GHOST
    sc = get(size_classes, size, size_classes["icon"])
    classes = cn(_PAGINATION_BTN_BASE, variant_cls, sc, class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    aria_current = is_active ? "page" : nothing
    extra = is_active ? (:aria_current => aria_current,) : ()

    A(:href => href, :class => classes, extra..., kwargs..., children...)
end

"""
    SuitePaginationPrevious(; href, class, kwargs...) -> VNode

Previous page navigation link.
"""
function SuitePaginationPrevious(; href::String="#", class::String="", kwargs...)
    classes = cn(_PAGINATION_BTN_BASE, _PAGINATION_GHOST, "h-10 px-4 py-2 gap-1", class)
    A(:href => href, :aria_label => "Go to previous page",
      :class => classes, kwargs...,
      Span(:class => "hidden sm:block", "Previous"),
    )
end

"""
    SuitePaginationNext(; href, class, kwargs...) -> VNode

Next page navigation link.
"""
function SuitePaginationNext(; href::String="#", class::String="", kwargs...)
    classes = cn(_PAGINATION_BTN_BASE, _PAGINATION_GHOST, "h-10 px-4 py-2 gap-1", class)
    A(:href => href, :aria_label => "Go to next page",
      :class => classes, kwargs...,
      Span(:class => "hidden sm:block", "Next"),
    )
end

"""
    SuitePaginationEllipsis(; class, kwargs...) -> VNode

Ellipsis indicator for skipped pages.
"""
function SuitePaginationEllipsis(; class::String="", kwargs...)
    classes = cn("flex size-9 items-center justify-center", class)
    Span(:aria_hidden => "true", :class => classes, kwargs...,
         "...",
         Span(:class => "sr-only", "More pages"),
    )
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Pagination,
        "Pagination.jl",
        :styling,
        "Pagination navigation bar",
        [:Button],
        Symbol[],
        [:SuitePagination, :SuitePaginationContent, :SuitePaginationItem,
         :SuitePaginationLink, :SuitePaginationPrevious, :SuitePaginationNext,
         :SuitePaginationEllipsis],
    ))
end
