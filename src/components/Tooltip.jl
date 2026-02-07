# SuiteTooltip.jl — Suite.jl Tooltip Component
#
# Tier: js_runtime (requires suite.js)
# Suite Dependencies: none (leaf component)
# JS Modules: Floating, DismissLayer, Tooltip
#
# Usage via package: using Suite; SuiteTooltip(...)
# Usage via extract: include("components/Tooltip.jl"); SuiteTooltip(...)
#
# Behavior (matches Radix Tooltip):
#   - Hover/focus-triggered informational popup
#   - Provider-level delay state machine (700ms open, 300ms skip)
#   - Escape key dismisses
#   - No focus trap (tooltip content is not interactive)
#   - Touch events ignored
#   - aria-describedby wiring for accessibility
#   - Grace area keeps tooltip open while pointer transits to content

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteTooltipProvider, SuiteTooltip, SuiteTooltipTrigger, SuiteTooltipContent

"""
    SuiteTooltipProvider(children...; delay_duration, skip_delay_duration, kwargs...) -> VNode

Provider that manages tooltip delay state. Wrap around a group of tooltips
for coordinated delay behavior (instant-open for quick succession).

# Arguments
- `delay_duration::Int=700`: Milliseconds before tooltip opens on hover
- `skip_delay_duration::Int=300`: Milliseconds window for instant-open after close
"""
function SuiteTooltipProvider(children...; delay_duration::Int=700, skip_delay_duration::Int=300, class::String="", kwargs...)
    Div(Symbol("data-suite-tooltip-provider") => "",
        Symbol("data-suite-tooltip-delay") => string(delay_duration),
        Symbol("data-suite-tooltip-skip-delay") => string(skip_delay_duration),
        :class => cn(class),
        :style => "display:contents",
        kwargs...,
        children...)
end

"""
    SuiteTooltip(children...; class, kwargs...) -> VNode

A hover/focus-triggered informational popup.

# Examples
```julia
SuiteTooltipProvider(
    SuiteTooltip(
        SuiteTooltipTrigger(SuiteButton(variant="outline", "Hover me")),
        SuiteTooltipContent(P("Tooltip text"))
    )
)
```
"""
function SuiteTooltip(children...; class::String="", kwargs...)
    id = "suite-tooltip-" * string(rand(UInt32), base=16)

    trigger_nodes = []
    content_nodes = []
    for child in children
        if child isa Therapy.VNode && haskey(child.props, Symbol("data-suite-tooltip-trigger-wrapper"))
            push!(trigger_nodes, child)
        else
            push!(content_nodes, child)
        end
    end

    Div(:class => cn(class),
        Symbol("data-suite-tooltip") => id,
        :style => "display:contents",
        kwargs...,
        [_tooltip_set_trigger_id(t, id) for t in trigger_nodes]...,
        content_nodes...,
    )
end

function _tooltip_set_trigger_id(node, id)
    if node isa Therapy.VNode && haskey(node.props, Symbol("data-suite-tooltip-trigger-wrapper"))
        inner_props = copy(node.children[1].props)
        inner_props[Symbol("data-suite-tooltip-trigger")] = id
        inner_props[Symbol("data-state")] = "closed"
        return Therapy.VNode(node.children[1].tag, inner_props, node.children[1].children)
    end
    node
end

"""
    SuiteTooltipTrigger(children...; class, kwargs...) -> VNode

The element that triggers the tooltip on hover/focus.
"""
function SuiteTooltipTrigger(children...; class::String="", kwargs...)
    Div(Symbol("data-suite-tooltip-trigger-wrapper") => "",
        :style => "display:contents",
        Button(:type => "button",
               :class => cn(class),
               kwargs...,
               children...))
end

"""
    SuiteTooltipContent(children...; side, side_offset, align, class, kwargs...) -> VNode

The tooltip content popup. Positioned relative to the trigger.

# Arguments
- `side::String="top"`: Preferred side ("top", "right", "bottom", "left")
- `side_offset::Int=4`: Distance from anchor in pixels
- `align::String="center"`: Alignment along side ("start", "center", "end")
"""
function SuiteTooltipContent(children...; side::String="top", side_offset::Int=4, align::String="center", theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "bg-warm-800 dark:bg-warm-300 text-warm-50 dark:text-warm-950",
        "animate-in fade-in-0 zoom-in-95",
        "data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95",
        "data-[side=bottom]:slide-in-from-top-2",
        "data-[side=left]:slide-in-from-right-2",
        "data-[side=right]:slide-in-from-left-2",
        "data-[side=top]:slide-in-from-bottom-2",
        "z-50 w-fit px-3 py-1.5 rounded-md text-xs text-balance",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-suite-tooltip-content") => "",
        Symbol("data-suite-tooltip-side") => side,
        Symbol("data-suite-tooltip-side-offset") => string(side_offset),
        Symbol("data-suite-tooltip-align") => align,
        Symbol("data-state") => "closed",
        :role => "tooltip",
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
        :Tooltip,
        "Tooltip.jl",
        :js_runtime,
        "Hover/focus-triggered informational popup with delay state machine",
        Symbol[],
        [:Floating, :DismissLayer, :Tooltip],
        [:SuiteTooltipProvider, :SuiteTooltip, :SuiteTooltipTrigger, :SuiteTooltipContent],
    ))
end
