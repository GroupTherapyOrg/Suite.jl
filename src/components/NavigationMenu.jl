# NavigationMenu.jl — Suite.jl Navigation Menu Component
#
# Tier: js_runtime (requires suite.js for hover timers, viewport sizing, animation)
# Suite Dependencies: none (leaf component)
# JS Modules: NavigationMenu, DismissLayer
#
# Usage via package: using Suite; NavigationMenu(NavigationMenuList(...))
# Usage via extract: include("components/NavigationMenu.jl"); NavigationMenu(...)
#
# Behavior (matches Radix NavigationMenu):
#   - Hover trigger to open content panel (200ms delay)
#   - Click trigger for immediate toggle
#   - Hover content keeps panel open; leave starts close timer (150ms)
#   - Skip delay (300ms) for rapid switching between items
#   - Viewport dynamically sizes to content
#   - Escape to dismiss
#   - Motion attributes for directional slide animation

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

"""
    NavigationMenu(children...; class, kwargs...) -> VNode

A site navigation menu with hover-triggered content panels.

# Examples
```julia
NavigationMenu(
    NavigationMenuList(
        NavigationMenuItem(
            NavigationMenuTrigger("Getting Started"),
            NavigationMenuContent(
                NavigationMenuLink("Introduction", href="/docs/", description="Learn about Suite.jl"),
                NavigationMenuLink("Installation", href="/docs/install/", description="How to install"),
            )
        ),
        NavigationMenuItem(
            NavigationMenuLink("Documentation", href="/docs/")
        ),
    ),
    NavigationMenuViewport(),
)
```
"""
function NavigationMenu(children...; orientation::String="horizontal", delay_duration::Int=200, skip_delay_duration::Int=300, theme::Symbol=:default, class::String="", kwargs...)
    id = "suite-nav-menu-" * string(rand(UInt32), base=16)

    classes = cn(
        "relative flex max-w-max flex-1 items-center justify-center",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-suite-nav-menu") => id,
        Symbol("data-orientation") => orientation,
        Symbol("data-delay-duration") => string(delay_duration),
        Symbol("data-skip-delay-duration") => string(skip_delay_duration),
        :class => classes,
        kwargs...,
        children...,
    )
end

"""
    NavigationMenuList(children...; class, kwargs...) -> VNode

Container for navigation menu items. Renders as a `<ul>`.
"""
function NavigationMenuList(children...; class::String="", kwargs...)
    Ul(Symbol("data-suite-nav-menu-list") => "",
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
    item_value = isempty(value) ? "nav-item-" * string(rand(UInt32), base=16) : value

    Li(Symbol("data-suite-nav-menu-item") => "",
       Symbol("data-value") => item_value,
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

    Therapy.Button(Symbol("data-suite-nav-menu-trigger") => "",
           Symbol("data-state") => "closed",
           :type => "button",
           :class => classes,
           (disabled ? [:disabled => ""] : Pair{Symbol,String}[])...,
           kwargs...,
           children...,
           Therapy.RawHtml(_NAV_CHEVRON_DOWN),
    )
end

"""
    NavigationMenuContent(children...; class, kwargs...) -> VNode

The content panel that appears when a trigger is hovered/clicked.
"""
function NavigationMenuContent(children...; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "top-0 left-0 w-full p-4 md:absolute md:w-auto",
        "data-[motion^=from-]:animate-in data-[motion^=to-]:animate-out",
        "data-[motion^=from-]:fade-in data-[motion^=to-]:fade-out",
        "data-[motion=from-end]:slide-in-from-right-52",
        "data-[motion=from-start]:slide-in-from-left-52",
        "data-[motion=to-end]:slide-out-to-right-52",
        "data-[motion=to-start]:slide-out-to-left-52",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-suite-nav-menu-content") => "",
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

    A(Symbol("data-suite-nav-menu-link") => "",
      :href => href,
      :class => classes,
      (active ? [Symbol("data-active") => "true"] : Pair{Symbol,String}[])...,
      kwargs...,
      link_children...,
    )
end

"""
    NavigationMenuViewport(; class, kwargs...) -> VNode

Dynamic sizing viewport container for navigation menu content panels.
"""
function NavigationMenuViewport(; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "origin-top-center mt-1.5 overflow-hidden rounded-md shadow",
        "bg-warm-50 dark:bg-warm-900",
        "border border-warm-200 dark:border-warm-700",
        "text-warm-800 dark:text-warm-300",
        "data-[state=open]:animate-in data-[state=closed]:animate-out",
        "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-90",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(:class => "absolute top-full left-0 flex justify-center",
        Div(Symbol("data-suite-nav-menu-viewport") => "",
            Symbol("data-state") => "closed",
            :style => "display:none",
            :class => classes,
            kwargs...))
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

    Div(Symbol("data-suite-nav-menu-indicator") => "",
        Symbol("data-state") => "hidden",
        :class => classes,
        kwargs...,
        Div(:class => arrow_classes))
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :NavigationMenu,
        "NavigationMenu.jl",
        :js_runtime,
        "Site navigation menu with hover-triggered content panels and viewport",
        Symbol[],
        [:NavigationMenu, :DismissLayer],
        [:NavigationMenu, :NavigationMenuList, :NavigationMenuItem,
         :NavigationMenuTrigger, :NavigationMenuContent,
         :NavigationMenuLink, :NavigationMenuViewport,
         :NavigationMenuIndicator],
    ))
end
