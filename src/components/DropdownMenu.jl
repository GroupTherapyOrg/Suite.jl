# SuiteDropdownMenu.jl — Suite.jl Dropdown Menu Component
#
# Tier: js_runtime (requires suite.js for menu behavior, floating, dismiss)
# Suite Dependencies: none (leaf component)
# JS Modules: Menu, DropdownMenu, Floating, DismissLayer, ScrollLock, FocusGuards
#
# Usage via package: using Suite; SuiteDropdownMenu(SuiteDropdownMenuTrigger(...), SuiteDropdownMenuContent(...))
# Usage via extract: include("components/DropdownMenu.jl"); SuiteDropdownMenu(...)
#
# Behavior (matches Radix DropdownMenu):
#   - Click trigger to open/close
#   - ArrowDown on trigger opens and focuses first item
#   - Arrow key navigation through items (wraps)
#   - Typeahead search (1s timeout, cycling)
#   - Escape key dismisses, click outside dismisses
#   - CheckboxItem and RadioGroup support
#   - Sub-menu support with ArrowRight/ArrowLeft
#   - Focus returns to trigger on close

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteDropdownMenu, SuiteDropdownMenuTrigger, SuiteDropdownMenuContent,
       SuiteDropdownMenuGroup, SuiteDropdownMenuLabel, SuiteDropdownMenuItem,
       SuiteDropdownMenuCheckboxItem, SuiteDropdownMenuRadioGroup,
       SuiteDropdownMenuRadioItem, SuiteDropdownMenuItemIndicator,
       SuiteDropdownMenuSeparator, SuiteDropdownMenuShortcut,
       SuiteDropdownMenuSub, SuiteDropdownMenuSubTrigger,
       SuiteDropdownMenuSubContent

# --- Chevron SVG ---
const _DROPDOWN_CHEVRON_RIGHT = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16" fill="none" class="ml-auto h-4 w-4"><path d="M6 12L10 8L6 4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>"""

# --- Check SVG ---
const _DROPDOWN_CHECK_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="h-4 w-4"><path d="M20 6L9 17l-5-5"/></svg>"""

# --- Radio Dot SVG ---
const _DROPDOWN_DOT_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor" class="h-2 w-2"><circle cx="12" cy="12" r="6"/></svg>"""

"""
    SuiteDropdownMenu(children...; class, kwargs...) -> VNode

A dropdown menu triggered by a button click.

# Examples
```julia
SuiteDropdownMenu(
    SuiteDropdownMenuTrigger(SuiteButton(variant="outline", "Open")),
    SuiteDropdownMenuContent(
        SuiteDropdownMenuLabel("My Account"),
        SuiteDropdownMenuSeparator(),
        SuiteDropdownMenuItem("Profile", shortcut="⇧⌘P"),
        SuiteDropdownMenuItem("Settings", shortcut="⌘S"),
        SuiteDropdownMenuSeparator(),
        SuiteDropdownMenuItem("Log out", shortcut="⇧⌘Q"),
    )
)
```
"""
function SuiteDropdownMenu(children...; class::String="", kwargs...)
    id = "suite-dropdown-menu-" * string(rand(UInt32), base=16)

    trigger_nodes = []
    content_nodes = []
    for child in children
        if child isa Therapy.VNode && haskey(child.props, Symbol("data-suite-dropdown-menu-trigger-wrapper"))
            push!(trigger_nodes, child)
        else
            push!(content_nodes, child)
        end
    end

    Div(:class => cn(class),
        Symbol("data-suite-dropdown-menu") => id,
        :style => "display:contents",
        kwargs...,
        [_dropdown_set_trigger_id(t, id) for t in trigger_nodes]...,
        content_nodes...,
    )
end

function _dropdown_set_trigger_id(node, id)
    if node isa Therapy.VNode && haskey(node.props, Symbol("data-suite-dropdown-menu-trigger-wrapper"))
        inner_props = copy(node.children[1].props)
        inner_props[Symbol("data-suite-dropdown-menu-trigger")] = id
        inner_props[Symbol("aria-haspopup")] = "menu"
        inner_props[Symbol("aria-expanded")] = "false"
        inner_props[Symbol("data-state")] = "closed"
        return Therapy.VNode(node.children[1].tag, inner_props, node.children[1].children)
    end
    node
