# SuiteButton.jl — Suite.jl Button Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; SuiteButton("Click")
# Usage via extract: include("components/Button.jl"); SuiteButton("Click")
#
# Reference: shadcn/ui Button — https://ui.shadcn.com/docs/components/button

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteButton

"""
    SuiteButton(children...; variant, size, class, kwargs...) -> VNode

A clickable button with multiple visual variants and sizes.
Equivalent to shadcn/ui's Button component.

# Variants
- `"default"`: Primary accent background (purple)
- `"destructive"`: Red/danger background
- `"outline"`: Bordered, transparent background
- `"secondary"`: Warm neutral background
- `"ghost"`: Transparent, hover shows background
- `"link"`: Styled as a hyperlink

# Sizes
- `"default"`: Standard (h-10 px-4 py-2)
- `"sm"`: Small (h-9 px-3)
- `"lg"`: Large (h-11 px-8)
- `"icon"`: Square icon button (h-10 w-10)

# Examples
```julia
SuiteButton("Click me")
SuiteButton(variant="outline", size="sm", "Settings")
SuiteButton(variant="destructive", "Delete")
SuiteButton(variant="icon", size="icon", "✕")
```
"""
function SuiteButton(children...; variant::String="default", size::String="default",
                     class::String="", kwargs...)
    base = "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50"

    variant_classes = Dict(
        "default"     => "bg-accent-600 text-white hover:bg-accent-700",
        "destructive" => "bg-accent-secondary-600 text-white hover:bg-accent-secondary-700",
        "outline"     => "border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-950 hover:bg-warm-100 dark:hover:bg-warm-900 text-warm-800 dark:text-warm-300",
        "secondary"   => "bg-warm-100 dark:bg-warm-900 text-warm-800 dark:text-warm-300 hover:bg-warm-200 dark:hover:bg-warm-800",
        "ghost"       => "hover:bg-warm-100 dark:hover:bg-warm-900 text-warm-800 dark:text-warm-300",
        "link"        => "text-accent-600 dark:text-accent-400 underline-offset-4 hover:underline",
    )

    size_classes = Dict(
        "default" => "h-10 px-4 py-2",
        "sm"      => "h-9 rounded-md px-3",
        "lg"      => "h-11 rounded-md px-8",
        "icon"    => "h-10 w-10",
    )

    vc = get(variant_classes, variant, variant_classes["default"])
    sc = get(size_classes, size, size_classes["default"])
    classes = cn(base, vc, sc, class)

    Button(:class => classes, kwargs..., children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Button,
        "Button.jl",
        :styling,
        "Clickable button with multiple variants and sizes",
        Symbol[],
        Symbol[],
        [:SuiteButton],
    ))
end
