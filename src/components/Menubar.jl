# SuiteMenubar.jl — Suite.jl Menubar Component
#
# Tier: js_runtime (requires suite.js for menu behavior, roving focus, floating, dismiss)
# Suite Dependencies: none (leaf component)
# JS Modules: Menu, Menubar, Floating, DismissLayer, ScrollLock, FocusGuards
#
# Usage via package: using Suite; SuiteMenubar(SuiteMenubarMenu(SuiteMenubarTrigger("File"), SuiteMenubarContent(...)), ...)
# Usage via extract: include("components/Menubar.jl"); SuiteMenubar(...)
#
# Behavior (matches Radix Menubar):
#   - Horizontal bar of menu triggers
#   - Click trigger to open/close its dropdown
#   - Arrow Left/Right to navigate between triggers (with loop)
#   - Pointer-enter rapid switching when any menu is open
#   - ArrowDown on trigger opens and focuses first item
#   - Arrow Left/Right within content navigates between menus
#   - Same item keyboard nav, typeahead, sub-menus as DropdownMenu

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteMenubar, SuiteMenubarMenu, SuiteMenubarTrigger, SuiteMenubarContent,
       SuiteMenubarGroup, SuiteMenubarLabel, SuiteMenubarItem,
       SuiteMenubarCheckboxItem, SuiteMenubarRadioGroup,
       SuiteMenubarRadioItem, SuiteMenubarItemIndicator,
       SuiteMenubarSeparator, SuiteMenubarShortcut,
       SuiteMenubarSub, SuiteMenubarSubTrigger,
       SuiteMenubarSubContent

# --- Chevron SVG ---
const _MENUBAR_CHEVRON_RIGHT = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16" fill="none" class="ml-auto h-4 w-4"><path d="M6 12L10 8L6 4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>"""
const _MENUBAR_CHECK_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="h-4 w-4"><path d="M20 6L9 17l-5-5"/></svg>"""
const _MENUBAR_DOT_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor" class="h-2 w-2"><circle cx="12" cy="12" r="6"/></svg>"""

"""
    SuiteMenubar(children...; loop, class, kwargs...) -> VNode

A horizontal menu bar containing multiple menu triggers.

# Examples
```julia
SuiteMenubar(
    SuiteMenubarMenu(
        SuiteMenubarTrigger("File"),
        SuiteMenubarContent(
            SuiteMenubarItem("New Tab", shortcut="⌘T"),
            SuiteMenubarItem("New Window", shortcut="⌘N"),
            SuiteMenubarSeparator(),
            SuiteMenubarItem("Print...", shortcut="⌘P"),
        )
    ),
    SuiteMenubarMenu(
        SuiteMenubarTrigger("Edit"),
        SuiteMenubarContent(
            SuiteMenubarItem("Undo", shortcut="⌘Z"),
            SuiteMenubarItem("Redo", shortcut="⇧⌘Z"),
        )
    ),
)
```
"""
function SuiteMenubar(children...; loop::Bool=true, theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "flex h-9 items-center gap-1 rounded-md p-1 shadow-xs",
        "bg-warm-50 dark:bg-warm-950",
        "border border-warm-200 dark:border-warm-700",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-suite-menubar") => "",
        Symbol("data-loop") => string(loop),
        :role => "menubar",
        :class => classes,
        kwargs...,
        children...)
end

"""
    SuiteMenubarMenu(children...; value, class, kwargs...) -> VNode

An individual menu within the menubar. Contains a trigger and content.
"""
function SuiteMenubarMenu(children...; value::String="", class::String="", kwargs...)
    id = "suite-menubar-menu-" * string(rand(UInt32), base=16)

    trigger_nodes = []
    content_nodes = []
    for child in children
        if child isa Therapy.VNode && haskey(child.props, Symbol("data-suite-menubar-trigger-marker"))
            push!(trigger_nodes, child)
        else
            push!(content_nodes, child)
        end
    end

    menu_value = isempty(value) ? id : value

    Div(Symbol("data-suite-menubar-menu") => id,
        Symbol("data-value") => menu_value,
        :class => cn("relative", class),
        :style => "display:contents",
        kwargs...,
        [_menubar_set_trigger_id(t, id) for t in trigger_nodes]...,
        content_nodes...,
    )
end

function _menubar_set_trigger_id(node, id)
    if node isa Therapy.VNode && haskey(node.props, Symbol("data-suite-menubar-trigger-marker"))
        inner = node.children[1]
        inner_props = copy(inner.props)
        inner_props[Symbol("data-suite-menubar-trigger")] = id
        inner_props[Symbol("aria-haspopup")] = "menu"
        inner_props[Symbol("aria-expanded")] = "false"
        inner_props[Symbol("data-state")] = "closed"
        return Therapy.VNode(inner.tag, inner_props, inner.children)
    end
    node
end

