# Menubar.jl — Suite.jl Menubar Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Menubar(MenubarMenu(MenubarTrigger("File"), MenubarContent(...)), ...)
# Usage via extract: include("components/Menubar.jl"); Menubar(...)
#
# Behavior (matches Radix Menubar):
#   - Horizontal bar of menu triggers
#   - Click trigger to open/close its dropdown
#   - Arrow Left/Right to navigate between triggers (with loop)
#   - Pointer-enter rapid switching when any menu is open
#   - ArrowDown on trigger opens and focuses first item
#   - Arrow Left/Right within content navigates between menus
#   - Same item keyboard nav, typeahead, sub-menus as DropdownMenu
#   - Signal-driven: Int32 signal (0=none, N=menu N open)
#   - ShowDescendants binding handles show/hide + data-state on content children

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Menubar, MenubarMenu, MenubarTrigger, MenubarContent,
       MenubarGroup, MenubarLabel, MenubarItem,
       MenubarCheckboxItem, MenubarRadioGroup,
       MenubarRadioItem, MenubarItemIndicator,
       MenubarSeparator, MenubarShortcut,
       MenubarSub, MenubarSubTrigger,
       MenubarSubContent

# --- Chevron SVG ---
const _MENUBAR_CHEVRON_RIGHT = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16" fill="none" class="ml-auto h-4 w-4"><path d="M6 12L10 8L6 4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>"""
const _MENUBAR_CHECK_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="h-4 w-4"><path d="M20 6L9 17l-5-5"/></svg>"""
const _MENUBAR_DOT_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor" class="h-2 w-2"><circle cx="12" cy="12" r="6"/></svg>"""

#   Menubar(children...; loop, theme, class, kwargs...) -> IslandVNode
#
# A horizontal menu bar containing multiple menu triggers.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# MenubarMenu children are auto-detected and injected with signal bindings.
# Each menu trigger gets an on_click that toggles the active menu index.
# ShowDescendants binding handles show/hide + data-state on content descendants.
#
# Examples:
#   Menubar(
#       MenubarMenu(
#           MenubarTrigger("File"),
#           MenubarContent(MenubarItem("New Tab"), MenubarItem("New Window"))
#       ),
#       MenubarMenu(
#           MenubarTrigger("Edit"),
#           MenubarContent(MenubarItem("Undo"), MenubarItem("Redo"))
#       ),
#   )
@island function Menubar(children...; loop::Bool=true, theme::Symbol=:default, class::String="", kwargs...)
    # Signal for active menu index (Int32: 0=none, N=menu N is open)
    active_menu, set_active = create_signal(Int32(0))

    # Walk children to find MenubarMenu elements and assign indices
    menu_idx = Int32(0)
    for child in children
        if child isa VNode && haskey(child.props, Symbol("data-menubar-menu"))
            menu_idx += Int32(1)
            _menubar_inject_menu_bindings!(child, active_menu, set_active, menu_idx)
        end
    end

    classes = cn(
        "flex h-9 items-center gap-1 rounded-md p-1 shadow-xs",
        "bg-warm-50 dark:bg-warm-950",
        "border border-warm-200 dark:border-warm-700",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-menubar") => "",
        Symbol("data-show") => ShowDescendants(active_menu),  # show/hide + data-state binding (inline Wasm)
        Symbol("data-loop") => string(loop),
        :role => "menubar",
        :class => classes,
        kwargs...,
        children...)
end

# Walk a MenubarMenu's children to inject on_click on trigger markers
# and data-menubar-trigger on inner buttons
function _menubar_inject_menu_bindings!(menu_node::VNode, active_menu, set_active, idx)
    for child in menu_node.children
        if child isa VNode
            if haskey(child.props, Symbol("data-menubar-trigger-marker"))
                # Put on_click on the marker div — toggles this menu open/closed
                let i = idx
                    child.props[:on_click] = () -> set_active(i * (Int32(1) - Int32(active_menu() == i)))
                end
                # Find inner button and add trigger identification
                for inner in child.children
                    if inner isa VNode
                        inner.props[Symbol("data-menubar-trigger")] = ""
                        inner.props[Symbol("aria-haspopup")] = "menu"
                        inner.props[Symbol("aria-expanded")] = "false"
                        inner.props[Symbol("data-state")] = "closed"
                    end
                end
            end
        end
    end
end

"""
    MenubarMenu(children...; value, class, kwargs...) -> VNode

An individual menu within the menubar. Contains a trigger and content.
"""
function MenubarMenu(children...; value::String="", class::String="", kwargs...)
    Div(Symbol("data-menubar-menu") => "",
        Symbol("data-value") => value,
        :class => cn("relative", class),
        :style => "display:contents",
        kwargs...,
        children...)
end

"""
    MenubarTrigger(children...; disabled, class, kwargs...) -> VNode

The button that opens a menu within the menubar.
"""
function MenubarTrigger(children...; disabled::Bool=false, theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "flex items-center rounded-sm px-2 py-1 text-sm font-medium",
        "text-warm-800 dark:text-warm-300",
        "outline-hidden select-none cursor-pointer",
        "data-[state=open]:bg-warm-100 data-[state=open]:dark:bg-warm-800",
        "data-[highlighted]:bg-warm-100 data-[highlighted]:dark:bg-warm-800",
        "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
        "focus-visible:bg-warm-100 focus-visible:dark:bg-warm-800",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-menubar-trigger-marker") => "",
        :style => "display:contents",
        Therapy.Button(:type => "button",
               :role => "menuitem",
               :tabindex => "-1",
               :class => classes,
               (disabled ? [Symbol("data-disabled") => ""] : Pair{Symbol,String}[])...,
               kwargs...,
               children...))
