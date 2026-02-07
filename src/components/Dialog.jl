# SuiteDialog.jl — Suite.jl Dialog Component
#
# Tier: js_runtime (requires suite.js for focus trap, dismiss layer, scroll lock)
# Suite Dependencies: none (leaf component)
# JS Modules: FocusGuards, FocusTrap, DismissLayer, ScrollLock, Dialog
#
# Usage via package: using Suite; SuiteDialog(SuiteDialogTrigger(SuiteButton("Open")), SuiteDialogContent(...))
# Usage via extract: include("components/Dialog.jl"); SuiteDialog(...)
#
# Behavior (matches Radix Dialog):
#   - Modal by default: focus trapped, scroll locked, outside pointer disabled
#   - Escape key dismisses
#   - Click outside dismisses
#   - Focus auto-moves to first tabbable non-link element on open
#   - Focus returns to trigger on close

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteDialog, SuiteDialogTrigger, SuiteDialogContent,
       SuiteDialogHeader, SuiteDialogFooter, SuiteDialogTitle,
       SuiteDialogDescription, SuiteDialogClose

"""
    SuiteDialog(children...; class, kwargs...) -> VNode

A modal dialog overlay. Contains trigger, overlay, and content.

# Examples
```julia
SuiteDialog(
    SuiteDialogTrigger(SuiteButton("Open Dialog")),
    SuiteDialogContent(
        SuiteDialogHeader(
            SuiteDialogTitle("Edit Profile"),
            SuiteDialogDescription("Make changes to your profile here.")
        ),
        # ... form fields
        SuiteDialogFooter(
            SuiteDialogClose(SuiteButton(variant="outline", "Cancel")),
            SuiteButton("Save changes")
        )
    )
)
```
"""
function SuiteDialog(children...; class::String="", kwargs...)
    id = "suite-dialog-" * string(rand(UInt32), base=16)

    # Separate trigger from content children
    trigger_nodes = []
    content_nodes = []
    for child in children
        if child isa Therapy.VNode && haskey(child.props, Symbol("data-suite-dialog-trigger-wrapper"))
            push!(trigger_nodes, child)
        else
            push!(content_nodes, child)
        end
    end

    Div(:class => cn(class),
        Symbol("data-suite-dialog") => id,
        :style => "display:none",
        kwargs...,
        # Re-emit trigger with the dialog ID
        [_dialog_set_trigger_id(t, id) for t in trigger_nodes]...,
        content_nodes...,
    )
end

function _dialog_set_trigger_id(node, id)
    if node isa Therapy.VNode && haskey(node.props, Symbol("data-suite-dialog-trigger-wrapper"))
        # Find the actual trigger button inside and set its data-suite-dialog-trigger
        inner_props = copy(node.children[1].props)
        inner_props[Symbol("data-suite-dialog-trigger")] = id
        inner_props[Symbol("aria-haspopup")] = "dialog"
        inner_props[Symbol("aria-expanded")] = "false"
        inner_props[Symbol("data-state")] = "closed"
        return Therapy.VNode(node.children[1].tag, inner_props, node.children[1].children)
    end
    node
end

"""
    SuiteDialogTrigger(children...; class, kwargs...) -> VNode

The button that opens the dialog. Wrap around a SuiteButton or any clickable element.
"""
function SuiteDialogTrigger(children...; class::String="", kwargs...)
    # Wrap in a marker div so SuiteDialog can find and wire it
    Div(Symbol("data-suite-dialog-trigger-wrapper") => "",
        :style => "display:contents",
        Button(:type => "button",
               :class => cn(class),
               kwargs...,
               children...))
end

