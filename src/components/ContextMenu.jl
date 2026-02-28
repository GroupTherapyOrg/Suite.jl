# ContextMenu.jl — Suite.jl Context Menu Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; ContextMenu(ContextMenuTrigger(...), ContextMenuContent(...))
# Usage via extract: include("components/ContextMenu.jl"); ContextMenu(...)
#
# Behavior (matches Radix ContextMenu):
#   - Right-click on trigger area opens at pointer position
#   - Touch long-press (700ms) opens at touch position
#   - Same keyboard navigation as DropdownMenu
#   - Escape/click-outside dismiss
#   - Sub-menu support
#   - Signal-driven: BindBool maps open signal to data-state and aria-expanded
#   - BindModal(mode=7) handles contextmenu positioning + menu behavior + dismiss

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export ContextMenu, ContextMenuTrigger, ContextMenuContent,
       ContextMenuGroup, ContextMenuLabel, ContextMenuItem,
       ContextMenuCheckboxItem, ContextMenuRadioGroup,
       ContextMenuRadioItem, ContextMenuItemIndicator,
       ContextMenuSeparator, ContextMenuShortcut,
       ContextMenuSub, ContextMenuSubTrigger,
       ContextMenuSubContent

# Re-use SVGs from DropdownMenu (they're the same icons)
const _CONTEXT_CHEVRON_RIGHT = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16" fill="none" class="ml-auto h-4 w-4"><path d="M6 12L10 8L6 4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>"""
const _CONTEXT_CHECK_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="h-4 w-4"><path d="M20 6L9 17l-5-5"/></svg>"""
const _CONTEXT_DOT_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor" class="h-2 w-2"><circle cx="12" cy="12" r="6"/></svg>"""

#   ContextMenu(children...; class, kwargs...) -> IslandVNode
#
# A context menu triggered by right-click (or long-press on touch).
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# ContextMenuTrigger and ContextMenuContent children are auto-detected and injected
# with signal bindings for data-state and modal+menu behavior.
#
# Examples:
#   ContextMenu(
#       ContextMenuTrigger(Div("Right click here")),
#       ContextMenuContent(ContextMenuItem("Cut"), ContextMenuItem("Copy"))
#   )
@island function ContextMenu(children...; class::String="", kwargs...)
    # Signal for open state (Int32: 0=closed, 1=open)
    is_open, set_open = create_signal(Int32(0))

    # Provide context for child islands (single key with getter+setter tuple)
    provide_context(:contextmenu, (is_open, set_open))

    Div(Symbol("data-modal") => BindModal(is_open, Int32(7)),  # mode 7 = context_menu
        :class => cn("", class),
        :style => "display:contents",
        kwargs...,
        children...)
end

#   ContextMenuTrigger(children...; class, kwargs...) -> IslandVNode
#
# The area that responds to right-click. Can wrap any content.
# Child island: owns signal + BindBool + on_click handler (compilable body).
# At runtime, context sharing connects to parent ContextMenu's signal.
@island function ContextMenuTrigger(children...; class::String="", kwargs...)
    # Read parent's signal from context (SSR) or create own (Wasm compilation)
    is_open, set_open = use_context_signal(:contextmenu, Int32(0))

    Span(Symbol("data-context-menu-trigger-wrapper") => "",
         :style => "display:contents",
         :class => cn(class),
         Symbol("data-state") => BindBool(is_open, "closed", "open"),
         :on_click => () -> set_open(Int32(1) - is_open()),
         kwargs...,
         children...)
end

