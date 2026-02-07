# Toolbar.jl — Suite.jl Toolbar Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (composes with Button and Separator)
# JS Modules: none
#
# Usage via package: using Suite; Toolbar(ToolbarGroup(Button(size="icon", "B"), Button(size="icon", "I")))
# Usage via extract: include("components/Toolbar.jl"); Toolbar(...)
#
# Horizontal toolbar with grouped actions and optional separators.
# Sessions.jl uses this for cell action buttons and notebook toolbar.

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Toolbar, ToolbarGroup, ToolbarSeparator

"""
    Toolbar(children...; class, kwargs...) -> VNode

A horizontal toolbar container for grouped actions.

# Examples
```julia
Toolbar(
    ToolbarGroup(
        Button(size="icon", variant="ghost", "B"),
        Button(size="icon", variant="ghost", "I"),
        Button(size="icon", variant="ghost", "U"),
    ),
    ToolbarSeparator(),
    ToolbarGroup(
        Button(size="icon", variant="ghost", "⌗"),
    ),
)
```
"""
function Toolbar(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("inline-flex items-center gap-1 rounded-lg border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-900 p-1", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(:class => classes, :role => "toolbar", kwargs..., children...)
end

"""
    ToolbarGroup(children...; class, kwargs...) -> VNode

A group of related toolbar items displayed together.
"""
function ToolbarGroup(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("flex items-center gap-0.5", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(:class => classes, :role => "group", kwargs..., children...)
end

"""
    ToolbarSeparator(; class, kwargs...) -> VNode

A vertical separator between toolbar groups.
"""
function ToolbarSeparator(; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("mx-1 h-6 w-px shrink-0 bg-warm-200 dark:bg-warm-700", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(:class => classes, :role => "none", kwargs...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Toolbar,
        "Toolbar.jl",
        :styling,
        "Horizontal toolbar with grouped actions",
        Symbol[],
        Symbol[],
        [:Toolbar, :ToolbarGroup, :ToolbarSeparator],
    ))
end
