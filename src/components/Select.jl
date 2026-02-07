# SuiteSelect.jl — Suite.jl Select Component
#
# Tier: js_runtime (requires suite.js for typeahead, keyboard nav, floating)
# Suite Dependencies: none (leaf component)
# JS Modules: Floating, DismissLayer, ScrollLock, FocusGuards, Select
#
# Usage via package: using Suite; SuiteSelect(...)
# Usage via extract: include("components/Select.jl"); SuiteSelect(...)
#
# Behavior (matches Radix Select):
#   - Custom styled select dropdown replacing native <select>
#   - Click or keyboard trigger opens floating content
#   - Arrow key navigation through items (wraps)
#   - Typeahead search (1s timeout, repeated char cycling)
#   - Escape key dismisses, click outside dismisses
#   - Tab prevented while open (select is not tab-navigable)
#   - Check indicator on selected item
#   - Groups, labels, separators support
#   - Popper positioning mode with flip/shift

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteSelect, SuiteSelectTrigger, SuiteSelectValue, SuiteSelectContent,
       SuiteSelectItem, SuiteSelectGroup, SuiteSelectLabel,
       SuiteSelectSeparator, SuiteSelectScrollUpButton, SuiteSelectScrollDownButton

# --- SVG Icons ---
const _SELECT_CHEVRON_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="size-4 opacity-50"><path d="m6 9 6 6 6-6"/></svg>"""

const _SELECT_CHECK_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="h-4 w-4"><path d="M20 6L9 17l-5-5"/></svg>"""

const _SELECT_SCROLL_UP_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="size-4"><path d="m18 15-6-6-6 6"/></svg>"""

const _SELECT_SCROLL_DOWN_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="size-4"><path d="m6 9 6 6 6-6"/></svg>"""

"""
    SuiteSelect(children...; value, default_value, name, disabled, required, class, kwargs...) -> VNode

A custom styled select dropdown replacing native `<select>`.

# Arguments
- `value::String=""`: Currently selected value (controlled)
- `default_value::String=""`: Initial value (uncontrolled)
- `name::String=""`: Form field name
- `disabled::Bool=false`: Disable the entire select
- `required::Bool=false`: Mark as required for form validation

# Examples
```julia
SuiteSelect(
    SuiteSelectTrigger(SuiteSelectValue(placeholder="Select a fruit...")),
    SuiteSelectContent(
        SuiteSelectGroup(
            SuiteSelectLabel("Fruits"),
            SuiteSelectItem("Apple", value="apple"),
            SuiteSelectItem("Banana", value="banana"),
            SuiteSelectItem("Orange", value="orange"),
        )
    )
)
```
"""
function SuiteSelect(children...; value::String="", default_value::String="",
                     name::String="", disabled::Bool=false, required::Bool=false,
                     class::String="", kwargs...)
    id = "suite-select-" * string(rand(UInt32), base=16)

    trigger_nodes = []
    content_nodes = []
    for child in children
        if child isa Therapy.VNode && haskey(child.props, Symbol("data-suite-select-trigger-wrapper"))
            push!(trigger_nodes, child)
        else
            push!(content_nodes, child)
        end
    end

    # Determine initial value
    initial_value = !isempty(value) ? value : default_value

    Div(:class => cn(class),
        Symbol("data-suite-select") => id,
        Symbol("data-suite-select-value") => initial_value,
        Symbol("data-suite-select-name") => name,
        :style => "display:contents",
        (disabled ? (Symbol("data-disabled") => "",) : ())...,
        (required ? (Symbol("data-required") => "",) : ())...,
        kwargs...,
        [_select_set_trigger_id(t, id) for t in trigger_nodes]...,
        content_nodes...,
    )
end

function _select_set_trigger_id(node, id)
    if node isa Therapy.VNode && haskey(node.props, Symbol("data-suite-select-trigger-wrapper"))
        inner = node.children[1]
        inner_props = copy(inner.props)
        inner_props[Symbol("data-suite-select-trigger")] = id
        inner_props[:role] = "combobox"
        inner_props[Symbol("aria-expanded")] = "false"
        inner_props[Symbol("aria-autocomplete")] = "none"
        inner_props[Symbol("data-state")] = "closed"
        return Therapy.VNode(inner.tag, inner_props, inner.children)
    end
    node
