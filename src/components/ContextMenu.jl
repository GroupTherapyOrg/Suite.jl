# SuiteContextMenu.jl — Suite.jl Context Menu Component
#
# Tier: js_runtime (requires suite.js for menu behavior, floating, dismiss)
# Suite Dependencies: none (leaf component)
# JS Modules: Menu, ContextMenu, Floating, DismissLayer, ScrollLock, FocusGuards
#
# Usage via package: using Suite; SuiteContextMenu(SuiteContextMenuTrigger(...), SuiteContextMenuContent(...))
# Usage via extract: include("components/ContextMenu.jl"); SuiteContextMenu(...)
#
# Behavior (matches Radix ContextMenu):
#   - Right-click on trigger area opens at pointer position
#   - Touch long-press (700ms) opens at touch position
#   - Same keyboard navigation as DropdownMenu
#   - Escape/click-outside dismiss
#   - Sub-menu support

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteContextMenu, SuiteContextMenuTrigger, SuiteContextMenuContent,
       SuiteContextMenuGroup, SuiteContextMenuLabel, SuiteContextMenuItem,
       SuiteContextMenuCheckboxItem, SuiteContextMenuRadioGroup,
       SuiteContextMenuRadioItem, SuiteContextMenuItemIndicator,
       SuiteContextMenuSeparator, SuiteContextMenuShortcut,
       SuiteContextMenuSub, SuiteContextMenuSubTrigger,
       SuiteContextMenuSubContent

# Re-use SVGs from DropdownMenu (they're the same icons)
const _CONTEXT_CHEVRON_RIGHT = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16" fill="none" class="ml-auto h-4 w-4"><path d="M6 12L10 8L6 4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>"""
const _CONTEXT_CHECK_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="h-4 w-4"><path d="M20 6L9 17l-5-5"/></svg>"""
const _CONTEXT_DOT_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor" class="h-2 w-2"><circle cx="12" cy="12" r="6"/></svg>"""

"""
    SuiteContextMenu(children...; class, kwargs...) -> VNode

A context menu triggered by right-click (or long-press on touch).

# Examples
```julia
SuiteContextMenu(
    SuiteContextMenuTrigger(
        Div(:class => "flex h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed border-warm-200 dark:border-warm-700 text-sm",
            "Right click here")
    ),
    SuiteContextMenuContent(
        SuiteContextMenuLabel("Actions"),
        SuiteContextMenuSeparator(),
        SuiteContextMenuItem("Cut", shortcut="⌘X"),
        SuiteContextMenuItem("Copy", shortcut="⌘C"),
        SuiteContextMenuItem("Paste", shortcut="⌘V"),
    )
)
```
"""
function SuiteContextMenu(children...; class::String="", kwargs...)
    id = "suite-context-menu-" * string(rand(UInt32), base=16)

    trigger_nodes = []
    content_nodes = []
    for child in children
        if child isa Therapy.VNode && haskey(child.props, Symbol("data-suite-context-menu-trigger-wrapper"))
            push!(trigger_nodes, child)
        else
            push!(content_nodes, child)
        end
    end

    Div(:class => cn(class),
        Symbol("data-suite-context-menu") => id,
        :style => "display:contents",
        kwargs...,
        [_context_set_trigger_id(t, id) for t in trigger_nodes]...,
        content_nodes...,
    )
end

function _context_set_trigger_id(node, id)
    if node isa Therapy.VNode && haskey(node.props, Symbol("data-suite-context-menu-trigger-wrapper"))
        inner_props = copy(node.children[1].props)
        inner_props[Symbol("data-suite-context-menu-trigger")] = id
        return Therapy.VNode(node.children[1].tag, inner_props, node.children[1].children)
    end
    node
end

"""
    SuiteContextMenuTrigger(children...; class, kwargs...) -> VNode

The area that responds to right-click. Can wrap any content.
Renders as a `<span>` (not a button — any content can be right-clicked).
"""
function SuiteContextMenuTrigger(children...; class::String="", kwargs...)
    Div(Symbol("data-suite-context-menu-trigger-wrapper") => "",
        :style => "display:contents",
        Span(:class => cn(class),
             kwargs...,
             children...))
end

