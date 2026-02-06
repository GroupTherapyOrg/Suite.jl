# SuiteAlert.jl — Suite.jl Alert Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; SuiteAlert(SuiteAlertTitle("Heads up"), SuiteAlertDescription("..."))
# Usage via extract: include("components/Alert.jl"); SuiteAlert(...)
#
# Reference: shadcn/ui Alert — https://ui.shadcn.com/docs/components/alert

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteAlert, SuiteAlertTitle, SuiteAlertDescription

"""
    SuiteAlert(children...; variant, class, kwargs...) -> VNode

A callout alert box with title and description.
Equivalent to shadcn/ui's Alert component.

# Variants
- `"default"`: Neutral card background
- `"destructive"`: Red destructive text

# Examples
```julia
SuiteAlert(
    SuiteAlertTitle("Heads up!"),
    SuiteAlertDescription("You can add components using the CLI."),
)
SuiteAlert(variant="destructive",
    SuiteAlertTitle("Error"),
    SuiteAlertDescription("Something went wrong."),
)
```
"""
function SuiteAlert(children...; variant::String="default", class::String="", kwargs...)
    base = "relative w-full rounded-lg border px-4 py-3 text-sm grid gap-1"

    variant_classes = Dict(
        "default"     => "bg-warm-100 dark:bg-warm-900 text-warm-800 dark:text-warm-300 border-warm-200 dark:border-warm-700",
        "destructive" => "bg-warm-100 dark:bg-warm-900 text-accent-secondary-600 dark:text-accent-secondary-400 border-accent-secondary-600/20 dark:border-accent-secondary-400/20",
    )

    vc = get(variant_classes, variant, variant_classes["default"])
    classes = cn(base, vc, class)

    Div(:role => "alert", :class => classes, kwargs..., children...)
end

"""
    SuiteAlertTitle(children...; class, kwargs...) -> VNode

Title text inside a SuiteAlert.
"""
function SuiteAlertTitle(children...; class::String="", kwargs...)
    classes = cn("font-medium leading-none tracking-tight", class)
    Div(:class => classes, kwargs..., children...)
end

"""
    SuiteAlertDescription(children...; class, kwargs...) -> VNode

Description text inside a SuiteAlert.
"""
function SuiteAlertDescription(children...; class::String="", kwargs...)
    classes = cn("text-sm text-warm-600 dark:text-warm-500", class)
    Div(:class => classes, kwargs..., children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Alert,
        "Alert.jl",
        :styling,
        "Callout alert box with title and description",
        Symbol[],
        Symbol[],
        [:SuiteAlert, :SuiteAlertTitle, :SuiteAlertDescription],
    ))
end
