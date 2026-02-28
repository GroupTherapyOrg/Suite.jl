# Command.jl — Suite.jl Command Component (cmdk-style command palette)
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none
# JS Modules: none
#
# Usage via package: using Suite; Command(...)
# Usage via extract: include("components/Command.jl"); Command(...)
#
# Behavior (matches cmdk):
#   - Search input filters items using fuzzy scoring
#   - Arrow key navigation through filtered items (wraps)
#   - Enter key selects highlighted item
#   - Groups auto-hide when no matching items
#   - Empty state shown when no results
#   - CommandDialog wraps Command inside a modal overlay
#   - Signal-driven: BindModal(mode=11) handles filtering/nav, BindModal(mode=12) handles dialog

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Command, CommandInput, CommandList,
       CommandEmpty, CommandGroup, CommandItem,
       CommandSeparator, CommandShortcut, CommandDialog

# --- SVG Icons ---
const _COMMAND_SEARCH_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mr-2 size-4 shrink-0 opacity-50"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>"""

#   Command(children...; should_filter, loop, class, kwargs...) -> IslandVNode
#
# A command palette / search interface for filtering and selecting items.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# BindModal(mode=11) handles fuzzy filtering, keyboard navigation, and item highlighting.
#
# Examples:
#   Command(
#       CommandInput(placeholder="Type a command or search..."),
#       CommandList(CommandEmpty("No results."), CommandGroup(heading="Suggestions",
#           CommandItem("Calendar", value="calendar")))
#   )
@island function Command(children...; should_filter::Bool=true, loop::Bool=true,
                      theme::Symbol=:default, class::String="", kwargs...)
    # Signal starts at 1 = "activated" — mode=11 installs behaviors immediately
    activated, _set_activated = create_signal(Int32(1))

    classes = cn(
        "glass-panel-elevated",
        "bg-warm-50 dark:bg-warm-900 text-warm-800 dark:text-warm-300",
        "flex h-full w-full flex-col overflow-hidden rounded-md",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-modal") => BindModal(activated, Int32(11)),  # mode 11 = command
        Symbol("data-command") => "",
        Symbol("data-command-filter") => should_filter ? "true" : "false",
        Symbol("data-command-loop") => loop ? "true" : "false",
        :class => classes,
        kwargs...,
        children...,
    )
end

"""
    CommandInput(; placeholder, class, kwargs...) -> VNode

The search input for the command palette.
"""
function CommandInput(; placeholder::String="", theme::Symbol=:default, class::String="", kwargs...)
    wrapper_classes = "flex h-9 items-center gap-2 border-b border-warm-200 dark:border-warm-700 px-3"
    input_classes = cn(
        "placeholder:text-warm-600 dark:placeholder:text-warm-500",
        "flex h-10 w-full rounded-md bg-transparent py-3 text-sm",
        "outline-hidden disabled:cursor-not-allowed disabled:opacity-50",
        class
    )
    if theme !== :default
        t = get_theme(theme)
        wrapper_classes = apply_theme(wrapper_classes, t)
        input_classes = apply_theme(input_classes, t)
    end

    Div(:class => wrapper_classes,
        Therapy.RawHtml(_COMMAND_SEARCH_SVG),
        Therapy.Input(Symbol("data-command-input") => "",
              :type => "text",
              :placeholder => placeholder,
              :autocomplete => "off",
              :autocorrect => "off",
              :spellcheck => "false",
              :class => input_classes,
              kwargs...))
end

"""
    CommandList(children...; class, kwargs...) -> VNode

The scrollable container for command items and groups.
"""
function CommandList(children...; class::String="", kwargs...)
    Div(Symbol("data-command-list") => "",
        :role => "listbox",
        Symbol("aria-label") => "Suggestions",
        :class => cn(
            "max-h-[300px] scroll-py-1 overflow-x-hidden overflow-y-auto",
            class
        ),
        kwargs...,
        children...,
    )
end

"""
    CommandEmpty(children...; class, kwargs...) -> VNode

Shown when the search yields no matching items.
"""
function CommandEmpty(children...; class::String="", kwargs...)
    Div(Symbol("data-command-empty") => "",
        :role => "presentation",
        :class => cn("py-6 text-center text-sm", class),
        :style => "display:none",
        kwargs...,
        children...,
    )
end

"""
    CommandGroup(children...; heading, class, kwargs...) -> VNode

A group of related command items with an optional heading.

# Arguments
- `heading::String=""`: Group heading text
"""
function CommandGroup(children...; heading::String="", theme::Symbol=:default, class::String="", kwargs...)
    group_id = "suite-cmd-group-" * string(rand(UInt32), base=16)
    heading_id = group_id * "-heading"

    group_classes = cn(
        "text-warm-800 dark:text-warm-300 overflow-hidden p-1",
        class
    )
    heading_classes = "text-warm-600 dark:text-warm-500 px-2 py-1.5 text-xs font-medium"
    if theme !== :default
        t = get_theme(theme)
        group_classes = apply_theme(group_classes, t)
        heading_classes = apply_theme(heading_classes, t)
    end

    Div(Symbol("data-command-group") => "",
        :role => "group",
        (isempty(heading) ? () : (Symbol("aria-labelledby") => heading_id,))...,
        :class => group_classes,
        kwargs...,
        (isempty(heading) ? () : (
            Div(:role => "presentation",
                :id => heading_id,
                Symbol("data-command-group-heading") => "",
                :class => heading_classes,
                heading),
        ))...,
        children...,
    )
