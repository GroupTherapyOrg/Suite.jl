# SuiteSwitch.jl — Suite.jl Switch Component
#
# Tier: js_runtime (requires suite.js for checked state toggle)
# Suite Dependencies: none
# JS Modules: Switch
#
# Usage via package: using Suite; SuiteSwitch()
# Usage via extract: include("components/Switch.jl"); SuiteSwitch()
#
# Behavior:
#   - A toggle switch (role=switch) with sliding thumb
#   - JS discovers via data-suite-switch attribute
#   - Clicking toggles aria-checked and data-state
#   - Thumb animation via CSS translateX (no JS animation)
#   - Native <button> provides Enter/Space keyboard support
#
# Reference: Radix UI Switch — https://www.radix-ui.com/primitives/docs/components/switch
# Reference: WAI-ARIA Switch — https://www.w3.org/WAI/ARIA/apg/patterns/switch/

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteSwitch

"""
    SuiteSwitch(; checked, disabled, size, class, kwargs...) -> VNode

A toggle switch with sliding thumb animation.

Requires `suite_script()` in your layout for JS behavior.

# Props
- `checked`: initial checked state (default `false`)
- `disabled`: disable the switch
- `size`: `"default"` or `"sm"`

# Examples
```julia
SuiteSwitch()
SuiteSwitch(checked=true)
SuiteSwitch(size="sm", disabled=true)
```
"""
function SuiteSwitch(; checked::Bool=false, disabled::Bool=false,
                     size::String="default", class::String="", kwargs...)
    state = checked ? "checked" : "unchecked"

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

    attrs = Pair{Symbol,Any}[
        :type => "button",
        :role => "switch",
        Symbol("data-suite-switch") => "",
        Symbol("data-state") => state,
        :aria_checked => string(checked),
        :class => track_classes,
    ]
    if disabled
        push!(attrs, :disabled => true)
        push!(attrs, Symbol("data-disabled") => "")
    end

    Button(attrs..., kwargs...,
        Span(Symbol("data-state") => state, :class => thumb_classes))
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Switch,
        "Switch.jl",
        :js_runtime,
        "Toggle switch with sliding thumb",
        Symbol[],
        [:Switch],
        [:SuiteSwitch],
    ))
end
