# Toggle.jl — Suite.jl Toggle Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none
# JS Modules: none
#
# Usage via package: using Suite; Toggle("B")
# Usage via extract: include("components/Toggle.jl"); Toggle("B")
#
# Behavior:
#   - A button that toggles between pressed/unpressed states
#   - Signal-driven: BindBool maps pressed signal to data-state and aria-pressed
#   - Clicking toggles pressed state via Wasm handler
#   - Native <button> provides Enter/Space keyboard support
#
# Reference: Radix UI Toggle — https://www.radix-ui.com/primitives/docs/components/toggle

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Toggle

#   Toggle(children...; variant, size, pressed, disabled, class, kwargs...) -> IslandVNode
#
# A two-state toggle button (pressed/unpressed).
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# Variants: "default" (transparent bg), "outline" (border + shadow)
# Sizes: "default" (h-9), "sm" (h-8), "lg" (h-10)
# Examples: Toggle("B"), Toggle(variant="outline", "I"), Toggle(pressed=true, "Bold")
@island function Toggle(children...; variant::String="default", size::String="default",
                     pressed::Bool=false, disabled::Bool=false,
                     theme::Symbol=:default, class::String="", kwargs...)
    # Signal for pressed state (Int32: 0=off, 1=on)
    is_pressed, set_pressed = create_signal(Int32(pressed ? 1 : 0))

    base = "inline-flex items-center justify-center gap-2 cursor-pointer rounded-md text-sm font-medium text-warm-800 dark:text-warm-300 transition-colors hover:bg-warm-100 dark:hover:bg-warm-900 hover:text-warm-600 dark:hover:text-warm-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 data-[state=on]:bg-warm-100 dark:data-[state=on]:bg-warm-900 data-[state=on]:text-warm-800 dark:data-[state=on]:text-warm-300"

    variant_classes = Dict(
        "default" => "bg-transparent",
        "outline" => "border border-warm-200 dark:border-warm-700 bg-transparent shadow-sm hover:bg-warm-100 dark:hover:bg-warm-900",
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
        Symbol("data-state") => BindBool(is_pressed, "off", "on"),
        :aria_pressed => BindBool(is_pressed, "false", "true"),
        :class => classes,
    ]
    if disabled
        push!(attrs, :disabled => true)
        push!(attrs, Symbol("data-disabled") => "")
    end

    Therapy.Button(attrs...,
        :on_click => () -> set_pressed(Int32(1) - is_pressed()),
        kwargs..., children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Toggle,
        "Toggle.jl",
        :island,
        "Two-state toggle button (pressed/unpressed)",
        Symbol[],
        Symbol[],
        [:Toggle],
    ))
end
