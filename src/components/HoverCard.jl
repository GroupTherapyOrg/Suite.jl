# HoverCard.jl — Suite.jl HoverCard Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; HoverCard(...)
# Usage via extract: include("components/HoverCard.jl"); HoverCard(...)
#
# Behavior (matches Radix HoverCard):
#   - Hover-triggered preview card for links/anchors
#   - Open delay 700ms, close delay 300ms (configurable)
#   - Hovering content keeps card open (cancels close timer)
#   - Escape key dismisses, click outside dismisses
#   - No focus trap (preview content, not interactive)
#   - Floating positioning with flip/shift collision avoidance
#   - Signal-driven: BindModal(mode=5) handles hover timing + floating positioning

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export HoverCard, HoverCardTrigger, HoverCardContent

#   HoverCard(children...; open_delay, close_delay, class, kwargs...) -> IslandVNode
#
# A hover-triggered preview card. Shows rich content when hovering a trigger.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# BindModal(mode=5) handles hover timing (delayed open + delayed close),
# floating positioning, content hover (cancel close), Escape + click-outside dismiss.
#
# Arguments:
# - open_delay::Int=700: Milliseconds before card opens on hover
# - close_delay::Int=300: Milliseconds before card closes after leaving
#
# Examples:
#   HoverCard(HoverCardTrigger(A(:href => "#", "@user")), HoverCardContent(P("Bio")))
@island function HoverCard(children...; open_delay::Int=700, close_delay::Int=300, class::String="", kwargs...)
    # Signal for open state (Int32: 0=closed, 1=open)
    is_open, set_open = create_signal(Int32(0))

    # Walk children to inject hover handlers on trigger wrapper
    for child in children
        if child isa VNode && haskey(child.props, Symbol("data-suite-hover-card-trigger-wrapper"))
            # Trigger wrapper: hover events toggle the signal
            child.props[:on_pointerenter] = () -> set_open(Int32(1))
            child.props[:on_pointerleave] = () -> set_open(Int32(0))
            child.props[Symbol("data-state")] = "closed"
        end
    end

    Div(Symbol("data-modal") => BindModal(is_open, Int32(5)),  # mode 5 = hover_card (hover + floating + dismiss)
        Symbol("data-suite-hover-card-open-delay") => string(open_delay),
        Symbol("data-suite-hover-card-close-delay") => string(close_delay),
        :class => cn("", class),
        :style => "display:contents",
        kwargs...,
        children...)
end

"""
    HoverCardTrigger(children...; class, kwargs...) -> VNode

The element that triggers the hover card on hover.
Typically wraps a link or anchor element.
"""
function HoverCardTrigger(children...; class::String="", kwargs...)
    Span(Symbol("data-suite-hover-card-trigger-wrapper") => "",
         :style => "display:contents",
         :class => cn("cursor-pointer", class),
         kwargs...,
         children...)
end

"""
    HoverCardContent(children...; side, side_offset, align, class, kwargs...) -> VNode

The floating hover card content. Positioned relative to the trigger.

# Arguments
- `side::String="bottom"`: Preferred side ("top", "right", "bottom", "left")
- `side_offset::Int=4`: Distance from anchor in pixels
- `align::String="center"`: Alignment along side ("start", "center", "end")
"""
function HoverCardContent(children...; side::String="bottom", side_offset::Int=4, align::String="center", theme::Symbol=:default, class::String="", kwargs...)
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
        :island,
        "Hover-triggered preview card with open/close delay",
        Symbol[],
        Symbol[],
        [:HoverCard, :HoverCardTrigger, :HoverCardContent],
    ))
end
