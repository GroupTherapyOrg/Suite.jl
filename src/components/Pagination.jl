# Pagination.jl — Suite.jl Pagination Component
#
# Tier: island (Wasm — click navigation for page links)
# Suite Dependencies: Button (uses button variant styling)
# JS Modules: none
#
# Usage via package: using Suite; Pagination(PaginationContent(...))
# Usage via extract: include("components/Pagination.jl"); Pagination(...)
#
# Signal-driven page navigation: clicking page links, prev/next updates active page.
# Uses match_descendants binding: active page link gets data-state="open",
# others get data-state="closed". Follows Carousel pattern exactly.
#
# Reference: shadcn/ui Pagination — https://ui.shadcn.com/docs/components/pagination

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Pagination, PaginationContent, PaginationItem,
       PaginationLink, PaginationPrevious, PaginationNext,
       PaginationEllipsis

# Button variant classes reused for pagination links
const _PAGINATION_OUTLINE = "border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-950 hover:bg-warm-100 dark:hover:bg-warm-900 text-warm-800 dark:text-warm-300"
const _PAGINATION_GHOST = "hover:bg-warm-100 dark:hover:bg-warm-900 text-warm-800 dark:text-warm-300"
const _PAGINATION_BTN_BASE = "inline-flex items-center justify-center gap-2 whitespace-nowrap cursor-pointer rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600"

# SSR helper: walk Pagination children, inject data-index + initial data-state.
# Returns (link_count, initial_active_page).
# PaginationLink items get 1..N (1-based), PaginationPrevious gets 100, PaginationNext gets 101.
function _pagination_ssr_setup!(children, initial_active::Int)
    link_idx = 0
    _walk_pagination_children!(children, link_idx, initial_active)
end

function _walk_pagination_children!(children, link_idx::Int, initial_active::Int)
    for child in children
        child isa VNode || continue
        # PaginationLink — has data-pagination-link marker
        if haskey(child.props, :data_pagination_link)
            link_idx += 1
            child.props[Symbol("data-index")] = string(link_idx)
            child.props[Symbol("data-state")] = link_idx == initial_active ? "open" : "closed"
        end
        # PaginationPrevious
        if haskey(child.props, :data_pagination_prev)
            child.props[Symbol("data-index")] = "100"
        end
        # PaginationNext
        if haskey(child.props, :data_pagination_next)
            child.props[Symbol("data-index")] = "101"
        end
        # Recurse into children (PaginationContent -> PaginationItem -> PaginationLink)
        if !isempty(child.children)
            link_idx = _walk_pagination_children!(child.children, link_idx, initial_active)
        end
    end
    return link_idx
end

