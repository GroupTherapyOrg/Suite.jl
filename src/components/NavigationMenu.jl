# NavigationMenu.jl — Suite.jl Navigation Menu Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; NavigationMenu(NavigationMenuList(...))
# Usage via extract: include("components/NavigationMenu.jl"); NavigationMenu(...)
#
# Behavior (matches Radix NavigationMenu):
#   - Hover trigger to open content panel (200ms delay)
#   - Click trigger for immediate toggle
#   - Hover content keeps panel open; leave starts close timer (150ms)
#   - Skip delay (300ms) for rapid switching between items
#   - Inline content panels (no viewport — matches shadcn viewport=false)
#   - Escape to dismiss
#   - Motion attributes for directional slide animation
#   - Signal-driven: Int32 signal (0=none, N=item N is open)
#   - ShowDescendants binding handles show/hide + data-state on content children

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export NavigationMenu, NavigationMenuList, NavigationMenuItem,
       NavigationMenuTrigger, NavigationMenuContent,
       NavigationMenuLink, NavigationMenuViewport,
       NavigationMenuIndicator

# --- Chevron Down SVG ---
const _NAV_CHEVRON_DOWN = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16" fill="none" aria-hidden="true" class="relative top-[1px] ml-1 size-3 transition duration-300 group-data-[state=open]:rotate-180"><path d="M4 6L8 10L12 6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>"""

#   NavigationMenu(children...; orientation, delay_duration, skip_delay_duration, theme, class, kwargs...) -> IslandVNode
#
# A site navigation menu with hover-triggered content panels.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# NavigationMenuItem children with triggers are auto-detected and injected
# with signal bindings for hover-to-open behavior.
# ShowDescendants binding handles show/hide + data-state on content descendants.
#
# Examples:
#   NavigationMenu(
#       NavigationMenuList(
#           NavigationMenuItem(
#               NavigationMenuTrigger("Getting Started"),
#               NavigationMenuContent(
#                   NavigationMenuLink("Introduction", href="/docs/"),
#               )
#           ),
#           NavigationMenuItem(
#               NavigationMenuLink("Documentation", href="/docs/")
#           ),
#       ),
#   )
@island function NavigationMenu(children...; orientation::String="horizontal", delay_duration::Int=200, skip_delay_duration::Int=300, theme::Symbol=:default, class::String="", kwargs...)
    # Compilable: 1 signal for active item index (Int32: 0=none, N=item N is open)
    active_item, set_active = create_signal(Int32(0))

    # SSR-only: walk children, inject data-index on trigger markers
    _nav_ssr_setup!(children)

    classes = cn(
        "relative flex max-w-max flex-1 items-center justify-center",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-nav-menu") => "",
        Symbol("data-show") => ShowDescendants(active_item),  # show/hide + data-state binding (inline Wasm)
        Symbol("data-orientation") => orientation,
        Symbol("data-delay-duration") => string(delay_duration),
        Symbol("data-skip-delay-duration") => string(skip_delay_duration),
        :class => classes,
        :on_click => () -> begin
            idx = compiled_get_event_data_index()
            if idx >= Int32(0)
                item_idx = idx + Int32(1)  # 0-based data-index → 1-based signal
                if active_item() == item_idx
                    set_active(Int32(0))  # Close
                else
                    set_active(item_idx)  # Open
                end
            end
        end,
        kwargs...,
        children...,
    )
end

# SSR helper: walk VNode tree to find NavigationMenuItems with triggers and inject data-index.
# Extracted from the island body so the AST transform doesn't try to compile for-loops.
function _nav_ssr_setup!(children)
    idx_ref = Ref(0)
    for child in children
        if child isa VNode
            _nav_ssr_walk!(child, idx_ref)
        end
    end
end

function _nav_ssr_walk!(node::VNode, idx_ref::Ref{Int})
    if haskey(node.props, Symbol("data-nav-menu-item"))
        # Check if this item has a trigger marker
        has_trigger = false
        for child in node.children
            if child isa VNode && haskey(child.props, Symbol("data-nav-menu-trigger-marker"))
                has_trigger = true
                break
            end
        end
        if has_trigger
            _nav_ssr_inject!(node, idx_ref[])
            idx_ref[] += 1
        end
        return  # Don't recurse into items
    end
    for child in node.children
        if child isa VNode
            _nav_ssr_walk!(child, idx_ref)
        end
    end
end

function _nav_ssr_inject!(item::VNode, idx::Int)
    for child in item.children
        if child isa VNode && haskey(child.props, Symbol("data-nav-menu-trigger-marker"))
            # Add data-index on trigger marker for event delegation
            child.props[Symbol("data-index")] = string(idx)
        end
    end
end

"""
    NavigationMenuList(children...; class, kwargs...) -> VNode

