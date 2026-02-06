# SuiteToggle.jl — Suite.jl Toggle Component
#
# Tier: js_runtime (requires suite.js for pressed state toggle)
# Suite Dependencies: none
# JS Modules: Toggle
#
# Usage via package: using Suite; SuiteToggle("B")
# Usage via extract: include("components/Toggle.jl"); SuiteToggle("B")
#
# Behavior:
#   - A button that toggles between pressed/unpressed states
#   - JS discovers via data-suite-toggle attribute
#   - Clicking toggles aria-pressed and data-state
#   - Native <button> provides Enter/Space keyboard support
#
# Reference: Radix UI Toggle — https://www.radix-ui.com/primitives/docs/components/toggle

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteToggle

"""
    SuiteToggle(children...; variant, size, pressed, disabled, class, kwargs...) -> VNode

A two-state toggle button (pressed/unpressed).

Requires `suite_script()` in your layout for JS behavior.

# Variants
- `"default"`: Transparent background, accent when pressed
- `"outline"`: Border with shadow, accent when pressed

# Sizes
- `"default"`: h-9 px-2 min-w-9
- `"sm"`: h-8 px-1.5 min-w-8
- `"lg"`: h-10 px-2.5 min-w-10

# Examples
```julia
SuiteToggle("B")
SuiteToggle(variant="outline", "I")
SuiteToggle(pressed=true, "Bold")
```
"""
function SuiteToggle(children...; variant::String="default", size::String="default",
                     pressed::Bool=false, disabled::Bool=false,
                     class::String="", kwargs...)
    base = "inline-flex items-center justify-center gap-2 rounded-md text-sm font-medium transition-colors hover:bg-warm-100 dark:hover:bg-warm-900 hover:text-warm-600 dark:hover:text-warm-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 data-[state=on]:bg-warm-100 dark:data-[state=on]:bg-warm-900 data-[state=on]:text-warm-800 dark:data-[state=on]:text-warm-300"

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
    state = pressed ? "on" : "off"
    classes = cn(base, vc, sc, class)

    attrs = Pair{Symbol,Any}[
        :type => "button",
        Symbol("data-suite-toggle") => "",
        Symbol("data-state") => state,
        :aria_pressed => string(pressed),
        :class => classes,
    ]
    if disabled
        push!(attrs, :disabled => true)
        push!(attrs, Symbol("data-disabled") => "")
    end

    Button(attrs..., kwargs..., children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Toggle,
        "Toggle.jl",
        :js_runtime,
        "Two-state toggle button (pressed/unpressed)",
        Symbol[],
        [:Toggle],
        [:SuiteToggle],
    ))
end
