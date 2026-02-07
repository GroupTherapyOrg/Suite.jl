# Collapsible.jl — Suite.jl Collapsible Component
#
# Tier: js_runtime (requires suite.js for toggle behavior)
# Suite Dependencies: none
# JS Modules: Collapsible
#
# Usage via package: using Suite; Collapsible(...)
# Usage via extract: include("components/Collapsible.jl"); Collapsible(...)
#
# Behavior:
#   - Renders a container with trigger button and collapsible content
#   - JS discovers via data-suite-collapsible attribute
#   - Clicking trigger toggles content visibility
#   - CSS grid-template-rows animation for smooth expand/collapse
#   - ARIA: aria-controls, aria-expanded on trigger; hidden on content
#
# Reference: Radix UI Collapsible — https://www.radix-ui.com/primitives/docs/components/collapsible

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Collapsible, CollapsibleTrigger, CollapsibleContent

"""
    Collapsible(children...; open, disabled, class, kwargs...) -> VNode

A container that can expand/collapse its content.

Requires `suite_script()` in your layout for JS behavior.

# Examples
```julia
Collapsible(
    CollapsibleTrigger("Toggle"),
    CollapsibleContent(
        Div("Hidden content here")
    ),
)

# Initially open
Collapsible(open=true,
    CollapsibleTrigger("Close"),
    CollapsibleContent(Div("Visible content")),
)
```
"""
function Collapsible(children...; open::Bool=false, disabled::Bool=false,
                          class::String="", kwargs...)
    id = "suite-collapsible-" * string(rand(UInt32), base=16)
    state = open ? "open" : "closed"

    attrs = Pair{Symbol,Any}[
        Symbol("data-suite-collapsible") => id,
        Symbol("data-state") => state,
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

Must be a direct child of `Collapsible`.
"""
function CollapsibleTrigger(children...; theme::Symbol=:default,
                                class::String="", kwargs...)
    classes = cn("cursor-pointer text-warm-800 dark:text-warm-300", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-suite-collapsible-trigger") => "",
        Symbol("data-state") => "closed",
        :aria_expanded => "false",
        :class => classes,
        kwargs...,
        children...)
end

"""
    CollapsibleContent(children...; class, kwargs...) -> VNode

The content that is shown/hidden when the collapsible is toggled.

Must be a direct child of `Collapsible`.

Uses CSS grid-template-rows animation for smooth expand/collapse.
"""
function CollapsibleContent(children...; class::String="", force_mount::Bool=false, kwargs...)
    classes = cn("overflow-hidden", class)

    Div(Symbol("data-suite-collapsible-content") => "",
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
        :js_runtime,
        "Expandable/collapsible content container",
        Symbol[],
        [:Collapsible],
        [:Collapsible, :CollapsibleTrigger, :CollapsibleContent],
    ))
end