"""
    SuiteDialogContent(children...; class, kwargs...) -> VNode

The dialog content panel. Contains header, body, footer, and close button.
Renders with overlay backdrop. Hidden by default, shown by JS.
"""
function SuiteDialogContent(children...; class::String="", kwargs...)
    Div(
        # Overlay backdrop
        Div(Symbol("data-suite-dialog-overlay") => "",
            Symbol("data-state") => "closed",
            :class => "fixed inset-0 z-50 bg-warm-950/80 data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
            :style => "display:none",
        ),
        # Content
        Div(Symbol("data-suite-dialog-content") => "",
            Symbol("data-state") => "closed",
            :role => "dialog",
            :aria_modal => "true",
            :tabindex => "-1",
            :class => cn(
                "bg-warm-50 dark:bg-warm-950 text-warm-800 dark:text-warm-300",
                "data-[state=open]:animate-in data-[state=closed]:animate-out",
                "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
                "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
                "fixed top-[50%] left-[50%] z-50 grid w-full max-w-[calc(100%-2rem)]",
                "translate-x-[-50%] translate-y-[-50%]",
                "gap-4 rounded-lg border border-warm-200 dark:border-warm-700",
                "p-6 shadow-lg duration-200 outline-none sm:max-w-lg",
                class
            ),
            kwargs...,
            children...,
            # Default close button (X in top-right)
            Button(:type => "button",
                   Symbol("data-suite-dialog-close") => "",
                   :class => "absolute right-4 top-4 rounded-sm opacity-70 ring-offset-warm-50 dark:ring-offset-warm-950 transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-accent-600 focus:ring-offset-2 disabled:pointer-events-none",
                   :aria_label => "Close",
                   # X icon
                   Svg(:class => "h-4 w-4", :fill => "none", :viewBox => "0 0 24 24",
                       :stroke => "currentColor", :stroke_width => "2",
                       Path(:stroke_linecap => "round", :stroke_linejoin => "round",
                            :d => "M18 6L6 18M6 6l12 12")),
            ),
        ),
    )
end

"""
    SuiteDialogHeader(children...; class, kwargs...) -> VNode

Header section of the dialog (typically contains title and description).
"""
function SuiteDialogHeader(children...; class::String="", kwargs...)
    Div(:class => cn("flex flex-col gap-2 text-center sm:text-left", class),
        kwargs...,
        children...)
end

"""
    SuiteDialogFooter(children...; class, kwargs...) -> VNode

Footer section of the dialog (typically contains action buttons).
"""
function SuiteDialogFooter(children...; class::String="", kwargs...)
    Div(:class => cn("flex flex-col-reverse gap-2 sm:flex-row sm:justify-end", class),
        kwargs...,
        children...)
end

"""
    SuiteDialogTitle(children...; class, kwargs...) -> VNode

Title of the dialog. Renders as h2.
"""
function SuiteDialogTitle(children...; class::String="", kwargs...)
    H2(:class => cn("text-lg leading-none font-semibold", class),
       kwargs...,
       children...)
end

"""
    SuiteDialogDescription(children...; class, kwargs...) -> VNode

Description text for the dialog.
"""
function SuiteDialogDescription(children...; class::String="", kwargs...)
    P(:class => cn("text-warm-600 dark:text-warm-500 text-sm", class),
      kwargs...,
      children...)
end

"""
    SuiteDialogClose(children...; class, kwargs...) -> VNode

A button that closes the dialog when clicked. Wrap around a SuiteButton or any element.
"""
function SuiteDialogClose(children...; class::String="", kwargs...)
    Span(Symbol("data-suite-dialog-close") => "",
         :class => cn(class),
         :style => "display:contents",
         kwargs...,
         children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Dialog,
        "Dialog.jl",
        :js_runtime,
        "Modal dialog overlay with focus trap, scroll lock, and dismiss layer",
        Symbol[],
        [:FocusGuards, :FocusTrap, :DismissLayer, :ScrollLock, :Dialog],
        [:SuiteDialog, :SuiteDialogTrigger, :SuiteDialogContent,
         :SuiteDialogHeader, :SuiteDialogFooter, :SuiteDialogTitle,
         :SuiteDialogDescription, :SuiteDialogClose],
    ))
end
