# Tooltip.jl — Suite.jl Tooltip Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Tooltip(...)
# Usage via extract: include("components/Tooltip.jl"); Tooltip(...)
#
# Behavior (matches Radix Tooltip):
#   - Hover/focus-triggered informational popup
#   - Provider-level delay (700ms default)
#   - Escape key dismisses
#   - No focus trap (tooltip content is not interactive)
#   - Floating positioning with flip/shift collision avoidance
#   - Signal-driven: BindModal(mode=4) handles hover timing + floating positioning

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export TooltipProvider, Tooltip, TooltipTrigger, TooltipContent

"""
    TooltipProvider(children...; delay_duration, skip_delay_duration, kwargs...) -> VNode

Provider that manages tooltip delay state. Wrap around a group of tooltips
for coordinated delay behavior (instant-open for quick succession).

# Arguments
- `delay_duration::Int=700`: Milliseconds before tooltip opens on hover
- `skip_delay_duration::Int=300`: Milliseconds window for instant-open after close
"""
function TooltipProvider(children...; delay_duration::Int=700, skip_delay_duration::Int=300, class::String="", kwargs...)
    Div(Symbol("data-tooltip-provider") => "",
        Symbol("data-tooltip-delay") => string(delay_duration),
        Symbol("data-tooltip-skip-delay") => string(skip_delay_duration),
        :class => cn(class),
        :style => "display:contents",
        kwargs...,
        children...)
end

#   Tooltip(children...; class, kwargs...) -> IslandVNode
#
# A hover/focus-triggered informational popup.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# BindModal(mode=4) handles hover timing, floating positioning, Escape dismiss,
# and pointerdown dismiss. Data-state updates are managed by the modal_state JS handler.
#
# Examples:
#   TooltipProvider(Tooltip(TooltipTrigger(Button("Hover me")), TooltipContent(P("Tip"))))
@island function Tooltip(children...; class::String="", kwargs...)
    # Signal for open state (Int32: 0=closed, 1=open)
    is_open, set_open = create_signal(Int32(0))

    # Provide context for child islands (Thaw-style signal sharing)
    provide_context(:tooltip_open, is_open)
    provide_context(:tooltip_set_open, set_open)

    Div(Symbol("data-modal") => BindModal(is_open, Int32(4)),  # mode 4 = tooltip (hover + floating)
        :class => cn("", class),
        :style => "display:contents",
        kwargs...,
        children...)
end

#   TooltipTrigger(children...; class, kwargs...) -> IslandVNode
#
# The element that triggers the tooltip on hover/focus.
# Child island: owns signal + pointerenter/pointerleave handlers (compilable body).
@island function TooltipTrigger(children...; class::String="", kwargs...)
    is_open, set_open = create_signal(Int32(0))

    Div(Symbol("data-tooltip-trigger-wrapper") => "",
        :style => "display:contents",
        Symbol("data-state") => "closed",
        :on_pointerenter => () -> set_open(Int32(1)),
        :on_pointerleave => () -> set_open(Int32(0)),
        Therapy.Button(:type => "button",
               :class => cn("cursor-pointer", class),
               kwargs...,
               children...))
end

"""
    TooltipContent(children...; side, side_offset, align, class, kwargs...) -> VNode

The tooltip content popup. Positioned relative to the trigger.

# Arguments
- `side::String="top"`: Preferred side ("top", "right", "bottom", "left")
- `side_offset::Int=4`: Distance from anchor in pixels
- `align::String="center"`: Alignment along side ("start", "center", "end")
"""
function TooltipContent(children...; side::String="top", side_offset::Int=4, align::String="center", theme::Symbol=:default, class::String="", kwargs...)
    classes = cn(
        "glass-panel",
        "bg-warm-800 dark:bg-warm-300 text-warm-50 dark:text-warm-950",
        "animate-in fade-in-0 zoom-in-95",
        "data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95",
        "data-[side=bottom]:slide-in-from-top-2",
        "data-[side=left]:slide-in-from-right-2",
        "data-[side=right]:slide-in-from-left-2",
        "data-[side=top]:slide-in-from-bottom-2",
        "z-50 w-fit px-3 py-1.5 rounded-md text-xs text-balance",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-tooltip-content") => "",
        Symbol("data-tooltip-side") => side,
        Symbol("data-tooltip-side-offset") => string(side_offset),
        Symbol("data-tooltip-align") => align,
        Symbol("data-state") => "closed",
        :role => "tooltip",
        :tabindex => "-1",
        :style => "display:none",
        :class => classes,
        kwargs...,
        children...,
    )
end

# --- Hydration Body (Wasm compilation) ---
# Tooltip: mode=4 (hover + floating). Trigger uses pointerenter/pointerleave.
# Root Div (BindModal) → Div trigger (hover events, contains Button) → Div content
# Parent island: Div(BindModal) wrapping children (nested islands handle their own bindings)
const _TOOLTIP_HYDRATION_BODY = quote
    is_open, set_open = create_signal(Int32(0))
    Div(
        Symbol("data-modal") => BindModal(is_open, Int32(4)),
        children,
    )
end

# Child island: Div(pointerenter/leave + Button(children))
const _TOOLTIPTRIGGER_HYDRATION_BODY = quote
    is_open, set_open = create_signal(Int32(0))
    Div(
        :on_pointerenter => () -> set_open(Int32(1)),
        :on_pointerleave => () -> set_open(Int32(0)),
        Button(children),
    )
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Tooltip,
        "Tooltip.jl",
        :island,
        "Hover/focus-triggered informational popup with delay state machine",
        Symbol[],
        Symbol[],
        [:TooltipProvider, :Tooltip, :TooltipTrigger, :TooltipContent],
    ))
end