"""
    ContextMenuContent(children...; class, kwargs...) -> VNode

The floating menu content panel. Positioned at the right-click location.
"""
function ContextMenuContent(children...; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
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
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-context-menu-content") => "",
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
    ContextMenuGroup(children...; class, kwargs...) -> VNode

Groups related menu items.
"""
function ContextMenuGroup(children...; class::String="", kwargs...)
    Div(:role => "group",
        :class => cn(class),
        kwargs...,
        children...)
end

"""
    ContextMenuLabel(children...; inset, class, kwargs...) -> VNode

A label for a group of menu items.
"""
function ContextMenuLabel(children...; inset::Bool=false, theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "px-2 py-1.5 text-sm font-medium text-warm-800 dark:text-warm-300",
        inset && "pl-8",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(:class => classes,
        kwargs...,
        children...)
end

"""
    ContextMenuItem(children...; shortcut, disabled, class, kwargs...) -> VNode

A menu item. Optionally pass a `shortcut` string to display a keyboard shortcut.
"""
function ContextMenuItem(children...; shortcut::String="", disabled::Bool=false, text_value::String="", theme::Symbol=:default, class::String="", kwargs...)
    item_children = collect(Any, children)
    if !isempty(shortcut)
        push!(item_children, Span(:class => "ml-auto text-xs tracking-widest text-warm-600 dark:text-warm-500",
                                   Symbol("data-menu-shortcut") => "",
                                   shortcut))
    end

    classes = cn(
        "relative flex cursor-pointer items-center gap-2 rounded-sm px-2 py-1.5",
        "text-sm outline-hidden select-none",
        "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
        "data-[highlighted]:bg-warm-100 data-[highlighted]:dark:bg-warm-800",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-menu-item") => "",
        :role => "menuitem",
        :tabindex => "-1",
        :class => classes,
        (disabled ? [Symbol("data-disabled") => ""] : Pair{Symbol,String}[])...,
        (!isempty(text_value) ? [Symbol("data-text-value") => text_value] : Pair{Symbol,String}[])...,
        kwargs...,
        item_children...)
end

"""
    ContextMenuCheckboxItem(children...; checked, disabled, class, kwargs...) -> VNode

A menu item with a checkbox.
"""
function ContextMenuCheckboxItem(children...; checked::Bool=false, disabled::Bool=false, theme::Symbol=:default, class::String="", kwargs...)
    state = checked ? "checked" : "unchecked"

    classes = cn(
        "relative flex cursor-pointer items-center gap-2 rounded-sm py-1.5 pr-2 pl-8",
        "text-sm outline-hidden select-none",
        "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
        "data-[highlighted]:bg-warm-100 data-[highlighted]:dark:bg-warm-800",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-menu-checkbox-item") => "",
        Symbol("data-state") => state,
        :role => "menuitemcheckbox",
        Symbol("aria-checked") => string(checked),
        :tabindex => "-1",
        :class => classes,
        (disabled ? [Symbol("data-disabled") => ""] : Pair{Symbol,String}[])...,
        kwargs...,
        Span(:class => "pointer-events-none absolute left-2 flex h-3.5 w-3.5 items-center justify-center",
             Symbol("data-menu-item-indicator") => "",
             :style => checked ? "" : "display:none",
             Therapy.RawHtml(_CONTEXT_CHECK_SVG)),
        children...,
    )
end

"""
    ContextMenuRadioGroup(children...; value, class, kwargs...) -> VNode

Container for radio menu items.
"""
function ContextMenuRadioGroup(children...; value::String="", class::String="", kwargs...)
    Div(Symbol("data-menu-radio-group") => "",
        Symbol("data-value") => value,
        :role => "group",
        :class => cn(class),
        kwargs...,
        children...)
end

"""
    ContextMenuRadioItem(children...; value, checked, disabled, class, kwargs...) -> VNode

A radio menu item within a RadioGroup.
"""
function ContextMenuRadioItem(children...; value::String="", checked::Bool=false, disabled::Bool=false, theme::Symbol=:default, class::String="", kwargs...)
    state = checked ? "checked" : "unchecked"

    classes = cn(
        "relative flex cursor-pointer items-center gap-2 rounded-sm py-1.5 pr-2 pl-8",
        "text-sm outline-hidden select-none",
        "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
        "data-[highlighted]:bg-warm-100 data-[highlighted]:dark:bg-warm-800",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-menu-radio-item") => "",
        Symbol("data-value") => value,
        Symbol("data-state") => state,
        :role => "menuitemradio",
        Symbol("aria-checked") => string(checked),
        :tabindex => "-1",
        :class => classes,
        (disabled ? [Symbol("data-disabled") => ""] : Pair{Symbol,String}[])...,
        kwargs...,
        Span(:class => "pointer-events-none absolute left-2 flex h-3.5 w-3.5 items-center justify-center",
             Symbol("data-menu-item-indicator") => "",
             :style => checked ? "" : "display:none",
             Therapy.RawHtml(_CONTEXT_DOT_SVG)),
        children...,
    )
end

"""
    ContextMenuItemIndicator(children...; class, kwargs...) -> VNode

Custom indicator for checkbox/radio items.
"""
function ContextMenuItemIndicator(children...; class::String="", kwargs...)
    Span(:class => cn("pointer-events-none absolute left-2 flex h-3.5 w-3.5 items-center justify-center", class),
         Symbol("data-menu-item-indicator") => "",
         kwargs...,
         children...)
end

"""
    ContextMenuSeparator(; class, kwargs...) -> VNode

A visual separator between menu items.
"""
function ContextMenuSeparator(; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn("-mx-1 my-1 h-px bg-warm-200 dark:bg-warm-700", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-menu-separator") => "",
        :role => "separator",
        :class => classes,
        kwargs...)
end

"""
    ContextMenuShortcut(children...; class, kwargs...) -> VNode

Displays a keyboard shortcut hint.
"""
function ContextMenuShortcut(children...; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn("ml-auto text-xs tracking-widest text-warm-600 dark:text-warm-500", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Span(:class => classes,
         Symbol("data-menu-shortcut") => "",
         kwargs...,
         children...)
end

"""
    ContextMenuSub(children...; class, kwargs...) -> VNode

Container for a sub-menu.
"""
function ContextMenuSub(children...; class::String="", kwargs...)
    Div(Symbol("data-menu-sub") => "",
        :class => cn("relative", class),
        kwargs...,
        children...)
end

"""
    ContextMenuSubTrigger(children...; inset, disabled, class, kwargs...) -> VNode

The item that opens a sub-menu.
"""
function ContextMenuSubTrigger(children...; inset::Bool=false, disabled::Bool=false, theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "flex cursor-pointer items-center gap-2 rounded-sm px-2 py-1.5 text-sm",
        "outline-hidden select-none",
        "data-[state=open]:bg-warm-100 data-[state=open]:dark:bg-warm-800",
        "data-[highlighted]:bg-warm-100 data-[highlighted]:dark:bg-warm-800",
        "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
        inset && "pl-8",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-menu-sub-trigger") => "",
        Symbol("data-state") => "closed",
        :role => "menuitem",
        Symbol("aria-haspopup") => "menu",
        Symbol("aria-expanded") => "false",
        :tabindex => "-1",
        :class => classes,
        (disabled ? [Symbol("data-disabled") => ""] : Pair{Symbol,String}[])...,
        kwargs...,
        children...,
        Therapy.RawHtml(_CONTEXT_CHEVRON_RIGHT),
    )
end

"""
    ContextMenuSubContent(children...; class, kwargs...) -> VNode

The floating panel of a sub-menu.
"""
function ContextMenuSubContent(children...; theme::Symbol=:default, class::String="", kwargs...)
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

    Div(Symbol("data-menu-sub-content") => "",
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

# --- Hydration Bodies (Wasm compilation) ---

# Parent island: Div(BindModal) wrapping children (nested islands handle their own bindings)
const _CONTEXTMENU_HYDRATION_BODY = quote
    is_open, set_open = create_signal(Int32(0))
    Div(
        Symbol("data-modal") => BindModal(is_open, Int32(7)),
        children,
    )
end

# Child island: Span(BindBool + click toggle + children)
const _CONTEXTMENUTRIGGER_HYDRATION_BODY = quote
    is_open, set_open = create_signal(Int32(0))
    Span(
        Symbol("data-state") => BindBool(is_open, "closed", "open"),
        :on_click => () -> set_open(Int32(1) - is_open()),
        children,
    )
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :ContextMenu,
        "ContextMenu.jl",
        :island,
        "Right-click context menu with keyboard nav, typeahead, and sub-menus",
        Symbol[],
        Symbol[],
        [:ContextMenu, :ContextMenuTrigger, :ContextMenuContent,
         :ContextMenuGroup, :ContextMenuLabel, :ContextMenuItem,
         :ContextMenuCheckboxItem, :ContextMenuRadioGroup,
         :ContextMenuRadioItem, :ContextMenuItemIndicator,
         :ContextMenuSeparator, :ContextMenuShortcut,
         :ContextMenuSub, :ContextMenuSubTrigger,
         :ContextMenuSubContent],
    ))
end