Container for navigation menu items. Renders as a `<ul>`.
"""
function NavigationMenuList(children...; class::String="", kwargs...)
    Ul(Symbol("data-nav-menu-list") => "",
       :class => cn(
           "flex flex-1 list-none items-center justify-center gap-1",
           class
       ),
       kwargs...,
       children...,
    )
end

"""
    NavigationMenuItem(children...; value, class, kwargs...) -> VNode

A single item within the navigation menu. Can contain a trigger + content or just a link.
"""
function NavigationMenuItem(children...; value::String="", class::String="", kwargs...)
    Li(Symbol("data-nav-menu-item") => "",
       (isempty(value) ? Pair{Symbol,String}[] : [Symbol("data-value") => value])...,
       :class => cn("relative", class),
       kwargs...,
       children...,
    )
end

"""
    NavigationMenuTrigger(children...; disabled, class, kwargs...) -> VNode

The trigger button that opens a navigation menu content panel.
"""
function NavigationMenuTrigger(children...; disabled::Bool=false, theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "group inline-flex h-9 w-max items-center justify-center cursor-pointer rounded-md px-4 py-2",
        "text-sm font-medium text-warm-800 dark:text-warm-300 transition-[color,box-shadow]",
        "bg-warm-50 dark:bg-warm-950",
        "hover:bg-warm-100 hover:dark:bg-warm-800",
        "data-[state=open]:bg-warm-100/50 data-[state=open]:dark:bg-warm-800/50",
        "disabled:pointer-events-none disabled:opacity-50",
        "focus-visible:ring-[3px] focus-visible:ring-accent-600/50",
        "focus-visible:outline-1 outline-none",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Span(Symbol("data-nav-menu-trigger-marker") => "",
         :style => "display:contents",
         Therapy.Button(Symbol("data-nav-menu-trigger") => "",
                Symbol("data-state") => "closed",
                Symbol("aria-expanded") => "false",
                :type => "button",
                :class => classes,
                (disabled ? [:disabled => ""] : Pair{Symbol,String}[])...,
                kwargs...,
                children...,
                Therapy.RawHtml(_NAV_CHEVRON_DOWN),
         ),
    )
end

"""
    NavigationMenuContent(children...; class, kwargs...) -> VNode

The content panel that appears when a trigger is hovered/clicked.
Renders as an inline dropdown (no viewport).
"""
function NavigationMenuContent(children...; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "glass-panel",
        # Inline dropdown positioning (no viewport)
        "absolute top-full left-0 mt-1.5 z-50",
        # Sizing and layout
        "w-[400px] lg:w-[500px] p-4 grid gap-3 md:grid-cols-2",
        # Visual appearance
        "bg-warm-50 dark:bg-warm-900 text-warm-800 dark:text-warm-300",
        "border border-warm-200 dark:border-warm-700",
        "rounded-md shadow-lg overflow-hidden",
        # Open/close animations
        "data-[state=open]:animate-in data-[state=closed]:animate-out",
        "data-[state=open]:fade-in-0 data-[state=closed]:fade-out-0",
        "data-[state=open]:zoom-in-95 data-[state=closed]:zoom-out-95",
        "duration-200",
        # Directional slide animations
        "data-[motion^=from-]:animate-in data-[motion^=to-]:animate-out",
        "data-[motion^=from-]:fade-in data-[motion^=to-]:fade-out",
        "data-[motion=from-end]:slide-in-from-right-52",
        "data-[motion=from-start]:slide-in-from-left-52",
        "data-[motion=to-end]:slide-out-to-right-52",
        "data-[motion=to-start]:slide-out-to-left-52",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-nav-menu-content") => "",
        Symbol("data-state") => "closed",
        :style => "display:none",
        :class => classes,
        kwargs...,
        children...,
    )
end

"""
    NavigationMenuLink(children...; href, active, description, class, kwargs...) -> VNode

