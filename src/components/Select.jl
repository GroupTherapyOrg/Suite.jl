# Select.jl — Suite.jl Select Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Select(...)
# Usage via extract: include("components/Select.jl"); Select(...)
#
# Behavior (Thaw-style inline Wasm):
#   - Custom styled select dropdown replacing native <select>
#   - Click trigger opens/closes floating content
#   - Escape key dismisses (via push_escape_handler Wasm import)
#   - Focus returns to trigger on close (via store/restore_active_element Wasm imports)
#   - Signal-driven: BindBool maps open signal to data-state and aria-expanded
#   - ShowDescendants binding handles show/hide + data-state on content children
#   - Check indicator on selected item
#   - Groups, labels, separators support
#
# Architecture: Split islands (Thaw-style)
#   - Select (parent island): creates signal, provides context, registers show binding
#   - SelectTrigger (child island): reads context, toggles signal with inline Wasm behavior
#   - SelectContent: plain function (styling, SSR-only)
#   - SelectItem: plain function (styling, SSR-only)
#
# Reference: Thaw Select — github.com/thaw-ui/thaw

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Select, SelectTrigger, SelectValue, SelectContent,
       SelectItem, SelectGroup, SelectLabel,
       SelectSeparator, SelectScrollUpButton, SelectScrollDownButton

# --- SVG Icons ---
const _SELECT_CHEVRON_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="size-4 opacity-50"><path d="m6 9 6 6 6-6"/></svg>"""

const _SELECT_CHECK_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="h-4 w-4"><path d="M20 6L9 17l-5-5"/></svg>"""

const _SELECT_SCROLL_UP_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="size-4"><path d="m18 15-6-6-6 6"/></svg>"""

const _SELECT_SCROLL_DOWN_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="size-4"><path d="m6 9 6 6 6-6"/></svg>"""

#   Select(children...; value, default_value, name, disabled, required, class, kwargs...) -> IslandVNode
#
# A custom styled select dropdown replacing native `<select>`.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# Parent island: creates signal, provides context for child islands.
# ShowDescendants binding handles show/hide + data-state on content children.
# Behavioral logic (focus, Escape) is inline Wasm in SelectTrigger.
#
# Examples:
#   Select(
#       SelectTrigger(SelectValue(placeholder="Select a fruit...")),
#       SelectContent(SelectItem("Apple", value="apple"), SelectItem("Banana", value="banana"))
#   )
@island function Select(children...; value::String="", default_value::String="",
                     name::String="", disabled::Bool=false, required::Bool=false,
                     class::String="", kwargs...)
    # Signal for open state (Int32: 0=closed, 1=open)
    is_open, set_open = create_signal(Int32(0))

    # Provide context for child islands (single key with getter+setter tuple)
    provide_context(:select, (is_open, set_open))

    initial_value = !isempty(value) ? value : default_value

    Div(Symbol("data-show") => ShowDescendants(is_open),  # show/hide + data-state binding (inline Wasm)
        Symbol("data-select-value") => initial_value,
        Symbol("data-select-name") => name,
        :class => cn(class),
        :style => "display:contents",
        (disabled ? (Symbol("data-disabled") => "",) : ())...,
        (required ? (Symbol("data-required") => "",) : ())...,
        kwargs...,
        children...,
    )
end

