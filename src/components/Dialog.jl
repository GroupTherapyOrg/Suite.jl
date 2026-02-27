# Dialog.jl — Suite.jl Dialog Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Dialog(DialogTrigger(Button("Open")), DialogContent(...))
# Usage via extract: include("components/Dialog.jl"); Dialog(...)
#
# Behavior (matches Radix Dialog):
#   - Modal by default: focus trapped, scroll locked, outside pointer disabled
#   - Escape key dismisses
#   - Click outside overlay dismisses
#   - Focus auto-moves to first tabbable non-link element on open
#   - Focus returns to trigger on close
#   - Signal-driven: BindBool maps open signal to data-state and aria-expanded
#   - BindModal handles scroll lock, focus trap, dismiss, show/hide with animation
#
# Reference: Radix UI Dialog — https://www.radix-ui.com/primitives/docs/components/dialog

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Dialog, DialogTrigger, DialogContent,
       DialogHeader, DialogFooter, DialogTitle,
       DialogDescription, DialogClose

#   Dialog(children...; class, kwargs...) -> IslandVNode
#
# A modal dialog overlay. Contains trigger, overlay, and content.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# DialogTrigger and DialogContent children are auto-detected and injected
# with signal bindings for data-state, aria-expanded, and modal behavior.
#
# Examples:
#   Dialog(DialogTrigger(Button("Open")), DialogContent(DialogHeader(DialogTitle("Title"))))
@island function Dialog(children...; class::String="", kwargs...)
    # Signal for open state (Int32: 0=closed, 1=open)
    is_open, set_open = create_signal(Int32(0))

    # Walk children to inject signal bindings
    for child in children
        if child isa VNode
            if haskey(child.props, Symbol("data-suite-dialog-trigger-wrapper"))
                # Inject reactive bindings on trigger wrapper
                child.props[Symbol("data-state")] = BindBool(is_open, "closed", "open")
                child.props[:aria_expanded] = BindBool(is_open, "false", "true")
                child.props[:on_click] = () -> set_open(Int32(1) - is_open())
            else
                # Content wrapper — walk into it
                _dialog_inject_content_bindings!(child, is_open, set_open)
            end
        end
    end

    Div(Symbol("data-modal") => BindModal(is_open, Int32(0)),  # mode 0 = dialog
        :class => cn("", class),
        kwargs...,
        children...)
end

# Walk the content wrapper to find overlay, content, and close buttons
function _dialog_inject_content_bindings!(node::VNode, is_open, set_open)
    for child in node.children
        if child isa VNode
            if haskey(child.props, Symbol("data-suite-dialog-overlay"))
                # Overlay: bind data-state, add click-to-close
                child.props[Symbol("data-state")] = BindBool(is_open, "closed", "open")
                child.props[:on_click] = () -> set_open(Int32(0))
            elseif haskey(child.props, Symbol("data-suite-dialog-content"))
                # Content: bind data-state
                child.props[Symbol("data-state")] = BindBool(is_open, "closed", "open")
                # Walk content for close buttons
                _dialog_inject_close_buttons!(child, set_open)
            end
        end
    end
end

# Recursively inject close handler on all [data-suite-dialog-close] elements
function _dialog_inject_close_buttons!(node::VNode, set_open)
    if haskey(node.props, Symbol("data-suite-dialog-close"))
        node.props[:on_click] = () -> set_open(Int32(0))
    end
    for child in node.children
        if child isa VNode
            _dialog_inject_close_buttons!(child, set_open)
        end
    end
end

"""
    DialogTrigger(children...; class, kwargs...) -> VNode

The button that opens the dialog. Wrap around a Button or any clickable element.
"""
function DialogTrigger(children...; class::String="", kwargs...)
    Span(Symbol("data-suite-dialog-trigger-wrapper") => "",
         :style => "display:contents",
         :class => cn("cursor-pointer", class),
         Symbol("data-state") => "closed",
         :aria_haspopup => "dialog",
         :aria_expanded => "false",
         kwargs...,
         children...)
end

"""
    DialogContent(children...; class, kwargs...) -> VNode

The dialog content panel. Contains header, body, footer, and close button.
Renders with overlay backdrop. Hidden by default, shown by Wasm island.
"""
function DialogContent(children...; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "glass-panel-elevated",
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
            :class => classes,
            kwargs...,
            children...,
            # Default close button (X in top-right)
            Therapy.Button(:type => "button",
                   Symbol("data-suite-dialog-close") => "",
                   :class => "absolute right-4 top-4 rounded-sm opacity-70 cursor-pointer ring-offset-warm-50 dark:ring-offset-warm-950 transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-accent-600 focus:ring-offset-2 disabled:pointer-events-none",
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
    DialogHeader(children...; class, kwargs...) -> VNode

Header section of the dialog (typically contains title and description).
"""
function DialogHeader(children...; class::String="", kwargs...)
    Div(:class => cn("flex flex-col gap-2 text-center sm:text-left", class),
        kwargs...,
        children...)
end

"""
    DialogFooter(children...; class, kwargs...) -> VNode

Footer section of the dialog (typically contains action buttons).
"""
function DialogFooter(children...; class::String="", kwargs...)
    Div(:class => cn("flex flex-col-reverse gap-2 sm:flex-row sm:justify-end", class),
        kwargs...,
        children...)
end

"""
    DialogTitle(children...; class, kwargs...) -> VNode

Title of the dialog. Renders as h2.
"""
function DialogTitle(children...; class::String="", kwargs...)
    H2(:class => cn("text-lg leading-none font-semibold text-warm-800 dark:text-warm-300", class),
       kwargs...,
       children...)
end

"""
    DialogDescription(children...; class, kwargs...) -> VNode

Description text for the dialog.
"""
function DialogDescription(children...; class::String="", kwargs...)
    P(:class => cn("text-warm-600 dark:text-warm-500 text-sm", class),
      kwargs...,
      children...)
end

"""
    DialogClose(children...; class, kwargs...) -> VNode

A button that closes the dialog when clicked. Wrap around a Button or any element.
"""
function DialogClose(children...; class::String="", kwargs...)
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
        :island,
        "Modal dialog overlay with focus trap, scroll lock, and dismiss layer",
        Symbol[],
        Symbol[],
        [:Dialog, :DialogTrigger, :DialogContent,
         :DialogHeader, :DialogFooter, :DialogTitle,
         :DialogDescription, :DialogClose],
    ))
end
