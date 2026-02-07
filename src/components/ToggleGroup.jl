# SuiteToggleGroup.jl — Suite.jl Toggle Group Component
#
# Tier: js_runtime (requires suite.js for selection management + roving focus)
# Suite Dependencies: none (contains own toggle item rendering)
# JS Modules: ToggleGroup
#
# Usage via package: using Suite; SuiteToggleGroup(...)
# Usage via extract: include("components/ToggleGroup.jl"); SuiteToggleGroup(...)
#
# Behavior:
#   - Single mode: one item selected at a time, deselection allowed
#   - Multiple mode: any combination of items selected
#   - Single mode: items use role=radio + aria-checked (NOT aria-pressed!)
#   - Multiple mode: items use aria-pressed
#   - Optional roving focus: arrow keys move focus between items
#
# Reference: Radix UI ToggleGroup — https://www.radix-ui.com/primitives/docs/components/toggle-group

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteToggleGroup, SuiteToggleGroupItem

"""
    SuiteToggleGroup(children...; type, default_value, variant, size, orientation, disabled, class, kwargs...) -> VNode

A group of toggle buttons where selection is managed collectively.

Requires `suite_script()` in your layout for JS behavior.

# Props
- `type`: `"single"` (default) or `"multiple"` — selection mode
- `default_value`: initially selected value(s) — String for single, Vector{String} for multiple
- `variant`: `"default"` or `"outline"` — passed to items
- `size`: `"default"`, `"sm"`, or `"lg"` — passed to items
- `orientation`: `"horizontal"` (default) or `"vertical"` — affects arrow key directions
- `disabled`: disable all items

# Examples
```julia
# Single selection
SuiteToggleGroup(type="single", default_value="center",
    SuiteToggleGroupItem(value="left", "Left"),
    SuiteToggleGroupItem(value="center", "Center"),
    SuiteToggleGroupItem(value="right", "Right"),
)

# Multiple selection, outline variant
SuiteToggleGroup(type="multiple", variant="outline",
    SuiteToggleGroupItem(value="bold", "B"),
    SuiteToggleGroupItem(value="italic", "I"),
    SuiteToggleGroupItem(value="underline", "U"),
)
```
"""
function SuiteToggleGroup(children...; type::String="single", default_value=nothing,
                          variant::String="default", size::String="default",
                          orientation::String="horizontal", disabled::Bool=false,
                          theme::Symbol=:default, class::String="", kwargs...)
    base = "inline-flex items-center justify-center gap-1 rounded-lg"
    classes = cn(base, class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    attrs = Pair{Symbol,Any}[
        Symbol("data-suite-toggle-group") => type,
        Symbol("data-orientation") => orientation,
        Symbol("data-variant") => variant,
        Symbol("data-size") => size,
        :role => "group",
        :class => classes,
    ]
    if disabled
        push!(attrs, Symbol("data-disabled") => "")
    end

    # Pass default value info for JS init
    if default_value !== nothing
        if default_value isa AbstractString
            push!(attrs, Symbol("data-default-value") => default_value)
        elseif default_value isa AbstractVector
            push!(attrs, Symbol("data-default-value") => join(default_value, ","))
        end
    end

    Div(attrs..., kwargs..., children...)
end

"""
    SuiteToggleGroupItem(children...; value, variant, size, disabled, class, kwargs...) -> VNode

A single item within a toggle group.

# Props
- `value`: unique identifier for this item (required)
- `variant`: override group variant for this item
- `size`: override group size for this item
- `disabled`: disable this specific item
"""
function SuiteToggleGroupItem(children...; value::String="", variant::String="default",
                              size::String="default", disabled::Bool=false,
                              theme::Symbol=:default, class::String="", kwargs...)
    base = "inline-flex items-center justify-center gap-2 rounded-md text-sm font-medium transition-colors hover:bg-warm-100 dark:hover:bg-warm-900 hover:text-warm-600 dark:hover:text-warm-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 data-[state=on]:bg-warm-100 dark:data-[state=on]:bg-warm-900 data-[state=on]:text-warm-800 dark:data-[state=on]:text-warm-300"

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
        Symbol("data-suite-toggle-group-item") => value,
        Symbol("data-state") => "off",
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
        :ToggleGroup,
        "ToggleGroup.jl",
        :js_runtime,
        "Group of toggle buttons with single/multiple selection",
        Symbol[],
        [:ToggleGroup],
        [:SuiteToggleGroup, :SuiteToggleGroupItem],
    ))
end