end

"""
    SuiteDropdownMenuTrigger(children...; class, kwargs...) -> VNode

The button that opens the dropdown menu.
"""
function SuiteDropdownMenuTrigger(children...; class::String="", kwargs...)
    Div(Symbol("data-suite-dropdown-menu-trigger-wrapper") => "",
        :style => "display:contents",
        Button(:type => "button",
               :class => cn(class),
               kwargs...,
               children...))
end

"""
    SuiteDropdownMenuContent(children...; side, side_offset, align, class, kwargs...) -> VNode

The floating menu content panel. Positioned relative to the trigger.
"""
function SuiteDropdownMenuContent(children...; side::String="bottom", side_offset::Int=4, align::String="start", class::String="", kwargs...)
    Div(Symbol("data-suite-dropdown-menu-content") => "",
        Symbol("data-side-preference") => side,
        Symbol("data-side-offset") => string(side_offset),
        Symbol("data-align-preference") => align,
        Symbol("data-state") => "closed",
        :role => "menu",
        :aria_orientation => "vertical",
        :tabindex => "-1",
        :style => "display:none",
        :class => cn(
            "z-50 max-h-[var(--radix-popper-available-height,300px)] min-w-[8rem]",
            "overflow-x-hidden overflow-y-auto rounded-md p-1 shadow-md",
            "bg-warm-50 dark:bg-warm-900 text-warm-800 dark:text-warm-300",
            "border border-warm-200 dark:border-warm-700",
            "data-[state=open]:animate-in data-[state=closed]:animate-out",
            "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
            "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
            "data-[side=bottom]:slide-in-from-top-2",
            "data-[side=left]:slide-in-from-right-2",
            "data-[side=right]:slide-in-from-left-2",
            "data-[side=top]:slide-in-from-bottom-2",
            class
        ),
        kwargs...,
        children...,
    )
end

"""
    SuiteDropdownMenuGroup(children...; class, kwargs...) -> VNode

Groups related menu items.
"""
function SuiteDropdownMenuGroup(children...; class::String="", kwargs...)
    Div(:role => "group",
        :class => cn(class),
        kwargs...,
        children...)
end

"""
    SuiteDropdownMenuLabel(children...; inset, class, kwargs...) -> VNode

A label for a group of menu items.
"""
function SuiteDropdownMenuLabel(children...; inset::Bool=false, class::String="", kwargs...)
    Div(:class => cn(
            "px-2 py-1.5 text-sm font-medium",
            inset && "pl-8",
            class
        ),
        kwargs...,
        children...)
end

"""
    SuiteDropdownMenuItem(children...; shortcut, disabled, class, kwargs...) -> VNode

A menu item. Optionally pass a `shortcut` string to display a keyboard shortcut.
"""
function SuiteDropdownMenuItem(children...; shortcut::String="", disabled::Bool=false, text_value::String="", class::String="", kwargs...)
    item_children = collect(Any, children)
    if !isempty(shortcut)
        push!(item_children, Span(:class => "ml-auto text-xs tracking-widest text-warm-600 dark:text-warm-500",
                                   Symbol("data-suite-menu-shortcut") => "",
                                   shortcut))
    end

    extra = Pair{Symbol,String}[]
    if disabled; push!(extra, Symbol("data-disabled") => ""); end
    if !isempty(text_value); push!(extra, Symbol("data-text-value") => text_value); end

    Div(Symbol("data-suite-menu-item") => "",
        :role => "menuitem",
        :tabindex => "-1",
        :class => cn(
            "relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5",
            "text-sm outline-hidden select-none",
            "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
            "data-[highlighted]:bg-warm-100 data-[highlighted]:dark:bg-warm-800",
            class
        ),
        extra...,
        kwargs...,
        item_children...)
end

