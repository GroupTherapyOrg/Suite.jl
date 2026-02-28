# Drawer.jl — Suite.jl Drawer Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Drawer(...)
# Usage via extract: include("components/Drawer.jl"); Drawer(...)
#
# Behavior (matches Vaul drawer):
#   - Bottom sheet with drag-to-dismiss
#   - Modal: focus trapped, scroll locked
#   - Escape key dismisses
#   - Click outside dismisses
#   - Drag velocity > 0.4 → close (fast swipe)
#   - Drag distance > 25% height → close
#   - Logarithmic damping when dragging past open position
#   - Supports 4 directions: bottom (default), top, left, right
#   - Signal-driven: BindBool maps open signal to data-state and aria-expanded
#   - BindModal mode=2 handles modal lifecycle + drag-to-dismiss

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Drawer, DrawerTrigger, DrawerContent,
       DrawerHeader, DrawerFooter, DrawerTitle,
       DrawerDescription, DrawerClose, DrawerHandle

#   Drawer(children...; class, kwargs...) -> IslandVNode
#
# A draggable bottom sheet overlay. Supports drag-to-dismiss with velocity
# and distance thresholds. Interactive behavior is compiled to WebAssembly —
# no JavaScript required.
#
# DrawerTrigger and DrawerContent children are auto-detected and injected
# with signal bindings for data-state, aria-expanded, and modal+drag behavior.
#
# Examples:
#   Drawer(DrawerTrigger(Button("Open")), DrawerContent(DrawerHandle(), DrawerTitle("Goal")))
@island function Drawer(children...; class::String="", kwargs...)
    # Signal for open state (Int32: 0=closed, 1=open)
    is_open, set_open = create_signal(Int32(0))

    # Provide context for child islands (Thaw-style signal sharing)
    provide_context(:drawer_open, is_open)
    provide_context(:drawer_set_open, set_open)

    Div(Symbol("data-modal") => BindModal(is_open, Int32(2)),  # mode 2 = drawer (dialog + drag-to-dismiss)
        :class => cn("", class),
        kwargs...,
        children...)
end

#   DrawerTrigger(children...; class, kwargs...) -> IslandVNode
#
# The button that opens the drawer.
# Child island: owns signal + BindBool + on_click handler (compilable body).
@island function DrawerTrigger(children...; class::String="", kwargs...)
    is_open, set_open = create_signal(Int32(0))

    Span(Symbol("data-drawer-trigger-wrapper") => "",
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
    DrawerContent(children...; direction, class, kwargs...) -> VNode

The drawer content panel. Supports drag-to-dismiss.

# Arguments
- `direction::String="bottom"`: Direction to slide from ("bottom", "top", "left", "right")
"""
function DrawerContent(children...; direction::String="bottom", theme::Symbol=:default, class::String="", kwargs...)
    # Direction-specific positioning classes
    dir_classes = if direction == "bottom"
        "inset-x-0 bottom-0 mt-24 rounded-t-[10px] border-t"
    elseif direction == "top"
        "inset-x-0 top-0 mb-24 rounded-b-[10px] border-b"
    elseif direction == "left"
        "inset-y-0 left-0 mr-24 rounded-r-[10px] border-r h-full w-3/4 sm:max-w-sm"
    elseif direction == "right"
        "inset-y-0 right-0 ml-24 rounded-l-[10px] border-l h-full w-3/4 sm:max-w-sm"
    else
        "inset-x-0 bottom-0 mt-24 rounded-t-[10px] border-t"
    end

    classes = cn(
        "bg-warm-50 dark:bg-warm-950 text-warm-800 dark:text-warm-300",
        "fixed z-50 flex h-auto flex-col outline-none",
        "border-warm-200 dark:border-warm-700",
        dir_classes,
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(
        # Overlay backdrop
        Div(Symbol("data-drawer-overlay") => "",
            Symbol("data-state") => "closed",
            :class => "fixed inset-0 z-50 bg-warm-950/80 data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
            :style => "display:none",
        ),
        # Content
        Div(Symbol("data-drawer-content") => "",
            Symbol("data-drawer-direction") => direction,
            Symbol("data-state") => "closed",
            :role => "dialog",
            :aria_modal => "true",
            :tabindex => "-1",
            :style => "touch-action:none",
            :class => classes,
            kwargs...,
            children...,
        ),
    )
end

"""
    DrawerHandle(; class, kwargs...) -> VNode

A visual drag handle indicator for the drawer.
"""
function DrawerHandle(; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn("mx-auto mt-4 h-2 w-[100px] rounded-full bg-warm-200 dark:bg-warm-800", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(:class => classes,
        kwargs...)
end

"""
    DrawerHeader(children...; class, kwargs...) -> VNode

Header section of the drawer.
"""
function DrawerHeader(children...; class::String="", kwargs...)
    Div(:class => cn("flex flex-col gap-2 p-4 text-center sm:text-left", class),
        kwargs...,
        children...)
end

"""
    DrawerFooter(children...; class, kwargs...) -> VNode

Footer section of the drawer.
"""
function DrawerFooter(children...; class::String="", kwargs...)
    Div(:class => cn("flex flex-col gap-2 p-4", class),
        kwargs...,
        children...)
end

"""
    DrawerTitle(children...; class, kwargs...) -> VNode

Title of the drawer. Renders as h2.
"""
function DrawerTitle(children...; class::String="", kwargs...)
    H2(:class => cn("text-lg leading-none font-semibold", class),
       kwargs...,
       children...)
end

"""
    DrawerDescription(children...; class, kwargs...) -> VNode

Description text for the drawer.
"""
function DrawerDescription(children...; class::String="", kwargs...)
    P(:class => cn("text-warm-600 dark:text-warm-500 text-sm", class),
      kwargs...,
      children...)
end

"""
    DrawerClose(children...; class, kwargs...) -> VNode

A button that closes the drawer when clicked.
"""
function DrawerClose(children...; class::String="", kwargs...)
    Span(Symbol("data-drawer-close") => "",
         :class => cn(class),
         :style => "display:contents",
         kwargs...,
         children...)
end

# --- Hydration Body (Wasm compilation) ---
# Mode=2 (dialog behavior + drag-to-dismiss). Same element structure as Dialog.
# Parent island: Div(BindModal) wrapping children (nested islands handle their own bindings)
const _DRAWER_HYDRATION_BODY = quote
    is_open, set_open = create_signal(Int32(0))
    Div(
        Symbol("data-modal") => BindModal(is_open, Int32(2)),
        children,
    )
end

# Child island: Span(BindBool + click toggle + children)
const _DRAWERTRIGGER_HYDRATION_BODY = quote
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
        :Drawer,
        "Drawer.jl",
        :island,
        "Draggable bottom sheet with velocity-based dismiss",
        Symbol[],
        Symbol[],
        [:Drawer, :DrawerTrigger, :DrawerContent,
         :DrawerHeader, :DrawerFooter, :DrawerTitle,
         :DrawerDescription, :DrawerClose, :DrawerHandle],
    ))
end