"""
    SuiteContextMenuContent(children...; class, kwargs...) -> VNode

The floating menu content panel. Positioned at the right-click location.
"""
function SuiteContextMenuContent(children...; class::String="", kwargs...)
    Div(Symbol("data-suite-context-menu-content") => "",
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
    SuiteContextMenuGroup(children...; class, kwargs...) -> VNode

Groups related menu items.
"""
function SuiteContextMenuGroup(children...; class::String="", kwargs...)
    Div(:role => "group",
        :class => cn(class),
        kwargs...,
        children...)
end

"""
    SuiteContextMenuLabel(children...; inset, class, kwargs...) -> VNode

A label for a group of menu items.
"""
function SuiteContextMenuLabel(children...; inset::Bool=false, class::String="", kwargs...)
    Div(:class => cn(
            "px-2 py-1.5 text-sm font-medium text-warm-800 dark:text-warm-300",
            inset && "pl-8",
            class
        ),
        kwargs...,
        children...)
end

"""
    SuiteContextMenuItem(children...; shortcut, disabled, class, kwargs...) -> VNode

A menu item. Optionally pass a `shortcut` string to display a keyboard shortcut.
"""
function SuiteContextMenuItem(children...; shortcut::String="", disabled::Bool=false, text_value::String="", class::String="", kwargs...)
    item_children = collect(Any, children)
    if !isempty(shortcut)
        push!(item_children, Span(:class => "ml-auto text-xs tracking-widest text-warm-600 dark:text-warm-500",
                                   Symbol("data-suite-menu-shortcut") => "",
                                   shortcut))
    end

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
        (disabled ? [Symbol("data-disabled") => ""] : Pair{Symbol,String}[])...,
        (!isempty(text_value) ? [Symbol("data-text-value") => text_value] : Pair{Symbol,String}[])...,
        kwargs...,
        item_children...)
end

"""
    SuiteContextMenuCheckboxItem(children...; checked, disabled, class, kwargs...) -> VNode

A menu item with a checkbox.
"""
function SuiteContextMenuCheckboxItem(children...; checked::Bool=false, disabled::Bool=false, class::String="", kwargs...)
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
        Span(:class => "pointer-events-none absolute left-2 flex h-3.5 w-3.5 items-center justify-center",
             Symbol("data-suite-menu-item-indicator") => "",
             :style => checked ? "" : "display:none",
             Therapy.RawHtml(_CONTEXT_CHECK_SVG)),
        children...,
    )
end

"""
    SuiteContextMenuRadioGroup(children...; value, class, kwargs...) -> VNode

Container for radio menu items.
"""
function SuiteContextMenuRadioGroup(children...; value::String="", class::String="", kwargs...)
    Div(Symbol("data-suite-menu-radio-group") => "",
        Symbol("data-value") => value,
        :role => "group",
        :class => cn(class),
        kwargs...,
        children...)
end

"""
    SuiteContextMenuRadioItem(children...; value, checked, disabled, class, kwargs...) -> VNode

A radio menu item within a RadioGroup.
"""
function SuiteContextMenuRadioItem(children...; value::String="", checked::Bool=false, disabled::Bool=false, class::String="", kwargs...)
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
        Span(:class => "pointer-events-none absolute left-2 flex h-3.5 w-3.5 items-center justify-center",
             Symbol("data-suite-menu-item-indicator") => "",
             :style => checked ? "" : "display:none",
             Therapy.RawHtml(_CONTEXT_DOT_SVG)),
        children...,
    )
end

"""
    SuiteContextMenuItemIndicator(children...; class, kwargs...) -> VNode

Custom indicator for checkbox/radio items.
"""
function SuiteContextMenuItemIndicator(children...; class::String="", kwargs...)
    Span(:class => cn("pointer-events-none absolute left-2 flex h-3.5 w-3.5 items-center justify-center", class),
         Symbol("data-suite-menu-item-indicator") => "",
         kwargs...,
         children...)
end

"""
    SuiteContextMenuSeparator(; class, kwargs...) -> VNode

A visual separator between menu items.
"""
function SuiteContextMenuSeparator(; class::String="", kwargs...)
    Div(Symbol("data-suite-menu-separator") => "",
        :role => "separator",
        :class => cn("-mx-1 my-1 h-px bg-warm-200 dark:bg-warm-700", class),
        kwargs...)
end

"""
    SuiteContextMenuShortcut(children...; class, kwargs...) -> VNode

Displays a keyboard shortcut hint.
"""
function SuiteContextMenuShortcut(children...; class::String="", kwargs...)
    Span(:class => cn("ml-auto text-xs tracking-widest text-warm-600 dark:text-warm-500", class),
         Symbol("data-suite-menu-shortcut") => "",
         kwargs...,
         children...)
end

"""
    SuiteContextMenuSub(children...; class, kwargs...) -> VNode

Container for a sub-menu.
"""
function SuiteContextMenuSub(children...; class::String="", kwargs...)
    Div(Symbol("data-suite-menu-sub") => "",
        :class => cn("relative", class),
        kwargs...,
        children...)
end

"""
    SuiteContextMenuSubTrigger(children...; inset, disabled, class, kwargs...) -> VNode

The item that opens a sub-menu.
"""
function SuiteContextMenuSubTrigger(children...; inset::Bool=false, disabled::Bool=false, class::String="", kwargs...)
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
        Therapy.RawHtml(_CONTEXT_CHEVRON_RIGHT),
    )
end

"""
    SuiteContextMenuSubContent(children...; class, kwargs...) -> VNode

The floating panel of a sub-menu.
"""
function SuiteContextMenuSubContent(children...; class::String="", kwargs...)
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
        :ContextMenu,
        "ContextMenu.jl",
        :js_runtime,
        "Right-click context menu with keyboard nav, typeahead, and sub-menus",
        Symbol[],
        [:Menu, :ContextMenu, :Floating, :DismissLayer, :ScrollLock, :FocusGuards],
        [:SuiteContextMenu, :SuiteContextMenuTrigger, :SuiteContextMenuContent,
         :SuiteContextMenuGroup, :SuiteContextMenuLabel, :SuiteContextMenuItem,
         :SuiteContextMenuCheckboxItem, :SuiteContextMenuRadioGroup,
         :SuiteContextMenuRadioItem, :SuiteContextMenuItemIndicator,
         :SuiteContextMenuSeparator, :SuiteContextMenuShortcut,
         :SuiteContextMenuSub, :SuiteContextMenuSubTrigger,
         :SuiteContextMenuSubContent],
    ))
end
