# Popover.jl — Suite.jl Popover Component
#
# Tier: js_runtime (requires suite.js)
# Suite Dependencies: none (leaf component)
# JS Modules: Floating, FocusGuards, FocusTrap, DismissLayer, ScrollLock, Popover
#
# Usage via package: using Suite; Popover(...)
# Usage via extract: include("components/Popover.jl"); Popover(...)
#
# Behavior (matches Radix Popover):
#   - Click-triggered floating panel
#   - Modal by default: focus trapped, scroll locked
#   - Escape key dismisses
#   - Click outside dismisses
#   - Positioned relative to trigger using Floating positioning
#   - Supports side/align/offset configuration

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Popover, PopoverTrigger, PopoverContent,
       PopoverClose, PopoverAnchor

"""
    Popover(children...; class, kwargs...) -> VNode

A click-triggered floating panel. Contains trigger and floating content.

# Examples
```julia
Popover(
    PopoverTrigger(Button(variant="outline", "Open")),
    PopoverContent(
        P("Place content for the popover here.")
    )
)
```
"""
function Popover(children...; class::String="", kwargs...)
    id = "suite-popover-" * string(rand(UInt32), base=16)

    trigger_nodes = []
    content_nodes = []
    for child in children
        if child isa Therapy.VNode && haskey(child.props, Symbol("data-suite-popover-trigger-wrapper"))
            push!(trigger_nodes, child)
        else
            push!(content_nodes, child)
        end
    end

    Div(:class => cn(class),
        Symbol("data-suite-popover") => id,
        :style => "display:contents",
        kwargs...,
        [_popover_set_trigger_id(t, id) for t in trigger_nodes]...,
        content_nodes...,
    )
end

function _popover_set_trigger_id(node, id)
    if node isa Therapy.VNode && haskey(node.props, Symbol("data-suite-popover-trigger-wrapper"))
        new_props = copy(node.props)
        new_props[Symbol("data-suite-popover-trigger")] = id
        new_props[Symbol("aria-haspopup")] = "dialog"
        new_props[Symbol("aria-expanded")] = "false"
        new_props[Symbol("data-state")] = "closed"
        return Therapy.VNode(node.tag, new_props, node.children)
    end
    node
end

"""
    PopoverTrigger(children...; class, kwargs...) -> VNode

The button that opens the popover.
"""
function PopoverTrigger(children...; class::String="", kwargs...)
    Span(Symbol("data-suite-popover-trigger-wrapper") => "",
         :style => "display:contents",
         :class => cn("cursor-pointer", class),
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
        :js_runtime,
        "Click-triggered floating panel with focus trap and positioning",
        Symbol[],
        [:Floating, :FocusGuards, :FocusTrap, :DismissLayer, :ScrollLock, :Popover],
        [:Popover, :PopoverTrigger, :PopoverContent,
         :PopoverClose, :PopoverAnchor],
    ))
end