end

"""
    SuiteSelectTrigger(children...; class, kwargs...) -> VNode

The button that opens the select dropdown.
"""
function SuiteSelectTrigger(children...; class::String="", kwargs...)
    Div(Symbol("data-suite-select-trigger-wrapper") => "",
        :style => "display:contents",
        Button(:type => "button",
               :class => cn(
                   "border-warm-200 dark:border-warm-700",
                   "focus-visible:border-accent-600 focus-visible:ring-accent-600/50",
                   "flex h-9 w-full items-center justify-between gap-2",
                   "rounded-md border bg-transparent px-3 py-2 text-sm",
                   "whitespace-nowrap shadow-xs",
                   "disabled:cursor-not-allowed disabled:opacity-50",
                   "data-[placeholder]:text-warm-600 dark:data-[placeholder]:text-warm-500",
                   "focus-visible:ring-[3px]",
                   class
               ),
               kwargs...,
               Span(:class => "line-clamp-1 flex items-center gap-2",
                    Symbol("data-slot") => "select-value",
                    children...),
               Therapy.RawHtml(_SELECT_CHEVRON_SVG),
        ))
end

"""
    SuiteSelectValue(; placeholder, class, kwargs...) -> VNode

Displays the currently selected value, or placeholder if none selected.
"""
function SuiteSelectValue(; placeholder::String="", class::String="", kwargs...)
    Span(Symbol("data-suite-select-display") => "",
         Symbol("data-placeholder") => "",
         :class => cn(class),
         kwargs...,
         placeholder)
end

"""
    SuiteSelectContent(children...; side, side_offset, align, class, kwargs...) -> VNode

The floating dropdown content containing items.

# Arguments
- `side::String="bottom"`: Preferred side ("top", "right", "bottom", "left")
- `side_offset::Int=4`: Distance from trigger in pixels
- `align::String="start"`: Alignment along side ("start", "center", "end")
"""
function SuiteSelectContent(children...; side::String="bottom", side_offset::Int=4,
                            align::String="start", class::String="", kwargs...)
    Div(Symbol("data-suite-select-content") => "",
        Symbol("data-suite-select-side") => side,
        Symbol("data-suite-select-side-offset") => string(side_offset),
        Symbol("data-suite-select-align") => align,
        Symbol("data-state") => "closed",
        :role => "listbox",
        :tabindex => "-1",
        :style => "display:none",
        :class => cn(
            "bg-warm-50 dark:bg-warm-900 text-warm-800 dark:text-warm-300",
            "data-[state=open]:animate-in data-[state=closed]:animate-out",
            "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
            "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
            "data-[side=bottom]:slide-in-from-top-2",
            "data-[side=left]:slide-in-from-right-2",
            "data-[side=right]:slide-in-from-left-2",
            "data-[side=top]:slide-in-from-bottom-2",
            "relative z-50 max-h-[--radix-select-content-available-height]",
            "min-w-[8rem] overflow-x-hidden overflow-y-auto rounded-md",
            "border border-warm-200 dark:border-warm-700 shadow-md p-1",
            "data-[side=bottom]:translate-y-1",
            "data-[side=left]:-translate-x-1",
            "data-[side=right]:translate-x-1",
            "data-[side=top]:-translate-y-1",
            class
        ),
        kwargs...,
        children...,
    )
end

