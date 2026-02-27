# DropdownMenu.jl — Suite.jl Dropdown Menu Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; DropdownMenu(DropdownMenuTrigger(...), DropdownMenuContent(...))
# Usage via extract: include("components/DropdownMenu.jl"); DropdownMenu(...)
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
#   - Signal-driven: BindBool maps open signal to data-state and aria-expanded
#   - BindModal(mode=6) handles floating positioning + menu behavior + dismiss

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export DropdownMenu, DropdownMenuTrigger, DropdownMenuContent,
       DropdownMenuGroup, DropdownMenuLabel, DropdownMenuItem,
       DropdownMenuCheckboxItem, DropdownMenuRadioGroup,
       DropdownMenuRadioItem, DropdownMenuItemIndicator,
       DropdownMenuSeparator, DropdownMenuShortcut,
       DropdownMenuSub, DropdownMenuSubTrigger,
       DropdownMenuSubContent

# --- Chevron SVG ---
const _DROPDOWN_CHEVRON_RIGHT = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16" fill="none" class="ml-auto h-4 w-4"><path d="M6 12L10 8L6 4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>"""

# --- Check SVG ---
const _DROPDOWN_CHECK_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="h-4 w-4"><path d="M20 6L9 17l-5-5"/></svg>"""

# --- Radio Dot SVG ---
const _DROPDOWN_DOT_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor" class="h-2 w-2"><circle cx="12" cy="12" r="6"/></svg>"""

#   DropdownMenu(children...; class, kwargs...) -> IslandVNode
#
# A dropdown menu triggered by a button click.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# DropdownMenuTrigger and DropdownMenuContent children are auto-detected and injected
# with signal bindings for data-state, aria-expanded, and modal+menu behavior.
#
# Examples:
#   DropdownMenu(
#       DropdownMenuTrigger(Button(variant="outline", "Open")),
#       DropdownMenuContent(DropdownMenuItem("Profile"), DropdownMenuItem("Settings"))
#   )
@island function DropdownMenu(children...; class::String="", kwargs...)
    # Signal for open state (Int32: 0=closed, 1=open)
    is_open, set_open = create_signal(Int32(0))

    # Walk children to inject signal bindings
    for child in children
        if child isa VNode
            if haskey(child.props, Symbol("data-dropdown-menu-trigger-wrapper"))
                # Inject reactive bindings on trigger wrapper
                child.props[Symbol("data-state")] = BindBool(is_open, "closed", "open")
                child.props[:aria_expanded] = BindBool(is_open, "false", "true")
                child.props[:on_click] = () -> set_open(Int32(1) - is_open())
            else
                # Content — inject data-state binding
                _dropdown_inject_content_bindings!(child, is_open)
            end
        end
    end

    Div(Symbol("data-modal") => BindModal(is_open, Int32(6)),  # mode 6 = dropdown_menu
        :class => cn("", class),
        :style => "display:contents",
        kwargs...,
        children...)
end

# Walk children to find content and inject data-state binding
function _dropdown_inject_content_bindings!(node::VNode, is_open)
    if haskey(node.props, Symbol("data-dropdown-menu-content"))
        node.props[Symbol("data-state")] = BindBool(is_open, "closed", "open")
    end
    for child in node.children
        if child isa VNode
            _dropdown_inject_content_bindings!(child, is_open)
        end
    end
end

"""
    DropdownMenuTrigger(children...; class, kwargs...) -> VNode

The button that opens the dropdown menu.
"""
function DropdownMenuTrigger(children...; class::String="", kwargs...)
    Span(Symbol("data-dropdown-menu-trigger-wrapper") => "",
         :style => "display:contents",
         :class => cn("cursor-pointer", class),
         Symbol("data-state") => "closed",
         :aria_haspopup => "menu",
         :aria_expanded => "false",
         kwargs...,
         children...)
end