#   Pagination(children...; class, kwargs...) -> VNode
#
# A pagination navigation bar with interactive page switching.
# Equivalent to shadcn/ui's Pagination component.
# Uses a single signal for current active page (1-based).
# Follows the Carousel pattern: 1 signal + match_descendants + click handler.
#
# Examples:
#   Pagination(PaginationContent(PaginationItem(PaginationLink("1", is_active=true)), ...))
@island function Pagination(children...; class::String="", theme::Symbol=:default, kwargs...)
    # Signal: current active page (1-based)
    # Initial value comes from _p prop (set by props transform)
    current_page, set_current_page = create_signal(Int32(1))

    # Auto-register match_descendants binding for data-state on [data-index] elements
    compiled_register_match_descendants(Int32(1), Int32(0))

    # SSR: walk children, inject data-index + initial data-state
    initial_active = _find_pagination_initial_active(children)
    _pagination_ssr_setup!(children, initial_active)

    classes = cn("mx-auto flex w-full justify-center", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Nav(:role => "navigation", :aria_label => "pagination",
        :class => classes,
        :on_click => () -> begin
            idx = compiled_get_event_data_index()
            # Prev button: data-index 100
            if idx == Int32(100)
                current = current_page()
                new_idx = current - Int32(1)
                if new_idx >= Int32(1)
                    set_current_page(new_idx)
                end
            end
            # Next button: data-index 101
            if idx == Int32(101)
                current = current_page()
                n = compiled_get_prop_i32(Int32(0))
                new_idx = current + Int32(1)
                if new_idx <= n
                    set_current_page(new_idx)
                end
            end
            # Direct page link: data-index 1..N (below 100)
            if idx >= Int32(1)
                if idx < Int32(100)
                    set_current_page(idx)
                end
            end
        end,
        kwargs..., children...)
end

# Helper: find which PaginationLink has is_active=true, return its 1-based index
function _find_pagination_initial_active(children)
    result = _scan_pagination_active(children, 0)
    return result > 0 ? result : 1
end

function _scan_pagination_active(children, count::Int)
    for child in children
        child isa VNode || continue
        if haskey(child.props, :data_pagination_link)
            count += 1
            if get(child.props, Symbol("data-pagination-active"), nothing) == "true"
                return count
            end
        end
        result = _scan_pagination_active(child.children, count)
        if result > 0
            return result
        end
        # Update count for sibling traversal
        count = _count_pagination_links_in(child.children, count)
    end
    return 0
end

function _count_pagination_links_in(children, count::Int)
    for child in children
        child isa VNode || continue
        if haskey(child.props, :data_pagination_link)
            count += 1
        end
        count = _count_pagination_links_in(child.children, count)
    end
    return count
end

"""
    PaginationContent(children...; class, kwargs...) -> VNode

Container for pagination items.
"""
function PaginationContent(children...; class::String="", kwargs...)
    classes = cn("flex flex-row items-center gap-1", class)
    Ul(:class => classes, kwargs..., children...)
end

"""
    PaginationItem(children...; kwargs...) -> VNode

Wrapper for individual pagination elements.
"""
function PaginationItem(children...; kwargs...)
    Li(kwargs..., children...)
end

"""
    PaginationLink(children...; is_active, size, href, class, kwargs...) -> VNode

A pagination page number link.
"""
function PaginationLink(children...; is_active::Bool=false, size::String="icon",
                              href::String="javascript:void(0)", class::String="", theme::Symbol=:default, kwargs...)
    size_classes = Dict(
        "default" => "h-10 px-4 py-2",
        "icon"    => "h-10 w-10",
    )

    # Use data-state for active styling (driven by Wasm signal match binding)
    variant_cls = is_active ? _PAGINATION_OUTLINE : _PAGINATION_GHOST
    sc = get(size_classes, size, size_classes["icon"])
    # Both active and inactive base classes + data-state driven override
    classes = cn(
        _PAGINATION_BTN_BASE, _PAGINATION_GHOST, sc,
        "data-[state=open]:border data-[state=open]:border-warm-200 data-[state=open]:dark:border-warm-700",
        "data-[state=open]:bg-warm-50 data-[state=open]:dark:bg-warm-950",
        class,
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    extra = is_active ? (:aria_current => "page",) : ()

    A(:href => href, :class => classes,
      :data_pagination_link => "true",
      is_active ? (Symbol("data-pagination-active") => "true") : (Symbol("data-pagination-active") => "false"),
      extra...,
      kwargs..., children...)
end

"""
    PaginationPrevious(; href, class, kwargs...) -> VNode

Previous page navigation link.
"""
function PaginationPrevious(; href::String="javascript:void(0)", class::String="", kwargs...)
    classes = cn(_PAGINATION_BTN_BASE, _PAGINATION_GHOST, "h-10 px-4 py-2 gap-1", class)
    A(:href => href, :aria_label => "Go to previous page",
      :class => classes,
      :data_pagination_prev => "true",
      kwargs...,
      Span(:class => "hidden sm:block", "Previous"),
    )
end

"""
    PaginationNext(; href, class, kwargs...) -> VNode

Next page navigation link.
"""
function PaginationNext(; href::String="javascript:void(0)", class::String="", kwargs...)
    classes = cn(_PAGINATION_BTN_BASE, _PAGINATION_GHOST, "h-10 px-4 py-2 gap-1", class)
    A(:href => href, :aria_label => "Go to next page",
      :class => classes,
      :data_pagination_next => "true",
      kwargs...,
      Span(:class => "hidden sm:block", "Next"),
    )
end

"""
    PaginationEllipsis(; class, kwargs...) -> VNode

Ellipsis indicator for skipped pages.
"""
function PaginationEllipsis(; class::String="", kwargs...)
    classes = cn("flex size-9 items-center justify-center", class)
    Span(:aria_hidden => "true", :class => classes, kwargs...,
         "...",
         Span(:class => "sr-only", "More pages"),
    )
end

# --- Hydration Support ---

const _PAGINATION_PROPS_TRANSFORM = (props, args) -> begin
    # Count page links by walking children recursively
    link_count = _count_all_pagination_links(args)

    # Find initial active page
    initial_active = _find_all_initial_active(args)
    if initial_active == 0
        initial_active = 1
    end

    props[:_n] = link_count
    props[:_p] = initial_active
end

function _count_all_pagination_links(nodes)
    count = 0
    for node in nodes
        node isa Therapy.VNode || continue
        if haskey(node.props, :data_pagination_link)
            count += 1
        end
        count += _count_all_pagination_links(node.children)
    end
    return count
end

function _find_all_initial_active(nodes)
    idx = 0
    for node in nodes
        node isa Therapy.VNode || continue
        if haskey(node.props, :data_pagination_link)
            idx += 1
            if get(node.props, Symbol("data-pagination-active"), nothing) == "true"
                return idx
            end
        end
        result = _find_all_initial_active(node.children)
        if result > 0
            return result
        end
    end
    return 0
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Pagination,
        "Pagination.jl",
        :island,
        "Pagination navigation bar",
        [:Button],
        Symbol[],
        [:Pagination, :PaginationContent, :PaginationItem,
         :PaginationLink, :PaginationPrevious, :PaginationNext,
         :PaginationEllipsis],
    ))
end