"""
    SuiteMenubarTrigger(children...; disabled, class, kwargs...) -> VNode

The button that opens a menu within the menubar.
"""
function SuiteMenubarTrigger(children...; disabled::Bool=false, theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "flex items-center rounded-sm px-2 py-1 text-sm font-medium",
        "outline-hidden select-none cursor-default",
        "data-[state=open]:bg-warm-100 data-[state=open]:dark:bg-warm-800",
        "data-[highlighted]:bg-warm-100 data-[highlighted]:dark:bg-warm-800",
        "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
        "focus-visible:bg-warm-100 focus-visible:dark:bg-warm-800",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-suite-menubar-trigger-marker") => "",
        :style => "display:contents",
        Button(:type => "button",
               :role => "menuitem",
               :tabindex => "-1",
               :class => classes,
               (disabled ? [Symbol("data-disabled") => ""] : Pair{Symbol,String}[])...,
               kwargs...,
               children...))
end

"""
    SuiteMenubarContent(children...; side, side_offset, align, class, kwargs...) -> VNode

The floating dropdown content panel for a menubar menu.
"""
function SuiteMenubarContent(children...; side::String="bottom", side_offset::Int=4, align::String="start", theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "z-50 max-h-[var(--radix-popper-available-height,300px)] min-w-[12rem]",
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
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-suite-menubar-content") => "",
        Symbol("data-side-preference") => side,
        Symbol("data-side-offset") => string(side_offset),
        Symbol("data-align-preference") => align,
        Symbol("data-state") => "closed",
        :role => "menu",
        :aria_orientation => "vertical",
        :tabindex => "-1",
        :style => "display:none",
        :class => classes,
        kwargs...,
        children...,
    )
end

"""
    SuiteMenubarGroup(children...; class, kwargs...) -> VNode

Groups related menu items.
"""
function SuiteMenubarGroup(children...; class::String="", kwargs...)
    Div(:role => "group",
        :class => cn(class),
        kwargs...,
        children...)
end

"""
    SuiteMenubarLabel(children...; inset, class, kwargs...) -> VNode

A label for a group of menu items.
"""
function SuiteMenubarLabel(children...; inset::Bool=false, class::String="", kwargs...)
    Div(:class => cn(
            "px-2 py-1.5 text-sm font-medium",
            inset && "pl-8",
            class
        ),
        kwargs...,
        children...)
end

"""
    SuiteMenubarItem(children...; shortcut, disabled, class, kwargs...) -> VNode

A menu item within a menubar dropdown.
"""
function SuiteMenubarItem(children...; shortcut::String="", disabled::Bool=false, text_value::String="", theme::Symbol=:default, class::String="", kwargs...)
    item_children = collect(Any, children)
    if !isempty(shortcut)
        push!(item_children, Span(:class => "ml-auto text-xs tracking-widest text-warm-600 dark:text-warm-500",
                                   Symbol("data-suite-menu-shortcut") => "",
                                   shortcut))
    end

    extra = Pair{Symbol,String}[]
    if disabled; push!(extra, Symbol("data-disabled") => ""); end
    if !isempty(text_value); push!(extra, Symbol("data-text-value") => text_value); end

    classes = cn(
        "relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5",
        "text-sm outline-hidden select-none",
        "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
        "data-[highlighted]:bg-warm-100 data-[highlighted]:dark:bg-warm-800",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-suite-menu-item") => "",
        :role => "menuitem",
        :tabindex => "-1",
        :class => classes,
        extra...,
        kwargs...,
        item_children...)
end

"""
    SuiteMenubarCheckboxItem(children...; checked, disabled, class, kwargs...) -> VNode

A menu item with a checkbox.
"""
function SuiteMenubarCheckboxItem(children...; checked::Bool=false, disabled::Bool=false, theme::Symbol=:default, class::String="", kwargs...)
    state = checked ? "checked" : "unchecked"

    classes = cn(
        "relative flex cursor-default items-center gap-2 rounded-sm py-1.5 pr-2 pl-8",
        "text-sm outline-hidden select-none",
        "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
        "data-[highlighted]:bg-warm-100 data-[highlighted]:dark:bg-warm-800",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-suite-menu-checkbox-item") => "",
        Symbol("data-state") => state,
        :role => "menuitemcheckbox",
        Symbol("aria-checked") => string(checked),
        :tabindex => "-1",
        :class => classes,
        (disabled ? [Symbol("data-disabled") => ""] : Pair{Symbol,String}[])...,
        kwargs...,
        Span(:class => "pointer-events-none absolute left-2 flex h-3.5 w-3.5 items-center justify-center",
             Symbol("data-suite-menu-item-indicator") => "",
             :style => checked ? "" : "display:none",
             Therapy.RawHtml(_MENUBAR_CHECK_SVG)),
        children...,
    )
end

"""
    SuiteMenubarRadioGroup(children...; value, class, kwargs...) -> VNode

Container for radio menu items.
"""
function SuiteMenubarRadioGroup(children...; value::String="", class::String="", kwargs...)
    Div(Symbol("data-suite-menu-radio-group") => "",
        Symbol("data-value") => value,
        :role => "group",
        :class => cn(class),
        kwargs...,
        children...)
end

