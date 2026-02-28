# Accordion.jl — Suite.jl Accordion Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (built on Collapsible concepts but independent)
# JS Modules: none
#
# Usage via package: using Suite; Accordion(...)
# Usage via extract: include("components/Accordion.jl"); Accordion(...)
#
# Behavior:
#   - Single mode: one item open at a time, optional collapsible flag
#   - Multiple mode: any combination of items open
#   - Signal-driven: BindBool maps open signals to data-state and aria-expanded
#   - @island Accordion injects signal bindings into AccordionItem children
#   - Content visibility via CSS data-[state=closed]:hidden (no JS hidden toggling)
#   - ARIA: region roles, aria-expanded on trigger via BindBool
#
# Reference: Radix UI Accordion — https://www.radix-ui.com/primitives/docs/components/accordion
# Reference: WAI-ARIA Accordion — https://www.w3.org/WAI/ARIA/apg/patterns/accordion/

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Accordion, AccordionItem, AccordionTrigger, AccordionContent

#   Accordion(children...; type, collapsible, default_value, orientation, disabled, class, kwargs...) -> IslandVNode
#
# A vertically stacked set of interactive headings that reveal/hide content sections.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# AccordionItem children are auto-detected and injected with signal bindings for
# data-state, aria-expanded, and click handlers for toggle coordination.
#
# Props:
#   type: "single" (default) or "multiple"
#   collapsible: whether the open item can be collapsed in single mode
#   default_value: initial open item(s) — String for single, Vector{String} for multiple
#   orientation: "vertical" (default) or "horizontal"
#   disabled: disable all items
#
# Examples:
#   Accordion(AccordionItem(value="item-1", AccordionTrigger("Section 1"), AccordionContent(P("Content"))))
#   Accordion(type="multiple", default_value=["item-1"], AccordionItem(value="item-1", ...))
@island function Accordion(children...; type::String="single", collapsible::Bool=false,
                        default_value=nothing, orientation::String="vertical",
                        disabled::Bool=false, theme::Symbol=:default,
                        class::String="", kwargs...)
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

    # Collect item signals for single-mode coordination
    # Each tuple: (getter, setter)
    item_signals = Tuple{Any, Any}[]

    # Walk children to find AccordionItem VNodes and inject signal bindings
    for child in children
        if child isa VNode && haskey(child.props, Symbol("data-accordion-item"))
            item_value = string(child.props[Symbol("data-accordion-item")])
            is_initially_open = item_value in open_values

            # Create signal for this item's open/closed state (Int32: 0=closed, 1=open)
            item_open, set_item_open = create_signal(Int32(is_initially_open ? 1 : 0))
            push!(item_signals, (item_open, set_item_open))
            item_idx = length(item_signals)

            # Inject BindBool on the AccordionItem root
            child.props[Symbol("data-state")] = BindBool(item_open, "closed", "open")

            # Walk item's children for trigger (H3 > Button) and content
            for subchild in child.children
                if subchild isa VNode
                    if subchild.tag == :h3
                        # H3 wrapper — look inside for the trigger button
                        for btn in subchild.children
                            if btn isa VNode && haskey(btn.props, Symbol("data-accordion-trigger"))
                                # Inject reactive bindings on trigger
                                btn.props[Symbol("data-state")] = BindBool(item_open, "closed", "open")
                                btn.props[:aria_expanded] = BindBool(item_open, "false", "true")
                                btn.props[Symbol("data-index")] = string(item_idx - 1)  # 0-indexed for hydration
                                # Inject click handler (unless disabled)
                                item_is_disabled = haskey(child.props, Symbol("data-disabled"))
                                if !disabled && !item_is_disabled
                                    let all_sigs = item_signals, my_get = item_open, my_set = set_item_open, my_idx = item_idx
                                        btn.props[:on_click] = function()
                                            current = my_get()
                                            if type == "single"
                                                if current == Int32(1)
                                                    # This item is open — collapse if allowed
                                                    if collapsible
                                                        my_set(Int32(0))
                                                    end
                                                else
                                                    # Close all others, open this one
                                                    for (j, (_, setter)) in enumerate(all_sigs)
                                                        if j != my_idx
                                                            setter(Int32(0))
                                                        end
                                                    end
                                                    my_set(Int32(1))
                                                end
                                            else
                                                # Multiple mode — toggle
                                                my_set(Int32(1) - current)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    elseif haskey(subchild.props, Symbol("data-accordion-content"))
                        # Inject reactive bindings on content
                        subchild.props[Symbol("data-state")] = BindBool(item_open, "closed", "open")
                        # Remove HTML hidden attr — CSS handles visibility via data-state
                        delete!(subchild.props, :hidden)
                        # Add CSS class to hide when closed
                        current_class = get(subchild.props, :class, "")
                        subchild.props[:class] = cn(current_class, "data-[state=closed]:hidden")
                    end
                end
            end
        end
    end

    base = "divide-y divide-warm-200 dark:divide-warm-700"
    classes = cn(base, class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    attrs = Pair{Symbol,Any}[
        Symbol("data-accordion") => type,
        Symbol("data-orientation") => orientation,
        :class => classes,
    ]
    if collapsible
        push!(attrs, Symbol("data-collapsible") => "")
    end
    if disabled
        push!(attrs, Symbol("data-disabled") => "")
    end

    Div(attrs..., kwargs..., children...)
end

"""
    AccordionItem(children...; value, disabled, class, kwargs...) -> VNode

A single accordion item containing a trigger and content.

Must be a direct child of `Accordion`. The parent @island injects
signal bindings (data-state) at render time.

# Props
- `value`: unique identifier for this item (required)
- `disabled`: disable this specific item
"""
function AccordionItem(children...; value::String="", disabled::Bool=false,
                            class::String="", kwargs...)
    classes = cn("", class)

    attrs = Pair{Symbol,Any}[
        Symbol("data-accordion-item") => value,
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

Must be a child of `AccordionItem` inside an `Accordion`. The parent @island
injects signal bindings (data-state, aria-expanded, on_click) at render time.

Rendered as a heading (h3) containing a button, matching Radix/shadcn structure.
Includes a chevron indicator that rotates on open.
"""
function AccordionTrigger(children...; theme::Symbol=:default,
                               class::String="", kwargs...)
    base = "flex flex-1 items-center justify-between py-4 cursor-pointer text-sm font-medium text-warm-800 dark:text-warm-300 transition-all hover:underline [&[data-state=open]>svg]:rotate-180"
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
               Symbol("data-accordion-trigger") => "",
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

Must be a child of `AccordionItem` inside an `Accordion`. The parent @island
injects signal bindings (data-state) and CSS visibility class at render time.

Has `role="region"` and is labelled by its trigger for accessibility.
"""
function AccordionContent(children...; class::String="", kwargs...)
    base = "overflow-hidden text-sm"
    inner_class = "pb-4 pt-0"
    classes = cn(base, class)

    Div(Symbol("data-accordion-content") => "",
        Symbol("data-state") => "closed",
        :role => "region",
        :hidden => true,
        :class => classes,
        kwargs...,
        Div(:class => inner_class, children...))
end

# --- Hydration Support ---

const _ACCORDION_PROPS_TRANSFORM = (props, args) -> begin
    mode = get(props, :type, "single") == "single" ? 0 : 1
    c_flag = (mode == 0 && get(props, :collapsible, false)) ? 1 : 0

    dv = get(props, :default_value, nothing)
    open_values = Set{String}()
    if dv !== nothing
        if dv isa AbstractString
            push!(open_values, dv)
        elseif dv isa AbstractVector
            for v in dv; push!(open_values, string(v)); end
        end
    end

    active_idx = -1
    mask = 0
    item_idx = 0
    for arg in args
        if arg isa Therapy.VNode && haskey(arg.props, Symbol("data-accordion-item"))
            val = string(arg.props[Symbol("data-accordion-item")])
            if val in open_values
                if mode == 0
                    active_idx = item_idx
                else
                    mask |= (1 << item_idx)
                end
            end
            item_idx += 1
        end
    end

    props[:_a] = mode == 0 ? active_idx : mask
    props[:_c] = c_flag
    props[:_m] = mode
    props[:_n] = item_idx
end


# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Accordion,
        "Accordion.jl",
        :island,
        "Vertically stacked expandable sections with keyboard navigation",
        Symbol[],
        Symbol[],
        [:Accordion, :AccordionItem, :AccordionTrigger, :AccordionContent],
    ))
end
