# Accordion.jl — Suite.jl Accordion Component
#
# Tier: js_runtime (requires suite.js for toggle + keyboard navigation)
# Suite Dependencies: none (built on Collapsible concepts but independent)
# JS Modules: Accordion
#
# Usage via package: using Suite; Accordion(...)
# Usage via extract: include("components/Accordion.jl"); Accordion(...)
#
# Behavior:
#   - Single mode: one item open at a time, optional collapsible flag
#   - Multiple mode: any combination of items open
#   - Arrow key navigation between triggers (wraps)
#   - Home/End jump to first/last trigger
#   - ARIA: region roles, aria-controls, aria-expanded, aria-labelledby
#
# Reference: Radix UI Accordion — https://www.radix-ui.com/primitives/docs/components/accordion
# Reference: WAI-ARIA Accordion — https://www.w3.org/WAI/ARIA/apg/patterns/accordion/

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Accordion, AccordionItem, AccordionTrigger, AccordionContent

"""
    Accordion(children...; type, collapsible, default_value, orientation, disabled, class, kwargs...) -> VNode

A vertically stacked set of interactive headings that reveal/hide content sections.

Requires `suite_script()` in your layout for JS behavior.

# Props
- `type`: `"single"` (default) or `"multiple"` — single allows one item open, multiple allows any combo
- `collapsible`: `true`/`false` (default `false`) — in single mode, whether the open item can be collapsed
- `default_value`: initial open item(s) — String for single, Vector{String} for multiple
- `orientation`: `"vertical"` (default) or `"horizontal"` — affects arrow key directions
- `disabled`: disable all items

# Examples
```julia
# Single mode (default)
Accordion(
    AccordionItem(value="item-1",
        AccordionTrigger("Section 1"),
        AccordionContent(P("Content for section 1")),
    ),
    AccordionItem(value="item-2",
        AccordionTrigger("Section 2"),
        AccordionContent(P("Content for section 2")),
    ),
)

# Multiple mode, first item open by default
Accordion(type="multiple", default_value=["item-1"],
    AccordionItem(value="item-1",
        AccordionTrigger("Always visible header"),
        AccordionContent(P("Initially open content")),
    ),
)
```
"""
function Accordion(children...; type::String="single", collapsible::Bool=false,
                        default_value=nothing, orientation::String="vertical",
                        disabled::Bool=false, theme::Symbol=:default,
                        class::String="", kwargs...)
    base = "divide-y divide-warm-200 dark:divide-warm-700"
    classes = cn(base, class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    attrs = Pair{Symbol,Any}[
        Symbol("data-suite-accordion") => type,
        Symbol("data-orientation") => orientation,
        :class => classes,
    ]
    if collapsible
        push!(attrs, Symbol("data-collapsible") => "")
    end
    if disabled
        push!(attrs, Symbol("data-disabled") => "")
    end

    # Compute which items are initially open
    open_values = Set{String}()
    if default_value !== nothing
        if default_value isa AbstractString
            push!(open_values, default_value)
        elseif default_value isa AbstractVector
            for v in default_value
                push!(open_values, string(v))
            end
        end
    end

    # Tag children with initial open state via a wrapper that injects data attributes
    # We pass the open_values set as a custom attribute the JS can read
    if !isempty(open_values)
        push!(attrs, Symbol("data-default-value") => join(open_values, ","))
    end

    Div(attrs..., kwargs..., children...)
end

"""
    AccordionItem(children...; value, disabled, class, kwargs...) -> VNode

A single accordion item containing a trigger and content.

# Props
- `value`: unique identifier for this item (required)
- `disabled`: disable this specific item
"""
function AccordionItem(children...; value::String="", disabled::Bool=false,
                            class::String="", kwargs...)
    classes = cn("", class)

    attrs = Pair{Symbol,Any}[
        Symbol("data-suite-accordion-item") => value,
        Symbol("data-state") => "closed",
        :class => classes,
    ]
    if disabled
        push!(attrs, Symbol("data-disabled") => "")
    end

    Div(attrs..., kwargs..., children...)
end

"""
    AccordionTrigger(children...; class, kwargs...) -> VNode

The button that toggles an accordion item open/closed.

Rendered as a heading (h3) containing a button, matching Radix/shadcn structure.
Includes a chevron indicator that rotates on open.
"""
function AccordionTrigger(children...; theme::Symbol=:default,
                               class::String="", kwargs...)
    base = "flex flex-1 items-center justify-between py-4 cursor-pointer text-sm font-medium transition-all hover:underline [&[data-state=open]>svg]:rotate-180"
    classes = cn(base, class)
    chevron_classes = "h-4 w-4 shrink-0 text-warm-600 dark:text-warm-500 transition-transform duration-200"
    if theme !== :default
        t = get_theme(theme)
        classes = apply_theme(classes, t)
        chevron_classes = apply_theme(chevron_classes, t)
    end

    # Chevron SVG icon
    chevron = Svg(:class => chevron_classes,
                  :fill => "none", :viewBox => "0 0 24 24", :stroke => "currentColor", :stroke_width => "2",
                  Path(:d => "M6 9l6 6 6-6"))

    H3(:class => "flex",
        Therapy.Button(:type => "button",
               Symbol("data-suite-accordion-trigger") => "",
               Symbol("data-state") => "closed",
               :aria_expanded => "false",
               :class => classes,
               kwargs...,
               children...,
               chevron))
end

"""
    AccordionContent(children...; class, kwargs...) -> VNode

The content panel revealed when an accordion item is opened.

Has `role="region"` and is labelled by its trigger for accessibility.
"""
function AccordionContent(children...; class::String="", kwargs...)
    base = "overflow-hidden text-sm"
    inner_class = "pb-4 pt-0"
    classes = cn(base, class)

    Div(Symbol("data-suite-accordion-content") => "",
        Symbol("data-state") => "closed",
        :role => "region",
        :hidden => true,
        :class => classes,
        kwargs...,
        Div(:class => inner_class, children...))
end

# --- Initial state script ---
# This inline script runs after the accordion is rendered to set initial open items
# Based on data-default-value attribute on the root

"""
    suite_accordion_init_script() -> VNode

Optional inline script to initialize accordion default values.
Call this after your accordion HTML if you need items open by default.
The suite.js Accordion.init() handles this automatically.
"""
function suite_accordion_init_script()
    Therapy.Script("""
    (function(){
        document.querySelectorAll('[data-suite-accordion][data-default-value]').forEach(function(root) {
            if (root._suiteAccordionDefaultApplied) return;
            root._suiteAccordionDefaultApplied = true;
            var vals = root.getAttribute('data-default-value').split(',');
            vals.forEach(function(v) {
                var item = root.querySelector('[data-suite-accordion-item="' + v + '"]');
                if (!item) return;
                item.setAttribute('data-state', 'open');
                var trigger = item.querySelector('[data-suite-accordion-trigger]');
                if (trigger) {
                    trigger.setAttribute('data-state', 'open');
                    trigger.setAttribute('aria-expanded', 'true');
                }
                var content = item.querySelector('[data-suite-accordion-content]');
                if (content) {
                    content.setAttribute('data-state', 'open');
                    content.hidden = false;
                }
            });
        });
    })();
    """)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Accordion,
        "Accordion.jl",
        :js_runtime,
        "Vertically stacked expandable sections with keyboard navigation",
        Symbol[],
        [:Accordion],
        [:Accordion, :AccordionItem, :AccordionTrigger, :AccordionContent],
    ))
end
