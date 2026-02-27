# ToggleGroup.jl — Suite.jl Toggle Group Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (contains own toggle item rendering)
# JS Modules: none
#
# Usage via package: using Suite; ToggleGroup(...)
# Usage via extract: include("components/ToggleGroup.jl"); ToggleGroup(...)
#
# Behavior:
#   - Signal-driven: BindBool maps per-item signal to data-state and ARIA attributes
#   - @island ToggleGroup injects signal bindings into ToggleGroupItem children
#   - Single mode: one item selected at a time, deselection allowed
#   - Multiple mode: any combination of items selected
#   - Single mode: items get role=radio + aria-checked via BindBool
#   - Multiple mode: items get aria-pressed via BindBool
#
# Reference: Radix UI ToggleGroup — https://www.radix-ui.com/primitives/docs/components/toggle-group

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export ToggleGroup, ToggleGroupItem

#   ToggleGroup(children...; type, default_value, variant, size, orientation, disabled, class, kwargs...) -> IslandVNode
#
# A group of toggle buttons where selection is managed collectively.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# ToggleGroupItem children are auto-detected and injected with signal bindings
# for data-state, aria-checked/aria-pressed, and click handlers.
#
# Props:
#   type: "single" (default) or "multiple" — selection mode
#   default_value: initially selected value(s) — String for single, Vector{String} for multiple
#   variant: "default" or "outline"
#   size: "default", "sm", or "lg"
#   orientation: "horizontal" (default) or "vertical"
#   disabled: disable all items
#
# Examples:
#   ToggleGroup(default_value="center",
#       ToggleGroupItem(value="left", "Left"),
#       ToggleGroupItem(value="center", "Center"),
#       ToggleGroupItem(value="right", "Right"),
#   )
@island function ToggleGroup(children...; type::String="single", default_value=nothing,
                          variant::String="default", size::String="default",
                          orientation::String="horizontal", disabled::Bool=false,
                          theme::Symbol=:default, class::String="", kwargs...)
    # Compute which items are initially on
    on_values = Set{String}()
    if default_value !== nothing
        if default_value isa AbstractString
            push!(on_values, default_value)
        elseif default_value isa AbstractVector
            for v in default_value
                push!(on_values, string(v))
            end
        end
    end

    # Collect item signals for coordination
    item_signals = Tuple{Any, Any}[]
    items = VNode[]

    for child in children
        if child isa VNode && haskey(child.props, Symbol("data-toggle-group-item"))
            item_value = string(child.props[Symbol("data-toggle-group-item")])
            is_on = item_value in on_values

            # Create signal for this item (Int32: 0=off, 1=on)
            item_sig, set_item_sig = create_signal(Int32(is_on ? 1 : 0))
            push!(item_signals, (item_sig, set_item_sig))
            push!(items, child)
            item_idx = length(item_signals)

            # Inject BindBool for data-state (off/on)
            child.props[Symbol("data-state")] = BindBool(item_sig, "off", "on")
            child.props[Symbol("data-index")] = string(item_idx - 1)  # 0-indexed for hydration

            # Inject ARIA attributes based on type
            if type == "single"
                child.props[:role] = "radio"
                child.props[:aria_checked] = BindBool(item_sig, "false", "true")
            else
                child.props[:aria_pressed] = BindBool(item_sig, "false", "true")
            end

            # Click handler (unless disabled)
            item_is_disabled = haskey(child.props, Symbol("data-disabled"))
            if !disabled && !item_is_disabled
                let all_sigs = item_signals, my_get = item_sig, my_set = set_item_sig, my_idx = item_idx
                    child.props[:on_click] = function()
                        current = my_get()
                        if type == "single"
                            if current == Int32(1)
                                # Already on — deselect
                                my_set(Int32(0))
                            else
                                # Deselect all, select this
                                for (j, (_, setter)) in enumerate(all_sigs)
                                    if j != my_idx
                                        setter(Int32(0))
                                    end
                                end
                                my_set(Int32(1))
                            end
                        else
                            # Multiple mode — toggle
                            my_set(Int32(1) - current)
                        end
                    end
                end
            end
        end
    end

    base = "inline-flex items-center justify-center gap-1 rounded-lg"
    classes = cn(base, class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    attrs = Pair{Symbol,Any}[
        Symbol("data-toggle-group") => type,
        Symbol("data-orientation") => orientation,
        Symbol("data-variant") => variant,
        Symbol("data-size") => size,
        :role => "group",
        :class => classes,
    ]
    if disabled
        push!(attrs, Symbol("data-disabled") => "")
    end

    Div(attrs..., kwargs..., children...)
end

"""
    ToggleGroupItem(children...; value, variant, size, disabled, class, kwargs...) -> VNode

A single item within a toggle group.

# Props
- `value`: unique identifier for this item (required)
- `variant`: override group variant for this item
- `size`: override group size for this item
- `disabled`: disable this specific item
"""
function ToggleGroupItem(children...; value::String="", variant::String="default",
                              size::String="default", disabled::Bool=false,
                              theme::Symbol=:default, class::String="", kwargs...)
    base = "inline-flex items-center justify-center gap-2 cursor-pointer rounded-md text-sm font-medium text-warm-800 dark:text-warm-300 transition-colors hover:bg-warm-100 dark:hover:bg-warm-900 hover:text-warm-600 dark:hover:text-warm-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 data-[state=on]:bg-warm-100 dark:data-[state=on]:bg-warm-900 data-[state=on]:text-warm-800 dark:data-[state=on]:text-warm-300"

    variant_classes = Dict(
        "default" => "bg-transparent",
        "outline" => "border border-warm-200 dark:border-warm-700 bg-transparent shadow-sm",
    )

    size_classes = Dict(
        "default" => "h-9 px-2 min-w-9",
        "sm"      => "h-8 px-1.5 min-w-8",
        "lg"      => "h-10 px-2.5 min-w-10",
    )

    vc = get(variant_classes, variant, variant_classes["default"])
    sc = get(size_classes, size, size_classes["default"])
    classes = cn(base, vc, sc, class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    attrs = Pair{Symbol,Any}[
        :type => "button",
        Symbol("data-toggle-group-item") => value,
        Symbol("data-state") => "off",
        :class => classes,
    ]
    if disabled
        push!(attrs, :disabled => true)
        push!(attrs, Symbol("data-disabled") => "")
    end

    Therapy.Button(attrs..., kwargs..., children...)
end

# --- Hydration Support ---

const _TOGGLEGROUP_PROPS_TRANSFORM = (props, args) -> begin
    mode = get(props, :type, "single") == "single" ? 0 : 1

    dv = get(props, :default_value, nothing)
    on_values = Set{String}()
    if dv !== nothing
        if dv isa AbstractString
            push!(on_values, dv)
        elseif dv isa AbstractVector
            for v in dv; push!(on_values, string(v)); end
        end
    end

    active_idx = -1
    mask = 0
    item_idx = 0
    for arg in args
        if arg isa Therapy.VNode && haskey(arg.props, Symbol("data-toggle-group-item"))
            val = string(arg.props[Symbol("data-toggle-group-item")])
            if val in on_values
                if mode == 0
                    active_idx = item_idx
                else
                    mask |= (1 << item_idx)
                end
            end
            item_idx += 1
        end
    end

    props[:_a] = mode == 0 ? active_idx : mask
    props[:_m] = mode
    props[:_n] = item_idx
end

const _TOGGLEGROUP_HYDRATION_BODY = quote
    active, set_active = create_signal(compiled_get_prop_i32(Int32(0)))
    m_flag = compiled_get_prop_i32(Int32(1))
    n = compiled_get_prop_i32(Int32(2))
    Div(
        begin
            i = Int32(0)
            while i < n
                Button(
                    if m_flag == Int32(0)
                        Symbol("data-state") => MatchBindBool(active, i, "off", "on")
                    else
                        Symbol("data-state") => BitBindBool(active, i, "off", "on")
                    end,
                    if m_flag == Int32(0)
                        :aria_checked => MatchBindBool(active, i, "false", "true")
                    else
                        :aria_pressed => BitBindBool(active, i, "false", "true")
                    end,
                    :on_click => (e) -> begin
                        idx = compiled_get_event_data_index()
                        if m_flag == Int32(0)
                            if idx == active()
                                set_active(Int32(-1))
                            else
                                set_active(idx)
                            end
                        else
                            set_active(active() ⊻ (Int32(1) << idx))
                        end
                    end,
                )
                i = i + Int32(1)
            end
        end
    )
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :ToggleGroup,
        "ToggleGroup.jl",
        :island,
        "Group of toggle buttons with single or multiple selection",
        Symbol[],
        Symbol[],
        [:ToggleGroup, :ToggleGroupItem],
    ))
end