"""
    SuiteDropdownMenuCheckboxItem(children...; checked, disabled, class, kwargs...) -> VNode

A menu item with a checkbox. Toggles checked state on click.
"""
function SuiteDropdownMenuCheckboxItem(children...; checked::Bool=false, disabled::Bool=false, class::String="", kwargs...)
    state = checked ? "checked" : "unchecked"

    Div(Symbol("data-suite-menu-checkbox-item") => "",
        Symbol("data-state") => state,
        :role => "menuitemcheckbox",
        Symbol("aria-checked") => string(checked),
        :tabindex => "-1",
        :class => cn(
            "relative flex cursor-default items-center gap-2 rounded-sm py-1.5 pr-2 pl-8",
            "text-sm outline-hidden select-none",
            "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
            "data-[highlighted]:bg-warm-100 data-[highlighted]:dark:bg-warm-800",
            class
        ),
        (disabled ? [Symbol("data-disabled") => ""] : Pair{Symbol,String}[])...,
        kwargs...,
        # Indicator
        Span(:class => "pointer-events-none absolute left-2 flex h-3.5 w-3.5 items-center justify-center",
             Symbol("data-suite-menu-item-indicator") => "",
             :style => checked ? "" : "display:none",
             Therapy.RawHtml(_DROPDOWN_CHECK_SVG)),
        children...,
    )
end

"""
    SuiteDropdownMenuRadioGroup(children...; value, class, kwargs...) -> VNode

Container for radio menu items. Only one item can be checked at a time.
"""
function SuiteDropdownMenuRadioGroup(children...; value::String="", class::String="", kwargs...)
    Div(Symbol("data-suite-menu-radio-group") => "",
        Symbol("data-value") => value,
        :role => "group",
        :class => cn(class),
        kwargs...,
        children...)
end

"""
    SuiteDropdownMenuRadioItem(children...; value, checked, disabled, class, kwargs...) -> VNode

A radio menu item within a RadioGroup.
"""
function SuiteDropdownMenuRadioItem(children...; value::String="", checked::Bool=false, disabled::Bool=false, class::String="", kwargs...)
    state = checked ? "checked" : "unchecked"

    Div(Symbol("data-suite-menu-radio-item") => "",
        Symbol("data-value") => value,
        Symbol("data-state") => state,
        :role => "menuitemradio",
        Symbol("aria-checked") => string(checked),
        :tabindex => "-1",
        :class => cn(
            "relative flex cursor-default items-center gap-2 rounded-sm py-1.5 pr-2 pl-8",
            "text-sm outline-hidden select-none",
            "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
            "data-[highlighted]:bg-warm-100 data-[highlighted]:dark:bg-warm-800",
            class
        ),
        (disabled ? [Symbol("data-disabled") => ""] : Pair{Symbol,String}[])...,
        kwargs...,
        # Indicator dot
        Span(:class => "pointer-events-none absolute left-2 flex h-3.5 w-3.5 items-center justify-center",
             Symbol("data-suite-menu-item-indicator") => "",
             :style => checked ? "" : "display:none",
             Therapy.RawHtml(_DROPDOWN_DOT_SVG)),
        children...,
    )
end

"""
    SuiteDropdownMenuItemIndicator(children...; class, kwargs...) -> VNode

Custom indicator for checkbox/radio items. Replaces the default check/dot.
"""
function SuiteDropdownMenuItemIndicator(children...; class::String="", kwargs...)
    Span(:class => cn("pointer-events-none absolute left-2 flex h-3.5 w-3.5 items-center justify-center", class),
         Symbol("data-suite-menu-item-indicator") => "",
         kwargs...,
         children...)
end

"""
    SuiteDropdownMenuSeparator(; class, kwargs...) -> VNode

A visual separator between menu items.
"""
function SuiteDropdownMenuSeparator(; class::String="", kwargs...)
    Div(Symbol("data-suite-menu-separator") => "",
        :role => "separator",
        :class => cn("-mx-1 my-1 h-px bg-warm-200 dark:bg-warm-700", class),
        kwargs...)
end

