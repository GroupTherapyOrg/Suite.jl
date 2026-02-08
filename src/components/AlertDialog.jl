# AlertDialog.jl — Suite.jl Alert Dialog Component
#
# Tier: js_runtime (requires suite.js)
# Suite Dependencies: none (leaf component)
# JS Modules: FocusGuards, FocusTrap, DismissLayer, ScrollLock, AlertDialog
#
# Usage via package: using Suite; AlertDialog(...)
# Usage via extract: include("components/AlertDialog.jl"); AlertDialog(...)
#
# Behavior (matches Radix AlertDialog):
#   - Always modal: focus trapped, scroll locked
#   - Escape key does NOT dismiss (unlike Dialog)
#   - Click outside does NOT dismiss (unlike Dialog)
#   - Focus auto-moves to Cancel button on open (not first tabbable)
#   - Can only be closed via Action or Cancel button
#   - role="alertdialog" (not "dialog")

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export AlertDialog, AlertDialogTrigger, AlertDialogContent,
       AlertDialogHeader, AlertDialogFooter, AlertDialogTitle,
       AlertDialogDescription, AlertDialogAction, AlertDialogCancel

"""
    AlertDialog(children...; class, kwargs...) -> VNode

A modal alert dialog that requires explicit user action to dismiss.
Cannot be dismissed by Escape key or clicking outside.

# Examples
```julia
AlertDialog(
    AlertDialogTrigger(Button(variant="destructive", "Delete Account")),
    AlertDialogContent(
        AlertDialogHeader(
            AlertDialogTitle("Are you absolutely sure?"),
            AlertDialogDescription("This action cannot be undone.")
        ),
        AlertDialogFooter(
            AlertDialogCancel(Button(variant="outline", "Cancel")),
            AlertDialogAction(Button(variant="destructive", "Delete"))
        )
    )
)
```
"""
function AlertDialog(children...; class::String="", kwargs...)
    id = "suite-alert-dialog-" * string(rand(UInt32), base=16)

    # Separate trigger from content children
    trigger_nodes = []
    content_nodes = []
    for child in children
        if child isa Therapy.VNode && haskey(child.props, Symbol("data-suite-alert-dialog-trigger-wrapper"))
            push!(trigger_nodes, child)
        else
            push!(content_nodes, child)
        end
    end

    # Trigger is rendered OUTSIDE the hidden container so it's always visible.
    Div(:class => cn(class),
        kwargs...,
        [_alert_dialog_set_trigger_id(t, id) for t in trigger_nodes]...,
        Div(Symbol("data-suite-alert-dialog") => id,
            :style => "display:none",
            content_nodes...,
        ),
    )
end

function _alert_dialog_set_trigger_id(node, id)
    if node isa Therapy.VNode && haskey(node.props, Symbol("data-suite-alert-dialog-trigger-wrapper"))
        new_props = copy(node.props)
        new_props[Symbol("data-suite-alert-dialog-trigger")] = id
        new_props[Symbol("aria-haspopup")] = "dialog"
        new_props[Symbol("aria-expanded")] = "false"
        new_props[Symbol("data-state")] = "closed"
        return Therapy.VNode(node.tag, new_props, node.children)
    end
    node
end

"""
    AlertDialogTrigger(children...; class, kwargs...) -> VNode

The button that opens the alert dialog.
"""
function AlertDialogTrigger(children...; class::String="", kwargs...)
    Span(Symbol("data-suite-alert-dialog-trigger-wrapper") => "",
         :style => "display:contents",
         :class => cn("cursor-pointer", class),
         kwargs...,
         children...)
end

"""
    AlertDialogContent(children...; class, kwargs...) -> VNode

The alert dialog content panel. Cannot be dismissed by Escape or click-outside.
"""
function AlertDialogContent(children...; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "bg-warm-50 dark:bg-warm-950 text-warm-800 dark:text-warm-300",
        "data-[state=open]:animate-in data-[state=closed]:animate-out",
        "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
        "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
        "fixed top-[50%] left-[50%] z-50 grid w-full max-w-[calc(100%-2rem)]",
        "translate-x-[-50%] translate-y-[-50%]",
        "gap-4 rounded-lg border border-warm-200 dark:border-warm-700",
        "p-6 shadow-lg duration-200 outline-none sm:max-w-lg",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(
        # Overlay backdrop
        Div(Symbol("data-suite-alert-dialog-overlay") => "",
            Symbol("data-state") => "closed",
            :class => "fixed inset-0 z-50 bg-warm-950/80 data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
            :style => "display:none",
        ),
        # Content
        Div(Symbol("data-suite-alert-dialog-content") => "",
            Symbol("data-state") => "closed",
            :role => "alertdialog",
            :aria_modal => "true",
            :tabindex => "-1",
            :class => classes,
            kwargs...,
            children...,
            # No default close button — AlertDialog requires explicit Action/Cancel
        ),
    )
end

"""
    AlertDialogHeader(children...; class, kwargs...) -> VNode

Header section (title + description).
"""
function AlertDialogHeader(children...; class::String="", kwargs...)
    Div(:class => cn("flex flex-col gap-2 text-center sm:text-left", class),
        kwargs...,
        children...)
end

"""
    AlertDialogFooter(children...; class, kwargs...) -> VNode

Footer section (action + cancel buttons).
"""
function AlertDialogFooter(children...; class::String="", kwargs...)
    Div(:class => cn("flex flex-col-reverse gap-2 sm:flex-row sm:justify-end", class),
        kwargs...,
        children...)
end

"""
    AlertDialogTitle(children...; class, kwargs...) -> VNode

Title of the alert dialog. Renders as h2.
"""
function AlertDialogTitle(children...; class::String="", kwargs...)
    H2(:class => cn("text-lg leading-none font-semibold text-warm-800 dark:text-warm-300", class),
       kwargs...,
       children...)
end

"""
    AlertDialogDescription(children...; class, kwargs...) -> VNode

Description text for the alert dialog.
"""
function AlertDialogDescription(children...; class::String="", kwargs...)
    P(:class => cn("text-warm-600 dark:text-warm-500 text-sm", class),
      kwargs...,
      children...)
end

"""
    AlertDialogAction(children...; class, kwargs...) -> VNode

Confirm action button. Clicking closes the alert dialog.
"""
function AlertDialogAction(children...; class::String="", kwargs...)
    Span(Symbol("data-suite-alert-dialog-action") => "",
         :class => cn(class),
         :style => "display:contents",
         kwargs...,
         children...)
end

"""
    AlertDialogCancel(children...; class, kwargs...) -> VNode

Cancel button. Clicking closes the alert dialog. Auto-focused on open.
"""
function AlertDialogCancel(children...; class::String="", kwargs...)
    Span(Symbol("data-suite-alert-dialog-cancel") => "",
         :class => cn(class),
         :style => "display:contents",
         kwargs...,
         children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :AlertDialog,
        "AlertDialog.jl",
        :js_runtime,
        "Modal alert dialog requiring explicit user action to dismiss",
        Symbol[],
        [:FocusGuards, :FocusTrap, :DismissLayer, :ScrollLock, :AlertDialog],
        [:AlertDialog, :AlertDialogTrigger, :AlertDialogContent,
         :AlertDialogHeader, :AlertDialogFooter, :AlertDialogTitle,
         :AlertDialogDescription, :AlertDialogAction, :AlertDialogCancel],
    ))
end
