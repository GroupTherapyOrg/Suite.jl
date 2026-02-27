# Popover.jl — Suite.jl Popover Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Popover(...)
# Usage via extract: include("components/Popover.jl"); Popover(...)
#
# Behavior (matches Radix Popover):
#   - Click-triggered floating panel
#   - Modal by default: focus trapped, scroll locked
#   - Escape key dismisses
#   - Click outside dismisses
#   - Positioned relative to trigger using floating positioning (Wasm)
#   - Supports side/align/offset configuration
#   - Signal-driven: BindBool maps open signal to data-state and aria-expanded
#   - BindModal(mode=3) handles modal behavior + floating positioning

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Popover, PopoverTrigger, PopoverContent,
       PopoverClose, PopoverAnchor

#   Popover(children...; class, kwargs...) -> IslandVNode
#
# A click-triggered floating panel. Contains trigger and floating content.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# PopoverTrigger and PopoverContent children are auto-detected and injected
# with signal bindings for data-state, aria-expanded, and modal+floating behavior.
#
# Examples:
#   Popover(PopoverTrigger(Button(variant="outline", "Open")), PopoverContent(P("Content")))
@island function Popover(children...; class::String="", kwargs...)
    # Signal for open state (Int32: 0=closed, 1=open)
    is_open, set_open = create_signal(Int32(0))

    # Walk children to inject signal bindings
    for child in children
        if child isa VNode
            if haskey(child.props, Symbol("data-suite-popover-trigger-wrapper"))
                # Inject reactive bindings on trigger wrapper
                child.props[Symbol("data-state")] = BindBool(is_open, "closed", "open")
                child.props[:aria_expanded] = BindBool(is_open, "false", "true")
                child.props[:on_click] = () -> set_open(Int32(1) - is_open())
            else
                # Content or other children — walk into them for content + close buttons
                _popover_inject_content_bindings!(child, is_open, set_open)
            end
        end
    end

    Div(Symbol("data-modal") => BindModal(is_open, Int32(3)),  # mode 3 = popover (dialog + floating)
        :class => cn("", class),
        :style => "display:contents",
        kwargs...,
        children...)
end

# Walk children to find popover content and close buttons
function _popover_inject_content_bindings!(node::VNode, is_open, set_open)
    if haskey(node.props, Symbol("data-suite-popover-content"))
        # Content: bind data-state
        node.props[Symbol("data-state")] = BindBool(is_open, "closed", "open")
        # Walk content for close buttons
        _popover_inject_close_buttons!(node, set_open)
    end
    for child in node.children
        if child isa VNode
            _popover_inject_content_bindings!(child, is_open, set_open)
        end
    end
end

# Recursively inject close handler on all [data-suite-popover-close] elements
function _popover_inject_close_buttons!(node::VNode, set_open)
    if haskey(node.props, Symbol("data-suite-popover-close"))
        node.props[:on_click] = () -> set_open(Int32(0))
    end
    for child in node.children
        if child isa VNode
            _popover_inject_close_buttons!(child, set_open)
        end
    end
end

"""
    PopoverTrigger(children...; class, kwargs...) -> VNode

The button that opens the popover.
"""
function PopoverTrigger(children...; class::String="", kwargs...)
    Span(Symbol("data-suite-popover-trigger-wrapper") => "",
         :style => "display:contents",
         :class => cn("cursor-pointer", class),
         Symbol("data-state") => "closed",
         :aria_haspopup => "dialog",
         :aria_expanded => "false",
         kwargs...,
         children...)
end

"""
    PopoverContent(children...; side, side_offset, align, class, kwargs...) -> VNode

The floating content panel. Positioned relative to the trigger.

# Arguments
- `side::String="bottom"`: Preferred side ("top", "right", "bottom", "left")
- `side_offset::Int=0`: Distance from anchor in pixels
- `align::String="center"`: Alignment along side ("start", "center", "end")
"""
function PopoverContent(children...; side::String="bottom", side_offset::Int=0, align::String="center", theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "glass-panel",
        "bg-warm-50 dark:bg-warm-900 text-warm-800 dark:text-warm-300",
        "data-[state=open]:animate-in data-[state=closed]:animate-out",
        "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
        "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
        "data-[side=bottom]:slide-in-from-top-2",
        "data-[side=left]:slide-in-from-right-2",
        "data-[side=right]:slide-in-from-left-2",
        "data-[side=top]:slide-in-from-bottom-2",
        "z-50 w-72 rounded-md border border-warm-200 dark:border-warm-700",
        "p-4 shadow-md outline-hidden",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-suite-popover-content") => "",
        Symbol("data-suite-popover-side") => side,
        Symbol("data-suite-popover-side-offset") => string(side_offset),
        Symbol("data-suite-popover-align") => align,
        Symbol("data-state") => "closed",
        :role => "dialog",
        :aria_modal => "true",
        :tabindex => "-1",
        :style => "display:none",
        :class => classes,
        kwargs...,
        children...,
    )
end

"""
    PopoverClose(children...; class, kwargs...) -> VNode

A button that closes the popover when clicked.
"""
function PopoverClose(children...; class::String="", kwargs...)
    Span(Symbol("data-suite-popover-close") => "",
         :class => cn(class),
         :style => "display:contents",
         kwargs...,
         children...)
end

"""
    PopoverAnchor(children...; class, kwargs...) -> VNode

Optional custom anchor element. When used, the popover positions relative
to this element instead of the trigger.
"""
function PopoverAnchor(children...; class::String="", kwargs...)
    Div(Symbol("data-suite-popover-anchor") => "",
        :class => cn(class),
        kwargs...,
        children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Popover,
        "Popover.jl",
        :island,
        "Click-triggered floating panel with focus trap and positioning",
        Symbol[],
        Symbol[],
        [:Popover, :PopoverTrigger, :PopoverContent,
         :PopoverClose, :PopoverAnchor],
    ))
end
