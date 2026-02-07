# SuiteCommand.jl — Suite.jl Command Component (cmdk-style command palette)
#
# Tier: js_runtime (requires suite.js for filtering, scoring, keyboard nav)
# Suite Dependencies: Dialog (for CommandDialog variant)
# JS Modules: Command
#
# Usage via package: using Suite; SuiteCommand(...)
# Usage via extract: include("components/Command.jl"); SuiteCommand(...)
#
# Behavior (matches cmdk):
#   - Search input filters items using fuzzy scoring
#   - Arrow key navigation through filtered items (wraps)
#   - Enter key selects highlighted item
#   - Groups auto-hide when no matching items
#   - Empty state shown when no results
#   - CommandDialog wraps Command inside a Dialog

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteCommand, SuiteCommandInput, SuiteCommandList,
       SuiteCommandEmpty, SuiteCommandGroup, SuiteCommandItem,
       SuiteCommandSeparator, SuiteCommandShortcut, SuiteCommandDialog

# --- SVG Icons ---
const _COMMAND_SEARCH_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mr-2 size-4 shrink-0 opacity-50"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>"""

"""
    SuiteCommand(children...; should_filter, loop, class, kwargs...) -> VNode

A command palette / search interface for filtering and selecting items.

# Arguments
- `should_filter::Bool=true`: Whether to enable fuzzy filtering on search
- `loop::Bool=true`: Whether keyboard navigation wraps around

# Examples
```julia
SuiteCommand(
    SuiteCommandInput(placeholder="Type a command or search..."),
    SuiteCommandList(
        SuiteCommandEmpty("No results found."),
        SuiteCommandGroup(heading="Suggestions",
            SuiteCommandItem("Calendar", value="calendar"),
            SuiteCommandItem("Search Emoji", value="emoji"),
            SuiteCommandItem("Calculator", value="calculator"),
        ),
        SuiteCommandSeparator(),
        SuiteCommandGroup(heading="Settings",
            SuiteCommandItem("Profile", value="profile"),
            SuiteCommandItem("Billing", value="billing"),
            SuiteCommandItem("Settings", value="settings"),
        ),
    )
)
```
"""
function SuiteCommand(children...; should_filter::Bool=true, loop::Bool=true,
                      theme::Symbol=:default, class::String="", kwargs...)
    id = "suite-command-" * string(rand(UInt32), base=16)

    classes = cn(
        "bg-warm-50 dark:bg-warm-900 text-warm-800 dark:text-warm-300",
        "flex h-full w-full flex-col overflow-hidden rounded-md",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-suite-command") => id,
        Symbol("data-suite-command-filter") => should_filter ? "true" : "false",
        Symbol("data-suite-command-loop") => loop ? "true" : "false",
        :class => classes,
        kwargs...,
        children...,
    )
end

"""
    SuiteCommandInput(; placeholder, class, kwargs...) -> VNode

The search input for the command palette.
"""
function SuiteCommandInput(; placeholder::String="", theme::Symbol=:default, class::String="", kwargs...)
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
        Input(Symbol("data-suite-command-input") => "",
              :type => "text",
              :placeholder => placeholder,
              :autocomplete => "off",
              :autocorrect => "off",
              :spellcheck => "false",
              :class => input_classes,
              kwargs...))
end

"""
    SuiteCommandList(children...; class, kwargs...) -> VNode

The scrollable container for command items and groups.
"""
function SuiteCommandList(children...; class::String="", kwargs...)
    Div(Symbol("data-suite-command-list") => "",
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
    SuiteCommandEmpty(children...; class, kwargs...) -> VNode

Shown when the search yields no matching items.
"""
function SuiteCommandEmpty(children...; class::String="", kwargs...)
    Div(Symbol("data-suite-command-empty") => "",
        :role => "presentation",
        :class => cn("py-6 text-center text-sm", class),
        :style => "display:none",
        kwargs...,
        children...,
    )
end

"""
    SuiteCommandGroup(children...; heading, class, kwargs...) -> VNode

A group of related command items with an optional heading.

# Arguments
- `heading::String=""`: Group heading text
"""
function SuiteCommandGroup(children...; heading::String="", theme::Symbol=:default, class::String="", kwargs...)
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

    Div(Symbol("data-suite-command-group") => "",
        :role => "group",
        (isempty(heading) ? () : (Symbol("aria-labelledby") => heading_id,))...,
        :class => group_classes,
        kwargs...,
        (isempty(heading) ? () : (
            Div(:role => "presentation",
                :id => heading_id,
                Symbol("data-suite-command-group-heading") => "",
                :class => heading_classes,
                heading),
        ))...,
        children...,
    )
end

"""
    SuiteCommandItem(children...; value, disabled, keywords, class, kwargs...) -> VNode

An individual item in the command palette.

# Arguments
- `value::String=""`: The value for filtering/selection (defaults to text content)
- `disabled::Bool=false`: Whether this item is disabled
- `keywords::Vector{String}=String[]`: Additional searchable text
"""
function SuiteCommandItem(children...; value::String="", disabled::Bool=false,
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

    Div(Symbol("data-suite-command-item") => "",
        Symbol("data-suite-command-item-value") => value,
        (isempty(keywords) ? () : (Symbol("data-suite-command-item-keywords") => join(keywords, ","),))...,
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
    SuiteCommandSeparator(; class, kwargs...) -> VNode

A visual separator between command groups.
"""
function SuiteCommandSeparator(; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn("bg-warm-200 dark:bg-warm-700 -mx-1 h-px", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-suite-command-separator") => "",
        :role => "separator",
        :class => classes,
        kwargs...)
end

"""
    SuiteCommandShortcut(children...; class, kwargs...) -> VNode

Displays a keyboard shortcut alongside a command item.
"""
function SuiteCommandShortcut(children...; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn("text-warm-600 dark:text-warm-500 ml-auto text-xs tracking-widest", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Span(Symbol("data-suite-command-shortcut") => "",
         :class => classes,
         children...)
end

"""
    SuiteCommandDialog(children...; class, kwargs...) -> VNode

A command palette inside a dialog overlay. Useful for ⌘K command palette pattern.

The dialog is triggered externally (e.g. via keyboard shortcut).
Uses SuiteDialog internally.
"""
function SuiteCommandDialog(children...; theme::Symbol=:default, class::String="", kwargs...)
    id = "suite-command-dialog-" * string(rand(UInt32), base=16)

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

    # Overlay + centered command palette
    Div(Symbol("data-suite-command-dialog") => id,
        Symbol("data-state") => "closed",
        :style => "display:none",
        :class => "fixed inset-0 z-50",
        # Overlay
        Div(:class => overlay_classes,
            Symbol("data-suite-command-dialog-overlay") => id),
        # Content
        Div(:class => content_classes,
            Symbol("data-suite-command-dialog-content") => id,
            kwargs...,
            SuiteCommand(children...; theme=theme),
        ),
    )
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Command,
        "Command.jl",
        :js_runtime,
        "Command palette with fuzzy search, keyboard navigation, and item filtering",
        Symbol[:Dialog],
        [:Command],
        [:SuiteCommand, :SuiteCommandInput, :SuiteCommandList,
         :SuiteCommandEmpty, :SuiteCommandGroup, :SuiteCommandItem,
         :SuiteCommandSeparator, :SuiteCommandShortcut, :SuiteCommandDialog],
    ))
end
