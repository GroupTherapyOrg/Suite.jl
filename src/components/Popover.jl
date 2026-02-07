# SuitePopover.jl — Suite.jl Popover Component
#
# Tier: js_runtime (requires suite.js)
# Suite Dependencies: none (leaf component)
# JS Modules: Floating, FocusGuards, FocusTrap, DismissLayer, ScrollLock, Popover
#
# Usage via package: using Suite; SuitePopover(...)
# Usage via extract: include("components/Popover.jl"); SuitePopover(...)
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

export SuitePopover, SuitePopoverTrigger, SuitePopoverContent,
       SuitePopoverClose, SuitePopoverAnchor

"""
    SuitePopover(children...; class, kwargs...) -> VNode

A click-triggered floating panel. Contains trigger and floating content.

# Examples
```julia
SuitePopover(
    SuitePopoverTrigger(SuiteButton(variant="outline", "Open")),
    SuitePopoverContent(
        P("Place content for the popover here.")
    )
)
```
"""
function SuitePopover(children...; class::String="", kwargs...)
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
        inner_props = copy(node.children[1].props)
        inner_props[Symbol("data-suite-popover-trigger")] = id
        inner_props[Symbol("aria-haspopup")] = "dialog"
        inner_props[Symbol("aria-expanded")] = "false"
        inner_props[Symbol("data-state")] = "closed"
        return Therapy.VNode(node.children[1].tag, inner_props, node.children[1].children)
    end
    node
end

"""
    SuitePopoverTrigger(children...; class, kwargs...) -> VNode

The button that opens the popover.
"""
function SuitePopoverTrigger(children...; class::String="", kwargs...)
    Div(Symbol("data-suite-popover-trigger-wrapper") => "",
        :style => "display:contents",
        Button(:type => "button",
               :class => cn(class),
               kwargs...,
               children...))
end

"""
    SuitePopoverContent(children...; side, side_offset, align, class, kwargs...) -> VNode

The floating content panel. Positioned relative to the trigger.

# Arguments
- `side::String="bottom"`: Preferred side ("top", "right", "bottom", "left")
- `side_offset::Int=0`: Distance from anchor in pixels
- `align::String="center"`: Alignment along side ("start", "center", "end")
"""
function SuitePopoverContent(children...; side::String="bottom", side_offset::Int=0, align::String="center", theme::Symbol=:default, class::String="", kwargs...)
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
    SuitePopoverClose(children...; class, kwargs...) -> VNode

A button that closes the popover when clicked.
"""
function SuitePopoverClose(children...; class::String="", kwargs...)
    Span(Symbol("data-suite-popover-close") => "",
         :class => cn(class),
         :style => "display:contents",
         kwargs...,
         children...)
end

"""
    SuitePopoverAnchor(children...; class, kwargs...) -> VNode

Optional custom anchor element. When used, the popover positions relative
to this element instead of the trigger.
"""
function SuitePopoverAnchor(children...; class::String="", kwargs...)
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
        [:SuitePopover, :SuitePopoverTrigger, :SuitePopoverContent,
         :SuitePopoverClose, :SuitePopoverAnchor],
    ))
end