"""
    SuiteMenubarRadioItem(children...; value, checked, disabled, class, kwargs...) -> VNode

A radio menu item within a RadioGroup.
"""
function SuiteMenubarRadioItem(children...; value::String="", checked::Bool=false, disabled::Bool=false, theme::Symbol=:default, class::String="", kwargs...)
    state = checked ? "checked" : "unchecked"

    classes = cn(
        "relative flex cursor-default items-center gap-2 rounded-sm py-1.5 pr-2 pl-8",
        "text-sm outline-hidden select-none",
        "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
        "data-[highlighted]:bg-warm-100 data-[highlighted]:dark:bg-warm-800",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-suite-menu-radio-item") => "",
        Symbol("data-value") => value,
        Symbol("data-state") => state,
        :role => "menuitemradio",
        Symbol("aria-checked") => string(checked),
        :tabindex => "-1",
        :class => classes,
        (disabled ? [Symbol("data-disabled") => ""] : Pair{Symbol,String}[])...,
        kwargs...,
        Span(:class => "pointer-events-none absolute left-2 flex h-3.5 w-3.5 items-center justify-center",
             Symbol("data-suite-menu-item-indicator") => "",
             :style => checked ? "" : "display:none",
             Therapy.RawHtml(_MENUBAR_DOT_SVG)),
        children...,
    )
end

"""
    SuiteMenubarItemIndicator(children...; class, kwargs...) -> VNode

Custom indicator for checkbox/radio items.
"""
function SuiteMenubarItemIndicator(children...; class::String="", kwargs...)
    Span(:class => cn("pointer-events-none absolute left-2 flex h-3.5 w-3.5 items-center justify-center", class),
         Symbol("data-suite-menu-item-indicator") => "",
         kwargs...,
         children...)
end

"""
    SuiteMenubarSeparator(; class, kwargs...) -> VNode

A visual separator between menu items.
"""
function SuiteMenubarSeparator(; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn("-mx-1 my-1 h-px bg-warm-200 dark:bg-warm-700", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-suite-menu-separator") => "",
        :role => "separator",
        :class => classes,
        kwargs...)
end

"""
    SuiteMenubarShortcut(children...; class, kwargs...) -> VNode

Displays a keyboard shortcut hint.
"""
function SuiteMenubarShortcut(children...; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn("ml-auto text-xs tracking-widest text-warm-600 dark:text-warm-500", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Span(:class => classes,
         Symbol("data-suite-menu-shortcut") => "",
         kwargs...,
         children...)
end

"""
    SuiteMenubarSub(children...; class, kwargs...) -> VNode

Container for a sub-menu.
"""
function SuiteMenubarSub(children...; class::String="", kwargs...)
    Div(Symbol("data-suite-menu-sub") => "",
        :class => cn("relative", class),
        kwargs...,
        children...)
end

"""
    SuiteMenubarSubTrigger(children...; inset, disabled, class, kwargs...) -> VNode

The item that opens a sub-menu.
"""
function SuiteMenubarSubTrigger(children...; inset::Bool=false, disabled::Bool=false, theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm",
        "outline-hidden select-none",
        "data-[state=open]:bg-warm-100 data-[state=open]:dark:bg-warm-800",
        "data-[highlighted]:bg-warm-100 data-[highlighted]:dark:bg-warm-800",
        "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
        inset && "pl-8",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-suite-menu-sub-trigger") => "",
        Symbol("data-state") => "closed",
        :role => "menuitem",
        Symbol("aria-haspopup") => "menu",
        Symbol("aria-expanded") => "false",
        :tabindex => "-1",
        :class => classes,
        (disabled ? [Symbol("data-disabled") => ""] : Pair{Symbol,String}[])...,
        kwargs...,
        children...,
        Therapy.RawHtml(_MENUBAR_CHEVRON_RIGHT),
    )
end

"""
    SuiteMenubarSubContent(children...; class, kwargs...) -> VNode

The floating panel of a sub-menu.
"""
function SuiteMenubarSubContent(children...; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
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
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-suite-menu-sub-content") => "",
        Symbol("data-state") => "closed",
        :role => "menu",
        :aria_orientation => "vertical",
        :tabindex => "-1",
        :style => "display:none",
        :class => classes,
        kwargs...,
        children...,
    )
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Menubar,
        "Menubar.jl",
        :js_runtime,
        "Horizontal menu bar with multiple dropdown menus and inter-menu navigation",
        Symbol[],
        [:Menu, :Menubar, :Floating, :DismissLayer, :ScrollLock, :FocusGuards],
        [:SuiteMenubar, :SuiteMenubarMenu, :SuiteMenubarTrigger, :SuiteMenubarContent,
         :SuiteMenubarGroup, :SuiteMenubarLabel, :SuiteMenubarItem,
         :SuiteMenubarCheckboxItem, :SuiteMenubarRadioGroup,
         :SuiteMenubarRadioItem, :SuiteMenubarItemIndicator,
         :SuiteMenubarSeparator, :SuiteMenubarShortcut,
         :SuiteMenubarSub, :SuiteMenubarSubTrigger,
         :SuiteMenubarSubContent],
    ))
end