"""
    SuiteDropdownMenuShortcut(children...; class, kwargs...) -> VNode

Displays a keyboard shortcut hint aligned to the right of a menu item.
"""
function SuiteDropdownMenuShortcut(children...; class::String="", kwargs...)
    Span(:class => cn("ml-auto text-xs tracking-widest text-warm-600 dark:text-warm-500", class),
         Symbol("data-suite-menu-shortcut") => "",
         kwargs...,
         children...)
end

"""
    SuiteDropdownMenuSub(children...; class, kwargs...) -> VNode

Container for a sub-menu. Contains a SubTrigger and SubContent.
"""
function SuiteDropdownMenuSub(children...; class::String="", kwargs...)
    Div(Symbol("data-suite-menu-sub") => "",
        :class => cn("relative", class),
        kwargs...,
        children...)
end

"""
    SuiteDropdownMenuSubTrigger(children...; inset, disabled, class, kwargs...) -> VNode

The item that opens a sub-menu on hover or ArrowRight.
"""
function SuiteDropdownMenuSubTrigger(children...; inset::Bool=false, disabled::Bool=false, class::String="", kwargs...)
    Div(Symbol("data-suite-menu-sub-trigger") => "",
        Symbol("data-state") => "closed",
        :role => "menuitem",
        Symbol("aria-haspopup") => "menu",
        Symbol("aria-expanded") => "false",
        :tabindex => "-1",
        :class => cn(
            "flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm",
            "outline-hidden select-none",
            "data-[state=open]:bg-warm-100 data-[state=open]:dark:bg-warm-800",
            "data-[highlighted]:bg-warm-100 data-[highlighted]:dark:bg-warm-800",
            "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
            inset && "pl-8",
            class
        ),
        (disabled ? [Symbol("data-disabled") => ""] : Pair{Symbol,String}[])...,
        kwargs...,
        children...,
        Therapy.RawHtml(_DROPDOWN_CHEVRON_RIGHT),
    )
end

"""
    SuiteDropdownMenuSubContent(children...; class, kwargs...) -> VNode

The floating panel of a sub-menu.
"""
function SuiteDropdownMenuSubContent(children...; class::String="", kwargs...)
    Div(Symbol("data-suite-menu-sub-content") => "",
        Symbol("data-state") => "closed",
        :role => "menu",
        :aria_orientation => "vertical",
        :tabindex => "-1",
        :style => "display:none",
        :class => cn(
            "z-50 min-w-[8rem] overflow-hidden rounded-md p-1 shadow-lg",
            "bg-warm-50 dark:bg-warm-900 text-warm-800 dark:text-warm-300",
            "border border-warm-200 dark:border-warm-700",
            "data-[state=open]:animate-in data-[state=closed]:animate-out",
            "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
            "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
            "data-[side=bottom]:slide-in-from-top-2",
            "data-[side=left]:slide-in-from-right-2",
            "data-[side=right]:slide-in-from-left-2",
            "data-[side=top]:slide-in-from-bottom-2",
            class
        ),
        kwargs...,
        children...,
    )
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :DropdownMenu,
        "DropdownMenu.jl",
        :js_runtime,
        "Click-triggered dropdown menu with keyboard nav, typeahead, and sub-menus",
        Symbol[],
        [:Menu, :DropdownMenu, :Floating, :DismissLayer, :ScrollLock, :FocusGuards],
        [:SuiteDropdownMenu, :SuiteDropdownMenuTrigger, :SuiteDropdownMenuContent,
         :SuiteDropdownMenuGroup, :SuiteDropdownMenuLabel, :SuiteDropdownMenuItem,
         :SuiteDropdownMenuCheckboxItem, :SuiteDropdownMenuRadioGroup,
         :SuiteDropdownMenuRadioItem, :SuiteDropdownMenuItemIndicator,
         :SuiteDropdownMenuSeparator, :SuiteDropdownMenuShortcut,
         :SuiteDropdownMenuSub, :SuiteDropdownMenuSubTrigger,
         :SuiteDropdownMenuSubContent],
    ))
end