end

"""
    CommandItem(children...; value, disabled, keywords, class, kwargs...) -> VNode

An individual item in the command palette.

# Arguments
- `value::String=""`: The value for filtering/selection (defaults to text content)
- `disabled::Bool=false`: Whether this item is disabled
- `keywords::Vector{String}=String[]`: Additional searchable text
"""
function CommandItem(children...; value::String="", disabled::Bool=false,
                          keywords::Vector{String}=String[], theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "data-[selected=true]:bg-warm-100 dark:data-[selected=true]:bg-warm-800",
        "data-[selected=true]:text-warm-800 dark:data-[selected=true]:text-warm-300",
        "relative flex cursor-pointer items-center gap-2 rounded-sm px-2 py-1.5 text-sm",
        "outline-hidden select-none",
        "data-[disabled=true]:pointer-events-none data-[disabled=true]:opacity-50",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-command-item") => "",
        Symbol("data-command-item-value") => value,
        (isempty(keywords) ? () : (Symbol("data-command-item-keywords") => join(keywords, ","),))...,
        :role => "option",
        Symbol("aria-selected") => "false",
        :tabindex => "-1",
        :class => classes,
        (disabled ? (Symbol("data-disabled") => "true",) : ())...,
        kwargs...,
        children...,
    )
end

"""
    CommandSeparator(; class, kwargs...) -> VNode

A visual separator between command groups.
"""
function CommandSeparator(; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn("bg-warm-200 dark:bg-warm-700 -mx-1 h-px", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-command-separator") => "",
        :role => "separator",
        :class => classes,
        kwargs...)
end

"""
    CommandShortcut(children...; class, kwargs...) -> VNode

Displays a keyboard shortcut alongside a command item.
"""
function CommandShortcut(children...; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn("text-warm-600 dark:text-warm-500 ml-auto text-xs tracking-widest", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Span(Symbol("data-command-shortcut") => "",
         :class => classes,
         children...)
end

#   CommandDialog(children...; class, kwargs...) -> IslandVNode
#
# A command palette inside a dialog overlay. Useful for ⌘K command palette pattern.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# BindModal(mode=12) handles dialog open/close, scroll lock, Escape/overlay dismiss.
# The embedded Command @island (mode=11) handles filtering and keyboard navigation.
#
# To open programmatically, click the trigger marker or use island._suiteOpen().
@island function CommandDialog(children...; theme::Symbol=:default, class::String="", kwargs...)
    is_open, set_open = create_signal(Int32(0))

    function toggle_dialog()
        set_open(Int32(1) - is_open())
    end

    overlay_classes = "fixed inset-0 bg-warm-950/80 data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0"
    content_classes = cn(
        "fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2",
        "z-50 w-full max-w-lg",
        "data-[state=open]:animate-in data-[state=closed]:animate-out",
        "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
        "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
        "data-[state=closed]:slide-out-to-left-1/2 data-[state=closed]:slide-out-to-top-[48%]",
        "data-[state=open]:slide-in-from-left-1/2 data-[state=open]:slide-in-from-top-[48%]",
        class
    )
    if theme !== :default
        t = get_theme(theme)
        overlay_classes = apply_theme(overlay_classes, t)
        content_classes = apply_theme(content_classes, t)
    end

    Div(Symbol("data-modal") => BindModal(is_open, Int32(12)),  # mode 12 = command_dialog
        # Hidden trigger marker for programmatic toggling
        Span(Symbol("data-command-dialog-trigger-marker") => "",
             :style => "display:none",
             :on_click => toggle_dialog),
        # Dialog overlay + content (initially hidden)
        Div(Symbol("data-command-dialog") => "",
            Symbol("data-state") => "closed",
            :style => "display:none",
            :class => "fixed inset-0 z-50",
            # Overlay
            Div(:class => overlay_classes,
                Symbol("data-command-dialog-overlay") => ""),
            # Content with embedded Command
            Div(:class => content_classes,
                Symbol("data-command-dialog-content") => "",
                kwargs...,
                Command(children...; theme=theme),
            ),
        ),
    )
end


# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Command,
        "Command.jl",
        :island,
        "Command palette with fuzzy search, keyboard navigation, and item filtering",
        Symbol[],
        Symbol[],
        [:Command, :CommandInput, :CommandList,
         :CommandEmpty, :CommandGroup, :CommandItem,
         :CommandSeparator, :CommandShortcut, :CommandDialog],
    ))
end