A link item within the navigation menu content. Can include a description.
"""
function NavigationMenuLink(children...; href::String="#", active::Bool=false, description::String="", theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "flex flex-col gap-1 rounded-sm p-2 text-sm cursor-pointer transition-all outline-none",
        "hover:bg-warm-100 hover:dark:bg-warm-800",
        "focus:bg-warm-100 focus:dark:bg-warm-800",
        "focus-visible:ring-[3px] focus-visible:ring-accent-600/50 focus-visible:outline-1",
        active && "bg-warm-100/50 dark:bg-warm-800/50",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    link_children = collect(Any, children)
    if !isempty(description)
        push!(link_children, Span(:class => "text-xs text-warm-600 dark:text-warm-500 line-clamp-2", description))
    end

    A(Symbol("data-nav-menu-link") => "",
      :href => href,
      :class => classes,
      (active ? [Symbol("data-active") => "true"] : Pair{Symbol,String}[])...,
      kwargs...,
      link_children...,
    )
end

"""
    NavigationMenuViewport(; kwargs...) -> VNode

Deprecated — no-op. Inline content panels are used instead.
Kept for backwards compatibility; renders nothing.
"""
function NavigationMenuViewport(; theme::Symbol=:default, class::String="", kwargs...)
    # No-op — inline content panels render directly under their triggers.
    # The viewport pattern requires React-style context/portal which is
    # impractical in vanilla JS. shadcn v4 supports viewport=false natively.
    Fragment()
end

"""
    NavigationMenuIndicator(; class, kwargs...) -> VNode

Visual indicator arrow that slides to show the active trigger position.
"""
function NavigationMenuIndicator(; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "top-full z-[1] flex h-1.5 items-end justify-center overflow-hidden",
        "data-[state=visible]:animate-in data-[state=hidden]:animate-out",
        "data-[state=hidden]:fade-out data-[state=visible]:fade-in",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    arrow_classes = "relative top-[60%] h-2 w-2 rotate-45 rounded-tl-sm shadow-md bg-warm-200 dark:bg-warm-700"
    theme !== :default && (arrow_classes = apply_theme(arrow_classes, get_theme(theme)))

    Div(Symbol("data-nav-menu-indicator") => "",
        Symbol("data-state") => "hidden",
        :class => classes,
        kwargs...,
        Div(:class => arrow_classes))
end

# --- Props Transform (counts trigger items for while loop) ---
function _count_nav_trigger_items(node)
    count = 0
    if node isa VNode && haskey(node.props, Symbol("data-nav-menu-item"))
        for child in node.children
            if child isa VNode && haskey(child.props, Symbol("data-nav-menu-trigger-marker"))
                count += 1
                break
            end
        end
    end
    if node isa VNode
        for child in node.children
            count += _count_nav_trigger_items(child)
        end
    end
    count
end

const _NAVIGATIONMENU_PROPS_TRANSFORM = (props, args) -> begin
    count = 0
    for arg in args
        count += _count_nav_trigger_items(arg)
    end
    props[:n_items] = count
end


# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :NavigationMenu,
        "NavigationMenu.jl",
        :island,
        "Site navigation menu with hover-triggered inline content panels",
        Symbol[],
        Symbol[],
        [:NavigationMenu, :NavigationMenuList, :NavigationMenuItem,
         :NavigationMenuTrigger, :NavigationMenuContent,
         :NavigationMenuLink, :NavigationMenuViewport,
         :NavigationMenuIndicator],
    ))
end
