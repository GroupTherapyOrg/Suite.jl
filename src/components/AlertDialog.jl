# AlertDialog.jl — Suite.jl Alert Dialog Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (leaf component)
# JS Modules: none
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
#   - Signal-driven: BindBool maps open signal to data-state and aria-expanded
#   - BindModal mode=1 handles modal lifecycle without Escape/outside dismiss
#
# Reference: Radix UI AlertDialog — https://www.radix-ui.com/primitives/docs/components/alert-dialog

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export AlertDialog, AlertDialogTrigger, AlertDialogContent,
       AlertDialogHeader, AlertDialogFooter, AlertDialogTitle,
       AlertDialogDescription, AlertDialogAction, AlertDialogCancel

#   AlertDialog(children...; class, kwargs...) -> IslandVNode
#
# A modal alert dialog that requires explicit user action to dismiss.
# Cannot be dismissed by Escape key or clicking outside.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# AlertDialogTrigger and AlertDialogContent children are auto-detected and
# injected with signal bindings for data-state, aria-expanded, and modal behavior.
#
# Examples:
#   AlertDialog(
#       AlertDialogTrigger(Button(variant="destructive", "Delete")),
#       AlertDialogContent(AlertDialogHeader(AlertDialogTitle("Sure?")), AlertDialogFooter(...))
#   )
@island function AlertDialog(children...; class::String="", kwargs...)
    # Signal for open state (Int32: 0=closed, 1=open)
    is_open, set_open = create_signal(Int32(0))

    # Provide context for child islands (single key with getter+setter tuple)
    provide_context(:alertdialog, (is_open, set_open))

    Div(Symbol("data-modal") => BindModal(is_open, Int32(1)),  # mode 1 = alert_dialog (no Escape/outside dismiss)
        :class => cn("", class),
        kwargs...,
        children...)
end

#   AlertDialogTrigger(children...; class, kwargs...) -> IslandVNode
#
# The button that opens the alert dialog.
# Child island: owns signal + BindBool + on_click handler (compilable body).
@island function AlertDialogTrigger(children...; class::String="", kwargs...)
    # Read parent's signal from context (SSR) or create own (Wasm compilation)
    is_open, set_open = use_context_signal(:alertdialog, Int32(0))

    Span(Symbol("data-alert-dialog-trigger-wrapper") => "",
         :style => "display:contents",
         :class => cn("cursor-pointer", class),
         Symbol("data-state") => BindBool(is_open, "closed", "open"),
         :aria_haspopup => "dialog",
         :aria_expanded => BindBool(is_open, "false", "true"),
         :on_click => () -> set_open(Int32(1) - is_open()),
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
        Div(Symbol("data-alert-dialog-overlay") => "",
            Symbol("data-state") => "closed",
            :class => "fixed inset-0 z-50 bg-warm-950/80 data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
            :style => "display:none",
        ),
        # Content
        Div(Symbol("data-alert-dialog-content") => "",
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
    Span(Symbol("data-alert-dialog-action") => "",
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
    Span(Symbol("data-alert-dialog-cancel") => "",
         :class => cn(class),
         :style => "display:contents",
         kwargs...,
         children...)
end

# --- Hydration Body (Wasm compilation) ---
# Same structure as Dialog but mode=1 (no Escape/click-outside dismiss) and no overlay click handler
# Parent island: Div(BindModal) wrapping children (nested islands handle their own bindings)
const _ALERTDIALOG_HYDRATION_BODY = quote
    is_open, set_open = create_signal(Int32(0))
    Div(
        Symbol("data-modal") => BindModal(is_open, Int32(1)),
        children,
    )
end

# Child island: Span(BindBool + click toggle + children)
const _ALERTDIALOGTRIGGER_HYDRATION_BODY = quote
    is_open, set_open = create_signal(Int32(0))
    Span(
        Symbol("data-state") => BindBool(is_open, "closed", "open"),
        :aria_expanded => BindBool(is_open, "false", "true"),
        :on_click => () -> set_open(Int32(1) - is_open()),
        children,
    )
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :AlertDialog,
        "AlertDialog.jl",
        :island,
        "Modal alert dialog requiring explicit user action to dismiss",
        Symbol[],
        Symbol[],
        [:AlertDialog, :AlertDialogTrigger, :AlertDialogContent,
         :AlertDialogHeader, :AlertDialogFooter, :AlertDialogTitle,
         :AlertDialogDescription, :AlertDialogAction, :AlertDialogCancel],
    ))
end
