# Drawer.jl — Suite.jl Drawer Component
#
# Tier: js_runtime (requires suite.js)
# Suite Dependencies: none (leaf component)
# JS Modules: FocusGuards, FocusTrap, DismissLayer, ScrollLock, Drawer
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

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Drawer, DrawerTrigger, DrawerContent,
       DrawerHeader, DrawerFooter, DrawerTitle,
       DrawerDescription, DrawerClose, DrawerHandle

"""
    Drawer(children...; class, kwargs...) -> VNode

A draggable bottom sheet overlay. Supports drag-to-dismiss with velocity
and distance thresholds.

# Examples
```julia
Drawer(
    DrawerTrigger(Button(variant="outline", "Open Drawer")),
    DrawerContent(
        DrawerHandle(),
        DrawerHeader(
            DrawerTitle("Move Goal"),
            DrawerDescription("Set your daily activity goal.")
        ),
        # ... content
        DrawerFooter(
            DrawerClose(Button(variant="outline", "Cancel")),
            Button("Submit")
        )
    )
)
```
"""
function Drawer(children...; class::String="", kwargs...)
    id = "suite-drawer-" * string(rand(UInt32), base=16)

    trigger_nodes = []
    content_nodes = []
    for child in children
        if child isa Therapy.VNode && haskey(child.props, Symbol("data-suite-drawer-trigger-wrapper"))
            push!(trigger_nodes, child)
        else
            push!(content_nodes, child)
        end
    end

    Div(:class => cn(class),
        Symbol("data-suite-drawer") => id,
        :style => "display:none",
        kwargs...,
        [_drawer_set_trigger_id(t, id) for t in trigger_nodes]...,
        content_nodes...,
    )
end

function _drawer_set_trigger_id(node, id)
    if node isa Therapy.VNode && haskey(node.props, Symbol("data-suite-drawer-trigger-wrapper"))
        inner_props = copy(node.children[1].props)
        inner_props[Symbol("data-suite-drawer-trigger")] = id
        inner_props[Symbol("aria-haspopup")] = "dialog"
        inner_props[Symbol("aria-expanded")] = "false"
        inner_props[Symbol("data-state")] = "closed"
        return Therapy.VNode(node.children[1].tag, inner_props, node.children[1].children)
    end
    node
end

"""
    DrawerTrigger(children...; class, kwargs...) -> VNode

The button that opens the drawer.
"""
function DrawerTrigger(children...; class::String="", kwargs...)
    Div(Symbol("data-suite-drawer-trigger-wrapper") => "",
        :style => "display:contents",
        Therapy.Button(:type => "button",
               :class => cn("cursor-pointer", class),
               kwargs...,
               children...))
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
        Div(Symbol("data-suite-drawer-overlay") => "",
            Symbol("data-state") => "closed",
            :class => "fixed inset-0 z-50 bg-warm-950/80 data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
            :style => "display:none",
        ),
        # Content
        Div(Symbol("data-suite-drawer-content") => "",
            Symbol("data-suite-drawer-direction") => direction,
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
    Span(Symbol("data-suite-drawer-close") => "",
         :class => cn(class),
         :style => "display:contents",
         kwargs...,
         children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Drawer,
        "Drawer.jl",
        :js_runtime,
        "Draggable bottom sheet with velocity-based dismiss",
        Symbol[],
        [:FocusGuards, :FocusTrap, :DismissLayer, :ScrollLock, :Drawer],
        [:Drawer, :DrawerTrigger, :DrawerContent,
         :DrawerHeader, :DrawerFooter, :DrawerTitle,
         :DrawerDescription, :DrawerClose, :DrawerHandle],
    ))
end
