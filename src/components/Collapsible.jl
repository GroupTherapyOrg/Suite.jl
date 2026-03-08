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
#   - Signal-driven: ShowDescendants maps open signal to visibility
#   - @island Collapsible injects signal bindings into trigger/content children
#   - Content visibility via display:none (ShowDescendants toggles)
#   - ARIA: aria-expanded on trigger via BindBool
#
# Reference: Radix UI Collapsible — https://www.radix-ui.com/primitives/docs/components/collapsible

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Collapsible, CollapsibleTrigger, CollapsibleContent

# SSR helper: set initial state for open=true collapsibles.
# Walks children to set CollapsibleContent visible and CollapsibleTrigger state.
function _collapsible_ssr_setup!(children, open::Bool)
    open || return
    for child in children
        # CollapsibleTrigger is an IslandVNode — inject _o prop and fix trigger attrs
        if child isa Therapy.IslandVNode && child.name == :CollapsibleTrigger
            child.props[:_o] = 1
            _collapsible_set_trigger_open!(child.content)
        end
        # CollapsibleContent is a regular VNode
        if child isa VNode && haskey(child.props, Symbol("data-collapsible-content"))
            child.props[Symbol("data-state")] = "open"
        end
    end
end

function _collapsible_set_trigger_open!(node)
    node isa VNode || return
    if haskey(node.props, Symbol("data-collapsible-trigger"))
        node.props[Symbol("data-state")] = "open"
        node.props[:aria_expanded] = "true"
    end
    for c in node.children
        _collapsible_set_trigger_open!(c)
    end
end

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
    # Compilable: signal from prop _o (index 0, alphabetically sorted)
    is_open, set_open = create_signal(compiled_get_prop_i32(Int32(0)))

    # Provide context for child islands
    provide_context(:collapsible, (is_open, set_open))

    # SSR: set initial state for open=true
    _collapsible_ssr_setup!(children, open)

    Div(Symbol("data-show") => ShowDescendants(is_open),
        Symbol("data-collapsible") => "",
        Symbol("data-state") => open ? "open" : "closed",
        (disabled ? (Symbol("data-disabled") => "",) : ())...,
        :class => cn(disabled ? "pointer-events-none" : "", class),
        kwargs...,
        children...)
end

#   CollapsibleTrigger(children...; class, kwargs...) -> IslandVNode
#
# The button that toggles the collapsible open/closed state.
# Child island: signal initialized from _o prop (set by parent SSR setup).
@island function CollapsibleTrigger(children...; theme::Symbol=:default,
                                class::String="", kwargs...)
    # Compilable: signal from prop _o (index 0)
    is_open, set_open = create_signal(compiled_get_prop_i32(Int32(0)))

    classes = cn("cursor-pointer text-warm-800 dark:text-warm-300", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-collapsible-trigger") => "",
        Symbol("data-state") => BindBool(is_open, "closed", "open"),
        :aria_expanded => BindBool(is_open, "false", "true"),
        :on_click => () -> set_open(Int32(1) - is_open()),
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
    classes = cn("overflow-hidden data-[state=closed]:hidden", class)

    Div(Symbol("data-collapsible-content") => "",
        Symbol("data-state") => "closed",
        :class => classes,
        kwargs...,
        children...)
end

# --- Hydration Support ---

const _COLLAPSIBLE_PROPS_TRANSFORM = (props, args) -> begin
    props[:_o] = get(props, :open, false) ? 1 : 0
end

const _COLLAPSIBLETRIGGER_PROPS_TRANSFORM = (props, args) -> begin
    props[:_o] = get(props, :_o, 0)
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