"""
    DropdownMenuContent(children...; side, side_offset, align, class, kwargs...) -> VNode

The floating menu content panel. Positioned relative to the trigger.
"""
function DropdownMenuContent(children...; side::String="bottom", side_offset::Int=4, align::String="start", theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "glass-panel",
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

    Div(Symbol("data-dropdown-menu-content") => "",
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
    DropdownMenuGroup(children...; class, kwargs...) -> VNode

Groups related menu items.
"""
function DropdownMenuGroup(children...; class::String="", kwargs...)
    Div(:role => "group",
        :class => cn(class),
        kwargs...,
        children...)
end

"""
    DropdownMenuLabel(children...; inset, class, kwargs...) -> VNode

A label for a group of menu items.
"""
function DropdownMenuLabel(children...; inset::Bool=false, class::String="", kwargs...)
    Div(:class => cn(
            "px-2 py-1.5 text-sm font-medium",
            inset && "pl-8",
            class
        ),
        kwargs...,
        children...)
end

"""
    DropdownMenuItem(children...; shortcut, disabled, class, kwargs...) -> VNode

A menu item. Optionally pass a `shortcut` string to display a keyboard shortcut.
"""
function DropdownMenuItem(children...; shortcut::String="", disabled::Bool=false, text_value::String="", theme::Symbol=:default, class::String="", kwargs...)
    item_children = collect(Any, children)
    if !isempty(shortcut)
        push!(item_children, Span(:class => "ml-auto text-xs tracking-widest text-warm-600 dark:text-warm-500",
                                   Symbol("data-menu-shortcut") => "",
                                   shortcut))
    end

    extra = Pair{Symbol,String}[]
    if disabled; push!(extra, Symbol("data-disabled") => ""); end
    if !isempty(text_value); push!(extra, Symbol("data-text-value") => text_value); end

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
        extra...,
        kwargs...,
        item_children...)
end

"""
    DropdownMenuCheckboxItem(children...; checked, disabled, class, kwargs...) -> VNode

A menu item with a checkbox. Toggles checked state on click.
"""
function DropdownMenuCheckboxItem(children...; checked::Bool=false, disabled::Bool=false, theme::Symbol=:default, class::String="", kwargs...)
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
        # Indicator
        Span(:class => "pointer-events-none absolute left-2 flex h-3.5 w-3.5 items-center justify-center",
             Symbol("data-menu-item-indicator") => "",
             :style => checked ? "" : "display:none",
             Therapy.RawHtml(_DROPDOWN_CHECK_SVG)),
        children...,
    )
end

"""
    DropdownMenuRadioGroup(children...; value, class, kwargs...) -> VNode

Container for radio menu items. Only one item can be checked at a time.
"""
function DropdownMenuRadioGroup(children...; value::String="", class::String="", kwargs...)
    Div(Symbol("data-menu-radio-group") => "",
        Symbol("data-value") => value,
        :role => "group",
        :class => cn(class),
        kwargs...,
        children...)
end

"""
    DropdownMenuRadioItem(children...; value, checked, disabled, class, kwargs...) -> VNode

A radio menu item within a RadioGroup.
"""
function DropdownMenuRadioItem(children...; value::String="", checked::Bool=false, disabled::Bool=false, theme::Symbol=:default, class::String="", kwargs...)
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
        # Indicator dot
        Span(:class => "pointer-events-none absolute left-2 flex h-3.5 w-3.5 items-center justify-center",
             Symbol("data-menu-item-indicator") => "",
             :style => checked ? "" : "display:none",
             Therapy.RawHtml(_DROPDOWN_DOT_SVG)),
        children...,
    )
end

"""
    DropdownMenuItemIndicator(children...; class, kwargs...) -> VNode

Custom indicator for checkbox/radio items. Replaces the default check/dot.
"""
function DropdownMenuItemIndicator(children...; class::String="", kwargs...)
    Span(:class => cn("pointer-events-none absolute left-2 flex h-3.5 w-3.5 items-center justify-center", class),
         Symbol("data-menu-item-indicator") => "",
         kwargs...,
         children...)
end

"""
    DropdownMenuSeparator(; class, kwargs...) -> VNode

A visual separator between menu items.
"""
function DropdownMenuSeparator(; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn("-mx-1 my-1 h-px bg-warm-200 dark:bg-warm-700", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-menu-separator") => "",
        :role => "separator",
        :class => classes,
        kwargs...)
end

"""
    DropdownMenuShortcut(children...; class, kwargs...) -> VNode

Displays a keyboard shortcut hint aligned to the right of a menu item.
"""
function DropdownMenuShortcut(children...; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn("ml-auto text-xs tracking-widest text-warm-600 dark:text-warm-500", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Span(:class => classes,
         Symbol("data-menu-shortcut") => "",
         kwargs...,
         children...)
end

"""
    DropdownMenuSub(children...; class, kwargs...) -> VNode

Container for a sub-menu. Contains a SubTrigger and SubContent.
"""
function DropdownMenuSub(children...; class::String="", kwargs...)
    Div(Symbol("data-menu-sub") => "",
        :class => cn("relative", class),
        kwargs...,
        children...)
end

"""
    DropdownMenuSubTrigger(children...; inset, disabled, class, kwargs...) -> VNode

The item that opens a sub-menu on hover or ArrowRight.
"""
function DropdownMenuSubTrigger(children...; inset::Bool=false, disabled::Bool=false, theme::Symbol=:default, class::String="", kwargs...)
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
        Therapy.RawHtml(_DROPDOWN_CHEVRON_RIGHT),
    )
end

"""
    DropdownMenuSubContent(children...; class, kwargs...) -> VNode

The floating panel of a sub-menu.
"""
function DropdownMenuSubContent(children...; theme::Symbol=:default, class::String="", kwargs...)
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

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :DropdownMenu,
        "DropdownMenu.jl",
        :island,
        "Click-triggered dropdown menu with keyboard nav, typeahead, and sub-menus",
        Symbol[],
        Symbol[],
        [:DropdownMenu, :DropdownMenuTrigger, :DropdownMenuContent,
         :DropdownMenuGroup, :DropdownMenuLabel, :DropdownMenuItem,
         :DropdownMenuCheckboxItem, :DropdownMenuRadioGroup,
         :DropdownMenuRadioItem, :DropdownMenuItemIndicator,
         :DropdownMenuSeparator, :DropdownMenuShortcut,
         :DropdownMenuSub, :DropdownMenuSubTrigger,
         :DropdownMenuSubContent],
    ))
end
