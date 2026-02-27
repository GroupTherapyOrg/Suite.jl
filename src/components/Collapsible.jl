# Collapsible.jl — Suite.jl Collapsible Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none
# JS Modules: none
#
# Usage via package: using Suite; Collapsible(...)
# Usage via extract: include("components/Collapsible.jl"); Collapsible(...)
#
# Behavior:
#   - Renders a container with trigger button and collapsible content
#   - Signal-driven: BindBool maps open signal to data-state and aria-expanded
#   - @island Collapsible injects signal bindings into trigger/content children
#   - Content visibility via CSS data-[state=closed]:hidden (no JS hidden toggling)
#   - ARIA: aria-expanded on trigger via BindBool
#
# Reference: Radix UI Collapsible — https://www.radix-ui.com/primitives/docs/components/collapsible

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Collapsible, CollapsibleTrigger, CollapsibleContent

#   Collapsible(children...; open, disabled, class, kwargs...) -> IslandVNode
#
# A container that can expand/collapse its content.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# CollapsibleTrigger and CollapsibleContent children are auto-detected and
# injected with signal bindings for data-state and aria-expanded.
#
# Examples:
#   Collapsible(CollapsibleTrigger("Toggle"), CollapsibleContent(Div("Content")))
#   Collapsible(open=true, CollapsibleTrigger("Close"), CollapsibleContent(Div("Visible")))
@island function Collapsible(children...; open::Bool=false, disabled::Bool=false,
                          class::String="", kwargs...)
    # Signal for open state (Int32: 0=closed, 1=open)
    is_open, set_open = create_signal(Int32(open ? 1 : 0))

    # Walk children to inject signal bindings into trigger/content VNodes
    for child in children
        if child isa VNode
            if haskey(child.props, Symbol("data-collapsible-trigger"))
                # Inject reactive bindings into trigger
                child.props[Symbol("data-state")] = BindBool(is_open, "closed", "open")
                child.props[:aria_expanded] = BindBool(is_open, "false", "true")
                if !disabled
                    child.props[:on_click] = () -> set_open(Int32(1) - is_open())
                end
            elseif haskey(child.props, Symbol("data-collapsible-content"))
                # Inject reactive bindings into content
                child.props[Symbol("data-state")] = BindBool(is_open, "closed", "open")
                # Remove HTML hidden attr — CSS handles visibility via data-state
                delete!(child.props, :hidden)
                # Add CSS class to hide when closed
                current_class = get(child.props, :class, "")
                child.props[:class] = cn(current_class, "data-[state=closed]:hidden")
            end
        end
    end

    attrs = Pair{Symbol,Any}[
        Symbol("data-collapsible") => "",
        Symbol("data-state") => BindBool(is_open, "closed", "open"),
        :class => cn("", class),
    ]
    if disabled
        push!(attrs, Symbol("data-disabled") => "")
    end

    Div(attrs..., kwargs..., children...)
end

"""
    CollapsibleTrigger(children...; class, kwargs...) -> VNode

The button that toggles the collapsible open/closed state.

Must be a direct child of `Collapsible`. The parent @island injects
signal bindings (data-state, aria-expanded, on_click) at render time.
"""
function CollapsibleTrigger(children...; theme::Symbol=:default,
                                class::String="", kwargs...)
    classes = cn("cursor-pointer text-warm-800 dark:text-warm-300", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-collapsible-trigger") => "",
        Symbol("data-state") => "closed",
        :aria_expanded => "false",
        :class => classes,
        kwargs...,
        children...)
end

"""
    CollapsibleContent(children...; class, kwargs...) -> VNode

The content that is shown/hidden when the collapsible is toggled.

Must be a direct child of `Collapsible`. The parent @island injects
signal bindings (data-state) and CSS visibility class at render time.
"""
function CollapsibleContent(children...; class::String="", force_mount::Bool=false, kwargs...)
    classes = cn("overflow-hidden", class)

    Div(Symbol("data-collapsible-content") => "",
        Symbol("data-state") => "closed",
        :hidden => true,
        :class => classes,
        kwargs...,
        children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Collapsible,
        "Collapsible.jl",
        :island,
        "Expandable/collapsible content container",
        Symbol[],
        Symbol[],
        [:Collapsible, :CollapsibleTrigger, :CollapsibleContent],
    ))
end
