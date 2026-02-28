# Popover.jl — Suite.jl Popover Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Popover(...)
# Usage via extract: include("components/Popover.jl"); Popover(...)
#
# Behavior (Thaw-style inline Wasm):
#   - Click-triggered floating panel
#   - Escape key dismisses (via push_escape_handler Wasm import)
#   - Click outside dismisses (via close button delegation)
#   - Positioned relative to trigger (floating positioning in slim modal binding)
#   - Supports side/align/offset configuration
#   - Signal-driven: BindBool maps open signal to data-state and aria-expanded
#   - Modal binding (mode=0) handles show/hide + data-state on content

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Popover, PopoverTrigger, PopoverContent,
       PopoverClose, PopoverAnchor

#   Popover(children...; class, kwargs...) -> IslandVNode
#
# A click-triggered floating panel. Contains trigger and floating content.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# Parent island: creates signal, provides context for child islands.
# Modal binding handles show/hide + data-state on content child.
# Behavioral logic (focus, Escape) is inline Wasm in PopoverTrigger.
#
# Examples:
#   Popover(PopoverTrigger(Button(variant="outline", "Open")), PopoverContent(P("Content")))
@island function Popover(children...; class::String="", kwargs...)
    # Signal for open state (Int32: 0=closed, 1=open)
    is_open, set_open = create_signal(Int32(0))

    # Provide context for child islands (single key with getter+setter tuple)
    provide_context(:popover, (is_open, set_open))

    Div(Symbol("data-show") => ShowDescendants(is_open),  # show/hide + data-state binding (inline Wasm)
        :class => cn("", class),
        :style => "display:contents",
        kwargs...,
        children...)
end

#   PopoverTrigger(children...; class, kwargs...) -> IslandVNode
#
# The button that opens the popover.
# Child island: owns signal + BindBool + inline Wasm behavior (compilable body).
#
# Inline Wasm behavior (Thaw-style):
#   - Open: store focus, set signal, register Escape handler (no scroll lock — floating panel)
#   - Close: set signal, pop Escape handler, restore focus
@island function PopoverTrigger(children...; class::String="", kwargs...)
    # Read parent's signal from context (SSR) or create own (Wasm compilation)
    is_open, set_open = use_context_signal(:popover, Int32(0))

    Span(Symbol("data-popover-trigger-wrapper") => "",
         :style => "display:contents",
         :class => cn("cursor-pointer", class),
         Symbol("data-state") => BindBool(is_open, "closed", "open"),
         :aria_haspopup => "dialog",
         :aria_expanded => BindBool(is_open, "false", "true"),
         :on_click => () -> begin
             if is_open() == Int32(0)
                 # Opening: inline Wasm behavior (no scroll lock for floating panel)
                 store_active_element()
                 set_open(Int32(1))
                 push_escape_handler(Int32(0))
             else
                 # Closing: inline Wasm behavior
                 set_open(Int32(0))
                 pop_escape_handler()
                 restore_active_element()
             end
         end,
         kwargs...,
         children...)
end

"""
    PopoverContent(children...; side, side_offset, align, class, kwargs...) -> VNode

The floating content panel. Positioned relative to the trigger.

# Arguments
- `side::String="bottom"`: Preferred side ("top", "right", "bottom", "left")
- `side_offset::Int=0`: Distance from anchor in pixels
- `align::String="center"`: Alignment along side ("start", "center", "end")
"""
function PopoverContent(children...; side::String="bottom", side_offset::Int=0, align::String="center", theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "glass-panel",
        "bg-warm-50 dark:bg-warm-900 text-warm-800 dark:text-warm-300",
        "data-[state=open]:animate-in data-[state=closed]:animate-out",
        "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
        "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
        "data-[side=bottom]:slide-in-from-top-2",
        "data-[side=left]:slide-in-from-right-2",
        "data-[side=right]:slide-in-from-left-2",
        "data-[side=top]:slide-in-from-bottom-2",
        "z-50 w-72 rounded-md border border-warm-200 dark:border-warm-700",
        "p-4 shadow-md outline-hidden",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-popover-content") => "",
        Symbol("data-popover-side") => side,
        Symbol("data-popover-side-offset") => string(side_offset),
        Symbol("data-popover-align") => align,
        Symbol("data-state") => "closed",
        :role => "dialog",
        :aria_modal => "true",
        :tabindex => "-1",
        :style => "display:none",
        :class => classes,
        kwargs...,
        children...,
    )
end

"""
    PopoverClose(children...; class, kwargs...) -> VNode

A button that closes the popover when clicked.
"""
function PopoverClose(children...; class::String="", kwargs...)
    Span(Symbol("data-popover-close") => "",
         :class => cn(class),
         :style => "display:contents",
         kwargs...,
         children...)
end

"""
    PopoverAnchor(children...; class, kwargs...) -> VNode

Optional custom anchor element. When used, the popover positions relative
to this element instead of the trigger.
"""
function PopoverAnchor(children...; class::String="", kwargs...)
    Div(Symbol("data-popover-anchor") => "",
        :class => cn(class),
        kwargs...,
        children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Popover,
        "Popover.jl",
        :island,
        "Click-triggered floating panel with focus trap and positioning",
        Symbol[],
        Symbol[],
        [:Popover, :PopoverTrigger, :PopoverContent,
         :PopoverClose, :PopoverAnchor],
    ))
end
