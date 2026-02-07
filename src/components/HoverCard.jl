# SuiteHoverCard.jl — Suite.jl HoverCard Component
#
# Tier: js_runtime (requires suite.js)
# Suite Dependencies: none (leaf component)
# JS Modules: Floating, DismissLayer, HoverCard
#
# Usage via package: using Suite; SuiteHoverCard(...)
# Usage via extract: include("components/HoverCard.jl"); SuiteHoverCard(...)
#
# Behavior (matches Radix HoverCard):
#   - Hover-triggered preview card for links/anchors
#   - Open delay 700ms, close delay 300ms
#   - Hovering content keeps card open
#   - Touch events ignored (mouse/keyboard only)
#   - Escape key dismisses
#   - Click outside dismisses
#   - No focus trap (preview content, not interactive)

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteHoverCard, SuiteHoverCardTrigger, SuiteHoverCardContent

"""
    SuiteHoverCard(children...; open_delay, close_delay, class, kwargs...) -> VNode

A hover-triggered preview card. Shows rich content when hovering a trigger.

# Arguments
- `open_delay::Int=700`: Milliseconds before card opens on hover
- `close_delay::Int=300`: Milliseconds before card closes after leaving

# Examples
```julia
SuiteHoverCard(
    SuiteHoverCardTrigger(
        A(:href => "#", :class => "underline", "@juliahub")
    ),
    SuiteHoverCardContent(
        Div(:class => "flex gap-4",
            SuiteAvatar(src="/avatar.png", fallback="JH"),
            Div(
                H4(:class => "text-sm font-semibold", "@juliahub"),
                P(:class => "text-sm", "The Julia Computing platform.")
            )
        )
    )
)
```
"""
function SuiteHoverCard(children...; open_delay::Int=700, close_delay::Int=300, class::String="", kwargs...)
    id = "suite-hover-card-" * string(rand(UInt32), base=16)

    trigger_nodes = []
    content_nodes = []
    for child in children
        if child isa Therapy.VNode && haskey(child.props, Symbol("data-suite-hover-card-trigger-wrapper"))
            push!(trigger_nodes, child)
        else
            push!(content_nodes, child)
        end
    end

    Div(:class => cn(class),
        Symbol("data-suite-hover-card") => id,
        Symbol("data-suite-hover-card-open-delay") => string(open_delay),
        Symbol("data-suite-hover-card-close-delay") => string(close_delay),
        :style => "display:contents",
        kwargs...,
        [_hover_card_set_trigger_id(t, id) for t in trigger_nodes]...,
        content_nodes...,
    )
end

function _hover_card_set_trigger_id(node, id)
    if node isa Therapy.VNode && haskey(node.props, Symbol("data-suite-hover-card-trigger-wrapper"))
        inner_props = copy(node.children[1].props)
        inner_props[Symbol("data-suite-hover-card-trigger")] = id
        inner_props[Symbol("data-state")] = "closed"
        return Therapy.VNode(node.children[1].tag, inner_props, node.children[1].children)
    end
    node
end

"""
    SuiteHoverCardTrigger(children...; class, kwargs...) -> VNode

The element that triggers the hover card on hover.
Typically wraps a link or anchor element.
"""
function SuiteHoverCardTrigger(children...; class::String="", kwargs...)
    Div(Symbol("data-suite-hover-card-trigger-wrapper") => "",
        :style => "display:contents",
        Span(:class => cn(class),
             kwargs...,
             children...))
end

"""
    SuiteHoverCardContent(children...; side, side_offset, align, class, kwargs...) -> VNode

The floating hover card content. Positioned relative to the trigger.

# Arguments
- `side::String="bottom"`: Preferred side ("top", "right", "bottom", "left")
- `side_offset::Int=4`: Distance from anchor in pixels
- `align::String="center"`: Alignment along side ("start", "center", "end")
"""
function SuiteHoverCardContent(children...; side::String="bottom", side_offset::Int=4, align::String="center", theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "bg-warm-50 dark:bg-warm-900 text-warm-800 dark:text-warm-300",
        "data-[state=open]:animate-in data-[state=closed]:animate-out",
        "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
        "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
        "data-[side=bottom]:slide-in-from-top-2",
        "data-[side=left]:slide-in-from-right-2",
        "data-[side=right]:slide-in-from-left-2",
        "data-[side=top]:slide-in-from-bottom-2",
        "z-50 w-64 rounded-md border border-warm-200 dark:border-warm-700",
        "p-4 shadow-md outline-hidden",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-suite-hover-card-content") => "",
        Symbol("data-suite-hover-card-side") => side,
        Symbol("data-suite-hover-card-side-offset") => string(side_offset),
        Symbol("data-suite-hover-card-align") => align,
        Symbol("data-state") => "closed",
        :tabindex => "-1",
        :style => "display:none",
        :class => classes,
        kwargs...,
        children...,
    )
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :HoverCard,
        "HoverCard.jl",
        :js_runtime,
        "Hover-triggered preview card with open/close delay",
        Symbol[],
        [:Floating, :DismissLayer, :HoverCard],
        [:SuiteHoverCard, :SuiteHoverCardTrigger, :SuiteHoverCardContent],
    ))
end