"""
    SuiteSelectItem(children...; value, disabled, text_value, class, kwargs...) -> VNode

An individual option in the select dropdown.

# Arguments
- `value::String`: The value associated with this item (required)
- `disabled::Bool=false`: Whether this item is disabled
- `text_value::String=""`: Override text used for typeahead (defaults to content text)
"""
function SuiteSelectItem(children...; value::String="", disabled::Bool=false,
                         text_value::String="", class::String="", kwargs...)
    Div(Symbol("data-suite-select-item") => "",
        Symbol("data-suite-select-item-value") => value,
        Symbol("data-suite-select-item-text") => text_value,
        :role => "option",
        Symbol("aria-selected") => "false",
        Symbol("data-state") => "unchecked",
        :tabindex => disabled ? nothing : "-1",
        :class => cn(
            "focus:bg-warm-100 dark:focus:bg-warm-800",
            "focus:text-warm-800 dark:focus:text-warm-300",
            "relative flex w-full cursor-default items-center gap-2",
            "rounded-sm py-1.5 pr-8 pl-2 text-sm outline-hidden",
            "select-none data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
            class
        ),
        (disabled ? (Symbol("data-disabled") => "", Symbol("aria-disabled") => "true") : ())...,
        kwargs...,
        # Check indicator
        Span(:class => "absolute right-2 flex size-3.5 items-center justify-center",
             Symbol("data-suite-select-item-indicator") => "",
             :style => "display:none",
             Therapy.RawHtml(_SELECT_CHECK_SVG)),
        Span(Symbol("data-suite-select-item-text-content") => "",
             children...),
    )
end

"""
    SuiteSelectGroup(children...; class, kwargs...) -> VNode

Groups related select items together.
"""
function SuiteSelectGroup(children...; class::String="", kwargs...)
    Div(:role => "group",
        Symbol("data-suite-select-group") => "",
        :class => cn("overflow-hidden p-1", class),
        kwargs...,
        children...)
end

"""
    SuiteSelectLabel(children...; class, kwargs...) -> VNode

A label for a group of select items.
"""
function SuiteSelectLabel(children...; class::String="", kwargs...)
    Div(:role => "presentation",
        Symbol("data-suite-select-label") => "",
        :class => cn("px-2 py-1.5 text-sm font-semibold text-warm-800 dark:text-warm-300", class),
        kwargs...,
        children...)
end

"""
    SuiteSelectSeparator(; class, kwargs...) -> VNode

A visual separator between select items.
"""
function SuiteSelectSeparator(; class::String="", kwargs...)
    Div(Symbol("data-suite-select-separator") => "",
        :role => "separator",
        :class => cn("bg-warm-200 dark:bg-warm-700 -mx-1 my-1 h-px", class),
        kwargs...)
end

"""
    SuiteSelectScrollUpButton(children...; class, kwargs...) -> VNode

A button at the top of the select content that scrolls items upward.
"""
function SuiteSelectScrollUpButton(children...; class::String="", kwargs...)
    Div(Symbol("data-suite-select-scroll-up") => "",
        Symbol("aria-hidden") => "true",
        :class => cn("flex cursor-default items-center justify-center py-1", class),
        kwargs...,
        (isempty(children) ? (Therapy.RawHtml(_SELECT_SCROLL_UP_SVG),) : children)...)
end

"""
    SuiteSelectScrollDownButton(children...; class, kwargs...) -> VNode

A button at the bottom of the select content that scrolls items downward.
"""
function SuiteSelectScrollDownButton(children...; class::String="", kwargs...)
    Div(Symbol("data-suite-select-scroll-down") => "",
        Symbol("aria-hidden") => "true",
        :class => cn("flex cursor-default items-center justify-center py-1", class),
        kwargs...,
        (isempty(children) ? (Therapy.RawHtml(_SELECT_SCROLL_DOWN_SVG),) : children)...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Select,
        "Select.jl",
        :js_runtime,
        "Custom styled select dropdown with typeahead, keyboard navigation, and floating positioning",
        Symbol[],
        [:Floating, :DismissLayer, :ScrollLock, :FocusGuards, :Select],
        [:SuiteSelect, :SuiteSelectTrigger, :SuiteSelectValue, :SuiteSelectContent,
         :SuiteSelectItem, :SuiteSelectGroup, :SuiteSelectLabel,
         :SuiteSelectSeparator, :SuiteSelectScrollUpButton, :SuiteSelectScrollDownButton],
    ))
end