#   SelectTrigger(children...; class, kwargs...) -> IslandVNode
#
# The button that opens the select dropdown.
# Child island: reads parent context signal via use_context_signal.
#
# Inline Wasm behavior (Thaw-style):
#   - Open: store focus, set signal, register Escape handler
#   - Close: set signal, pop Escape handler, restore focus
@island function SelectTrigger(children...; theme::Symbol=:default, class::String="", kwargs...)
    # Read parent's signal from context (SSR) or create own (Wasm compilation)
    is_open, set_open = use_context_signal(:select, Int32(0))

    classes = cn(
        "border-warm-200 dark:border-warm-700",
        "focus-visible:border-accent-600 focus-visible:ring-accent-600/50",
        "flex h-9 w-full items-center justify-between gap-2",
        "rounded-md border bg-transparent px-3 py-2 text-sm",
        "text-warm-800 dark:text-warm-300",
        "whitespace-nowrap shadow-xs cursor-pointer",
        "disabled:cursor-not-allowed disabled:opacity-50",
        "data-[placeholder]:text-warm-600 dark:data-[placeholder]:text-warm-500",
        "focus-visible:ring-[3px]",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Span(Symbol("data-select-trigger-wrapper") => "",
         :style => "display:contents",
         Symbol("data-state") => BindBool(is_open, "closed", "open"),
         :on_click => () -> begin
             if is_open() == Int32(0)
                 # Opening: inline Wasm behavior (no scroll lock — floating panel)
                 store_active_element()
                 set_open(Int32(1))
                 push_escape_handler(Int32(0))
             else
                 # Closing: inline Wasm behavior
                 set_open(Int32(0))
                 pop_escape_handler()
                 restore_active_element()
             end
         end,
         kwargs...,
         Therapy.Button(:type => "button",
                :class => classes,
                :role => "combobox",
                Symbol("aria-expanded") => BindBool(is_open, "false", "true"),
                Symbol("aria-autocomplete") => "none",
                Symbol("aria-haspopup") => "listbox",
                Span(:class => "line-clamp-1 flex items-center gap-2",
                     Symbol("data-slot") => "select-value",
                     children...),
                Therapy.RawHtml(_SELECT_CHEVRON_SVG),
         ))
end

"""
    SelectValue(; placeholder, class, kwargs...) -> VNode

Displays the currently selected value, or placeholder if none selected.
"""
function SelectValue(; placeholder::String="", class::String="", kwargs...)
    Span(Symbol("data-select-display") => "",
         Symbol("data-placeholder") => "",
         :class => cn(class),
         kwargs...,
         placeholder)
end

"""
    SelectContent(children...; side, side_offset, align, class, kwargs...) -> VNode

The floating dropdown content containing items.

# Arguments
- `side::String="bottom"`: Preferred side ("top", "right", "bottom", "left")
- `side_offset::Int=4`: Distance from trigger in pixels
- `align::String="start"`: Alignment along side ("start", "center", "end")
"""
function SelectContent(children...; side::String="bottom", side_offset::Int=4,
                            align::String="start", theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
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
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-select-content") => "",
        Symbol("data-select-side") => side,
        Symbol("data-select-side-offset") => string(side_offset),
        Symbol("data-select-align") => align,
        Symbol("data-state") => "closed",
        :role => "listbox",
        :tabindex => "-1",
        :style => "display:none",
        :class => classes,
        kwargs...,
        children...,
    )
end

"""
    SelectItem(children...; value, disabled, text_value, class, kwargs...) -> VNode

An individual option in the select dropdown.

# Arguments
- `value::String`: The value associated with this item (required)
- `disabled::Bool=false`: Whether this item is disabled
- `text_value::String=""`: Override text used for typeahead (defaults to content text)
"""
function SelectItem(children...; value::String="", disabled::Bool=false,
                         text_value::String="", theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "focus:bg-warm-100 dark:focus:bg-warm-800",
        "focus:text-warm-800 dark:focus:text-warm-300",
        "relative flex w-full cursor-pointer items-center gap-2",
        "rounded-sm py-1.5 pr-8 pl-2 text-sm outline-hidden",
        "select-none data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-select-item") => "",
        Symbol("data-select-item-value") => value,
        Symbol("data-select-item-text") => text_value,
        :role => "option",
        Symbol("aria-selected") => "false",
        Symbol("data-state") => "unchecked",
        :tabindex => disabled ? nothing : "-1",
        :class => classes,
        (disabled ? (Symbol("data-disabled") => "", Symbol("aria-disabled") => "true") : ())...,
        kwargs...,
        # Check indicator
        Span(:class => "absolute right-2 flex size-3.5 items-center justify-center",
             Symbol("data-select-item-indicator") => "",
             :style => "display:none",
             Therapy.RawHtml(_SELECT_CHECK_SVG)),
        Span(Symbol("data-select-item-text-content") => "",
             children...),
    )
end

"""
    SelectGroup(children...; class, kwargs...) -> VNode

Groups related select items together.
"""
function SelectGroup(children...; class::String="", kwargs...)
    Div(:role => "group",
        Symbol("data-select-group") => "",
        :class => cn("overflow-hidden p-1", class),
        kwargs...,
        children...)
end

"""
    SelectLabel(children...; class, kwargs...) -> VNode

A label for a group of select items.
"""
function SelectLabel(children...; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn("px-2 py-1.5 text-sm font-semibold text-warm-800 dark:text-warm-300", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(:role => "presentation",
        Symbol("data-select-label") => "",
        :class => classes,
        kwargs...,
        children...)
end

"""
    SelectSeparator(; class, kwargs...) -> VNode

A visual separator between select items.
"""
function SelectSeparator(; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn("bg-warm-200 dark:bg-warm-700 -mx-1 my-1 h-px", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-select-separator") => "",
        :role => "separator",
        :class => classes,
        kwargs...)
end

"""
    SelectScrollUpButton(children...; class, kwargs...) -> VNode

A button at the top of the select content that scrolls items upward.
"""
function SelectScrollUpButton(children...; class::String="", kwargs...)
    Div(Symbol("data-select-scroll-up") => "",
        Symbol("aria-hidden") => "true",
        :class => cn("flex cursor-pointer items-center justify-center py-1", class),
        kwargs...,
        (isempty(children) ? (Therapy.RawHtml(_SELECT_SCROLL_UP_SVG),) : children)...)
end

"""
    SelectScrollDownButton(children...; class, kwargs...) -> VNode

A button at the bottom of the select content that scrolls items downward.
"""
function SelectScrollDownButton(children...; class::String="", kwargs...)
    Div(Symbol("data-select-scroll-down") => "",
        Symbol("aria-hidden") => "true",
        :class => cn("flex cursor-pointer items-center justify-center py-1", class),
        kwargs...,
        (isempty(children) ? (Therapy.RawHtml(_SELECT_SCROLL_DOWN_SVG),) : children)...)
end


# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Select,
        "Select.jl",
        :island,
        "Custom styled select dropdown with keyboard navigation and dismiss",
        Symbol[],
        Symbol[],
        [:Select, :SelectTrigger, :SelectValue, :SelectContent,
         :SelectItem, :SelectGroup, :SelectLabel,
         :SelectSeparator, :SelectScrollUpButton, :SelectScrollDownButton],
    ))
end
