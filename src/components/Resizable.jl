# Resizable.jl — Suite.jl Resizable Panel Component
#
# Tier: island (Wasm — drag handle for panel resizing)
# Suite Dependencies: none
# JS Modules: none
#
# Usage via package: using Suite; ResizablePanelGroup(ResizablePanel(...), ResizableHandle(), ResizablePanel(...))
# Usage via extract: include("components/Resizable.jl"); ResizablePanelGroup(...)
#
# Draggable panel resizing with flex-grow layout, min/max constraints,
# keyboard arrow key support, and ARIA separator semantics.
#
# Architecture: Monolithic @island
#   - Signal 0: dragging (Int32, 0 or 1)
#   - Signal 1: split_pct (Int32, percentage * 100 of first panel, 0-10000)
#   - Handler 0: on_pointerdown — if on handle, capture, set dragging=1
#   - Handler 1: on_pointermove — if dragging, compute split, update panels
#   - Handler 2: on_pointerup — release, set dragging=0
#   - Handler 3: on_keydown — arrows ±1% on focused handle
#
# Element IDs (2-panel layout):
#   0: therapy-island, 1: group Div, 2: panel A, 3: handle, 4: panel B
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

# SSR helper: walk children, inject data-index on handles.
# Panel flex-grow is already set by ResizablePanel() — no override needed.
function _resizable_ssr_setup!(children)
    handle_idx = 0
    for child in children
        child isa VNode || continue
        if haskey(child.props, :data_resizable_handle)
            child.props[Symbol("data-index")] = string(handle_idx)
            handle_idx += 1
        end
    end
end

#   ResizablePanelGroup(children...; direction, class, kwargs...) -> VNode
#
# A container for resizable panels arranged horizontally or vertically.
# Options: direction ("horizontal"/"vertical")
# Examples: ResizablePanelGroup(direction="horizontal", ResizablePanel(default_size=30, ...), ResizableHandle(), ...)
@island function ResizablePanelGroup(children...; direction::String="horizontal",
                             class::String="", theme::Symbol=:default, kwargs...)
    flex_dir = direction == "vertical" ? "flex-col" : "flex-row"

    # Signal 0: dragging state
    dragging, set_dragging = create_signal(Int32(0))
    # Signal 1: split percentage * 100 (from prop _s, index 0)
    split_pct, set_split_pct = create_signal(compiled_get_prop_i32(Int32(0)))

    # SSR: inject data-index on handles
    _resizable_ssr_setup!(children)

    classes = cn("flex w-full h-full overflow-hidden", flex_dir, class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(:class => classes,
        Symbol("data-resizable") => "",
        Symbol("data-resizable-direction") => direction,
        :style => "flex-wrap:nowrap;",
        # Handler 0: pointerdown — if on handle, capture and start dragging
        # NOTE: All Float64 arithmetic — WasmTarget cannot compile Int32(Float64)
        :on_pointerdown => () -> begin
            idx = compiled_get_event_data_index()
            if idx >= Int32(0)
                el = Int32(1)
                capture_pointer(el)
                set_dragging(Int32(1))
                rx = get_bounding_rect_x(el)
                rw = get_bounding_rect_w(el)
                px = get_pointer_x()
                pct = (px - rx) * Float64(100) / rw
                if pct < Float64(10)
                    pct = Float64(10)
                end
                if pct > Float64(90)
                    pct = Float64(90)
                end
                set_style_numeric(Int32(2), Int32(0), pct)
                set_style_numeric(Int32(4), Int32(0), Float64(100) - pct)
            end
        end,
        # Handler 1: pointermove — if dragging, update split
        :on_pointermove => () -> begin
            if dragging() == Int32(1)
                el = Int32(1)
                rx = get_bounding_rect_x(el)
                rw = get_bounding_rect_w(el)
                px = get_pointer_x()
                pct = (px - rx) * Float64(100) / rw
                if pct < Float64(10)
                    pct = Float64(10)
                end
                if pct > Float64(90)
                    pct = Float64(90)
                end
                set_style_numeric(Int32(2), Int32(0), pct)
                set_style_numeric(Int32(4), Int32(0), Float64(100) - pct)
            end
        end,
        # Handler 2: pointerup — release, stop dragging
        :on_pointerup => () -> begin
            el = Int32(1)
            release_pointer(el)
            set_dragging(Int32(0))
        end,
        # Handler 3: keydown — arrows ±1% on focused handle
        :on_keydown => () -> begin
            key = get_key_code()
            current = split_pct()
            step = Int32(100)  # 1% = 100 in our 0-10000 scale
            new_val = current
            # ArrowRight (39) or ArrowDown (40) = increase first panel
            if key == Int32(39)
                new_val = current + step
            end
            if key == Int32(40)
                new_val = current + step
            end
            # ArrowLeft (37) or ArrowUp (38) = decrease first panel
            if key == Int32(37)
                new_val = current - step
            end
            if key == Int32(38)
                new_val = current - step
            end
            # Clamp 10%-90%
            if new_val < Int32(1000)
                new_val = Int32(1000)
            end
            if new_val > Int32(9000)
                new_val = Int32(9000)
            end
            if new_val != current
                set_split_pct(new_val)
                pct_a = Float64(new_val) / Float64(100)
                pct_b = (Float64(10000) - Float64(new_val)) / Float64(100)
                set_style_numeric(Int32(2), Int32(0), pct_a)
                set_style_numeric(Int32(4), Int32(0), pct_b)
            end
        end,
        kwargs...,
        children...,
    )
end

# Compute initial split from first panel's default_size
function _compute_initial_split(children)
    for child in children
        child isa VNode || continue
        if haskey(child.props, :data_resizable_panel)
            ds = get(child.props, :data_resizable_default_size, "0")
            size = tryparse(Int, string(ds))
            if size !== nothing && size > 0
                return size * 100  # Convert percentage to our 0-10000 scale
            end
            return 5000  # Default 50%
        end
    end
    return 5000
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

# --- Hydration Support ---

const _RESIZABLE_PROPS_TRANSFORM = (props, args) -> begin
    # Compute initial split percentage * 100 from first panel
    split = 5000  # default 50%
    for arg in args
        arg isa Therapy.VNode || continue
        if haskey(arg.props, :data_resizable_panel)
            ds = get(arg.props, :data_resizable_default_size, "0")
            size = tryparse(Int, string(ds))
            if size !== nothing && size > 0
                split = size * 100
            end
            break
        end
    end
    props[:_s] = split
end


# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Resizable,
        "Resizable.jl",
        :island,
        "Draggable panel resizing with min/max constraints",
        Symbol[],
        Symbol[],
        [:ResizablePanelGroup, :ResizablePanel, :ResizableHandle],
    ))
end
