# Spinner.jl — Suite.jl Spinner Component
#
# Tier: styling (pure HTML + Tailwind CSS animation, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Spinner()
# Usage via extract: include("components/Spinner.jl"); Spinner()
#
# Animated loading spinner. Sessions.jl uses this for cell execution loading.

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Spinner

"""
    Spinner(; size, class, kwargs...) -> VNode

An animated loading spinner using SVG + CSS animation.

# Sizes
- `"sm"`: 16×16 (h-4 w-4)
- `"default"`: 24×24 (h-6 w-6)
- `"lg"`: 32×32 (h-8 w-8)

# Examples
```julia
Spinner()
Spinner(size="sm")
Spinner(size="lg")
Spinner(class="text-accent-secondary-600")
```
"""
function Spinner(; size::String="default", class::String="", theme::Symbol=:default, kwargs...)
    size_classes = Dict(
        "sm"      => "h-4 w-4",
        "default" => "h-6 w-6",
        "lg"      => "h-8 w-8",
    )

    sc = get(size_classes, size, size_classes["default"])
    classes = cn("animate-spin text-accent-600 dark:text-accent-400", sc, class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    # SVG spinner — circle with a gap (strokeDasharray trick)
    Svg(:class => classes, :viewBox => "0 0 24 24", :fill => "none",
        :xmlns => "http://www.w3.org/2000/svg",
        Symbol("aria-hidden") => "true",
        kwargs...,
        Circle(:cx => "12", :cy => "12", :r => "10", :stroke => "currentColor",
               :stroke_width => "4", :class => "opacity-25"),
        Path(:d => "M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z",
             :fill => "currentColor", :class => "opacity-75"),
    )
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Spinner,
        "Spinner.jl",
        :styling,
        "Animated loading spinner indicator",
        Symbol[],
        Symbol[],
        [:Spinner],
    ))
end
