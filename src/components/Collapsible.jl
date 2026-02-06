# SuiteCollapsible.jl — Suite.jl Collapsible Component
#
# Tier: js_runtime (requires suite.js for toggle behavior)
# Suite Dependencies: none
# JS Modules: Collapsible
#
# Usage via package: using Suite; SuiteCollapsible(...)
# Usage via extract: include("components/Collapsible.jl"); SuiteCollapsible(...)
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

export SuiteCollapsible, SuiteCollapsibleTrigger, SuiteCollapsibleContent

"""
    SuiteCollapsible(children...; open, disabled, class, kwargs...) -> VNode

A container that can expand/collapse its content.

Requires `suite_script()` in your layout for JS behavior.

# Examples
```julia
SuiteCollapsible(
    SuiteCollapsibleTrigger("Toggle"),
    SuiteCollapsibleContent(
        Div("Hidden content here")
    ),
)

# Initially open
SuiteCollapsible(open=true,
    SuiteCollapsibleTrigger("Close"),
    SuiteCollapsibleContent(Div("Visible content")),
)
```
"""
function SuiteCollapsible(children...; open::Bool=false, disabled::Bool=false,
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
    SuiteCollapsibleTrigger(children...; class, kwargs...) -> VNode

The button that toggles the collapsible open/closed state.

Must be a direct child of `SuiteCollapsible`.
"""
function SuiteCollapsibleTrigger(children...; class::String="", kwargs...)
    base = "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50"
    classes = cn(base, class)

    Button(:type => "button",
           Symbol("data-suite-collapsible-trigger") => "",
           Symbol("data-state") => "closed",
           :aria_expanded => "false",
           :class => classes,
           kwargs...,
           children...)
end

"""
    SuiteCollapsibleContent(children...; class, kwargs...) -> VNode

The content that is shown/hidden when the collapsible is toggled.

Must be a direct child of `SuiteCollapsible`.

Uses CSS grid-template-rows animation for smooth expand/collapse.
"""
function SuiteCollapsibleContent(children...; class::String="", force_mount::Bool=false, kwargs...)
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
        [:SuiteCollapsible, :SuiteCollapsibleTrigger, :SuiteCollapsibleContent],
    ))
end