end

"""
    MenubarContent(children...; side, side_offset, align, class, kwargs...) -> VNode

The floating dropdown content panel for a menubar menu.
"""
function MenubarContent(children...; side::String="bottom", side_offset::Int=4, align::String="start", theme::Symbol=:default, class::String="", kwargs...)
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

    Div(Symbol("data-menubar-content") => "",
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
    MenubarGroup(children...; class, kwargs...) -> VNode

Groups related menu items.
"""
function MenubarGroup(children...; class::String="", kwargs...)
    Div(:role => "group",
        :class => cn(class),
        kwargs...,
        children...)
end

"""
    MenubarLabel(children...; inset, class, kwargs...) -> VNode

A label for a group of menu items.
"""
function MenubarLabel(children...; inset::Bool=false, class::String="", kwargs...)
    Div(:class => cn(
            "px-2 py-1.5 text-sm font-medium",
            inset && "pl-8",
            class
        ),
        kwargs...,
        children...)
end

"""
    MenubarItem(children...; shortcut, disabled, class, kwargs...) -> VNode

A menu item within a menubar dropdown.
"""
function MenubarItem(children...; shortcut::String="", disabled::Bool=false, text_value::String="", theme::Symbol=:default, class::String="", kwargs...)
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
    MenubarCheckboxItem(children...; checked, disabled, class, kwargs...) -> VNode

A menu item with a checkbox.
"""
function MenubarCheckboxItem(children...; checked::Bool=false, disabled::Bool=false, theme::Symbol=:default, class::String="", kwargs...)
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
             Therapy.RawHtml(_MENUBAR_CHECK_SVG)),
        children...,
    )
end

"""
    MenubarRadioGroup(children...; value, class, kwargs...) -> VNode

Container for radio menu items.
"""
function MenubarRadioGroup(children...; value::String="", class::String="", kwargs...)
    Div(Symbol("data-menu-radio-group") => "",
        Symbol("data-value") => value,
        :role => "group",
        :class => cn(class),
        kwargs...,
        children...)
end

"""
    MenubarRadioItem(children...; value, checked, disabled, class, kwargs...) -> VNode

A radio menu item within a RadioGroup.
"""
function MenubarRadioItem(children...; value::String="", checked::Bool=false, disabled::Bool=false, theme::Symbol=:default, class::String="", kwargs...)
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
             Therapy.RawHtml(_MENUBAR_DOT_SVG)),
        children...,
    )
end

"""
    MenubarItemIndicator(children...; class, kwargs...) -> VNode

Custom indicator for checkbox/radio items.
"""
function MenubarItemIndicator(children...; class::String="", kwargs...)
    Span(:class => cn("pointer-events-none absolute left-2 flex h-3.5 w-3.5 items-center justify-center", class),
         Symbol("data-menu-item-indicator") => "",
         kwargs...,
         children...)
end

"""
    MenubarSeparator(; class, kwargs...) -> VNode

A visual separator between menu items.
"""
function MenubarSeparator(; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn("-mx-1 my-1 h-px bg-warm-200 dark:bg-warm-700", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-menu-separator") => "",
        :role => "separator",
        :class => classes,
        kwargs...)
end

"""
    MenubarShortcut(children...; class, kwargs...) -> VNode

Displays a keyboard shortcut hint.
"""
function MenubarShortcut(children...; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn("ml-auto text-xs tracking-widest text-warm-600 dark:text-warm-500", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Span(:class => classes,
         Symbol("data-menu-shortcut") => "",
         kwargs...,
         children...)
end

"""
    MenubarSub(children...; class, kwargs...) -> VNode

Container for a sub-menu.
"""
function MenubarSub(children...; class::String="", kwargs...)
    Div(Symbol("data-menu-sub") => "",
        :class => cn("relative", class),
        kwargs...,
        children...)
end

"""
    MenubarSubTrigger(children...; inset, disabled, class, kwargs...) -> VNode

The item that opens a sub-menu.
"""
function MenubarSubTrigger(children...; inset::Bool=false, disabled::Bool=false, theme::Symbol=:default, class::String="", kwargs...)
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
        Therapy.RawHtml(_MENUBAR_CHEVRON_RIGHT),
    )
end

"""
    MenubarSubContent(children...; class, kwargs...) -> VNode

The floating panel of a sub-menu.
"""
function MenubarSubContent(children...; theme::Symbol=:default, class::String="", kwargs...)
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

# --- Props Transform (counts menus for while loop) ---
const _MENUBAR_PROPS_TRANSFORM = (props, args) -> begin
    count = 0
    for arg in args
        if arg isa VNode && haskey(arg.props, Symbol("data-menubar-menu"))
            count += 1
        end
    end
    props[:n_menus] = count
end


# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Menubar,
        "Menubar.jl",
        :island,
        "Horizontal menu bar with multiple dropdown menus and inter-menu navigation",
        Symbol[],
        Symbol[],
        [:Menubar, :MenubarMenu, :MenubarTrigger, :MenubarContent,
         :MenubarGroup, :MenubarLabel, :MenubarItem,
         :MenubarCheckboxItem, :MenubarRadioGroup,
         :MenubarRadioItem, :MenubarItemIndicator,
         :MenubarSeparator, :MenubarShortcut,
         :MenubarSub, :MenubarSubTrigger,
         :MenubarSubContent],
    ))
end
