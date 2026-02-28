# Resizable.jl — Suite.jl Resizable Panel Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none
# JS Modules: none
#
# Usage via package: using Suite; ResizablePanelGroup(ResizablePanel(...), ResizableHandle(), ResizablePanel(...))
# Usage via extract: include("components/Resizable.jl"); ResizablePanelGroup(...)
#
# Draggable panel resizing with flex-grow layout, min/max constraints,
# keyboard arrow key support, and ARIA separator semantics.
# Signal-driven: BindModal(mode=21) handles all interaction via Wasm
#
# Reference: react-resizable-panels by bvaughn + shadcn/ui Resizable

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- SVG Icons ---
const _RESIZABLE_GRIP_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="8" height="16" viewBox="0 0 8 16" fill="currentColor"><circle cx="2" cy="4" r="1" opacity="0.5"/><circle cx="6" cy="4" r="1" opacity="0.5"/><circle cx="2" cy="8" r="1" opacity="0.5"/><circle cx="6" cy="8" r="1" opacity="0.5"/><circle cx="2" cy="12" r="1" opacity="0.5"/><circle cx="6" cy="12" r="1" opacity="0.5"/></svg>"""
const _RESIZABLE_GRIP_H_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="8" viewBox="0 0 16 8" fill="currentColor"><circle cx="4" cy="2" r="1" opacity="0.5"/><circle cx="4" cy="6" r="1" opacity="0.5"/><circle cx="8" cy="2" r="1" opacity="0.5"/><circle cx="8" cy="6" r="1" opacity="0.5"/><circle cx="12" cy="2" r="1" opacity="0.5"/><circle cx="12" cy="6" r="1" opacity="0.5"/></svg>"""

# --- Component Implementation ---

export ResizablePanelGroup, ResizablePanel, ResizableHandle

#   ResizablePanelGroup(children...; direction, class, kwargs...) -> VNode
#
# A container for resizable panels arranged horizontally or vertically.
# Options: direction ("horizontal"/"vertical")
# Examples: ResizablePanelGroup(direction="horizontal", ResizablePanel(default_size=30, ...), ResizableHandle(), ...)
@island function ResizablePanelGroup(children...; direction::String="horizontal",
                             class::String="", theme::Symbol=:default, kwargs...)
    is_active, set_active = create_signal(Int32(1))

    flex_dir = direction == "vertical" ? "flex-col" : "flex-row"

    classes = cn("flex w-full h-full overflow-hidden", flex_dir, class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(:class => classes,
        Symbol("data-modal") => BindModal(is_active, Int32(21)),
        Symbol("data-resizable-direction") => direction,
        :style => "flex-wrap:nowrap;",
        kwargs...,
        children...,
    )
end

"""
    ResizablePanel(children...; default_size, min_size, max_size, class, kwargs...) -> VNode

A resizable panel within a ResizablePanelGroup.

# Options
- `default_size`: Initial size as percentage (default: `0` = auto-distribute)
- `min_size`: Minimum size percentage (default: `10`)
- `max_size`: Maximum size percentage (default: `100`)
"""
function ResizablePanel(children...; default_size::Int=0, min_size::Int=10,
                        max_size::Int=100, class::String="",
                        theme::Symbol=:default, kwargs...)
    id = "suite-panel-" * string(rand(UInt32), base=16)

    classes = cn("overflow-hidden", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    grow = default_size > 0 ? string(default_size) : "1"

    Div(:class => classes,
        :data_resizable_panel => id,
        :data_resizable_default_size => string(default_size),
        :data_resizable_min_size => string(min_size),
        :data_resizable_max_size => string(max_size),
        :style => "display:flex;flex-basis:0;flex-shrink:1;flex-grow:$(grow);",
        kwargs...,
        children...,
    )
end

"""
    ResizableHandle(; with_handle, class, kwargs...) -> VNode

A drag handle between resizable panels.

# Options
- `with_handle`: Whether to show a visible grip icon (default: `false`)
"""
function ResizableHandle(; with_handle::Bool=false, class::String="",
                          theme::Symbol=:default, kwargs...)
    # Determine grip icon orientation from parent context — not available at render,
    # so we render both and JS hides the wrong one via data attribute.
    # Default to vertical (horizontal group = vertical separator).
    handle_content = if with_handle
        Div(:class => "z-10 flex h-4 w-3 items-center justify-center rounded-sm border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-900",
            RawHtml(_RESIZABLE_GRIP_SVG),
        )
    else
        nothing
    end

    classes = cn(
        "relative flex-shrink-0 select-none",
        "bg-warm-200 dark:bg-warm-700",
        "data-[suite-resizable-direction=horizontal]:w-px data-[suite-resizable-direction=horizontal]:cursor-col-resize",
        "data-[suite-resizable-direction=vertical]:h-px data-[suite-resizable-direction=vertical]:cursor-row-resize",
        "hover:bg-accent-500 dark:hover:bg-accent-400",
        "focus-visible:outline-2 focus-visible:outline-accent-600 focus-visible:outline-offset-0",
        "transition-colors",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    # ARIA: separator role, inverse orientation
    Div(:class => classes,
        :data_resizable_handle => "inactive",
        :role => "separator",
        :tabindex => "0",
        Symbol("aria-orientation") => "vertical",
        :data_resizable_direction => "horizontal",
        kwargs...,
        handle_content === nothing ? "" : handle_content,
    )
end


# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Resizable,
        "Resizable.jl",
        :island,
        "Draggable panel resizing with min/max constraints",
        Symbol[],
        [:Resizable],
        [:ResizablePanelGroup, :ResizablePanel, :ResizableHandle],
    ))
end
