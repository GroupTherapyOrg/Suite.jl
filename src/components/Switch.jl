# Switch.jl — Suite.jl Switch Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none
# JS Modules: none
#
# Usage via package: using Suite; Switch()
# Usage via extract: include("components/Switch.jl"); Switch()
#
# Behavior:
#   - A toggle switch (role=switch) with sliding thumb
#   - Signal-driven: BindBool maps checked signal to data-state and aria-checked
#   - Clicking toggles checked state via Wasm handler
#   - Thumb animation via CSS translateX (no JS animation)
#   - Native <button> provides Enter/Space keyboard support
#   - Thumb data-state is auto-updated by set_data_state_bool (switch mode)
#
# Reference: Radix UI Switch — https://www.radix-ui.com/primitives/docs/components/switch
# Reference: WAI-ARIA Switch — https://www.w3.org/WAI/ARIA/apg/patterns/switch/

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Switch

#   Switch(; checked, disabled, size, class, kwargs...) -> IslandVNode
#
# A toggle switch with sliding thumb animation.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# Props: checked (default false), disabled, size ("default" or "sm")
# Examples: Switch(), Switch(checked=true), Switch(size="sm", disabled=true)
@island function Switch(; checked::Bool=false, disabled::Bool=false,
                     size::String="default", theme::Symbol=:default,
                     class::String="", kwargs...)
    # Signal for checked state (Int32: 0=unchecked, 1=checked)
    is_checked, set_checked = create_signal(Int32(checked ? 1 : 0))

    # Track dimensions
    track_sizes = Dict(
        "default" => "h-5 w-9",
        "sm"      => "h-3.5 w-6",
    )
    thumb_sizes = Dict(
        "default" => "size-4",
        "sm"      => "size-3",
    )

    track_size = get(track_sizes, size, track_sizes["default"])
    thumb_size = get(thumb_sizes, size, thumb_sizes["default"])

    track_base = "peer inline-flex shrink-0 cursor-pointer items-center rounded-full border-2 border-transparent shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600 focus-visible:ring-offset-2 focus-visible:ring-offset-warm-50 dark:focus-visible:ring-offset-warm-950 disabled:cursor-not-allowed disabled:opacity-50 data-[state=checked]:bg-accent-600 data-[state=unchecked]:bg-warm-200 dark:data-[state=unchecked]:bg-warm-700"
    track_classes = cn(track_base, track_size, class)

    thumb_base = "pointer-events-none block rounded-full bg-warm-50 dark:bg-warm-950 shadow-lg ring-0 transition-transform data-[state=checked]:translate-x-[calc(100%+2px)] data-[state=unchecked]:translate-x-0"
    thumb_classes = cn(thumb_base, thumb_size)

    if theme !== :default
        t = get_theme(theme)
        track_classes = apply_theme(track_classes, t)
        thumb_classes = apply_theme(thumb_classes, t)
    end

    attrs = Pair{Symbol,Any}[
        :type => "button",
        :role => "switch",
        Symbol("data-state") => BindBool(is_checked, "unchecked", "checked"),
        :aria_checked => BindBool(is_checked, "false", "true"),
        :class => track_classes,
    ]
    if disabled
        push!(attrs, :disabled => true)
        push!(attrs, Symbol("data-disabled") => "")
    end

    Therapy.Button(attrs...,
        :on_click => () -> set_checked(Int32(1) - is_checked()),
        kwargs...,
        Span(Symbol("data-state") => BindBool(is_checked, "unchecked", "checked"), :class => thumb_classes))
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Switch,
        "Switch.jl",
        :island,
        "Toggle switch with sliding thumb",
        Symbol[],
        Symbol[],
        [:Switch],
    ))
end
