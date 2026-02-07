# Empty.jl — Suite.jl Empty Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Empty(title="No results", description="Try a different search query.")
# Usage via extract: include("components/Empty.jl"); Empty(...)
#
# Empty state placeholder. Sessions.jl uses this for "No notebooks open", etc.

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Empty, EmptyIcon, EmptyTitle, EmptyDescription, EmptyAction

"""
    Empty(children...; class, kwargs...) -> VNode

An empty state placeholder container for when there's no content to display.

Compose with sub-components:

```julia
Empty(
    EmptyIcon(Spinner()),
    EmptyTitle("No notebooks open"),
    EmptyDescription("Create a new notebook or open an existing one."),
    EmptyAction(Button("New Notebook"))
)
```
"""
function Empty(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("flex min-h-[200px] flex-col items-center justify-center gap-3 rounded-lg border border-dashed border-warm-200 dark:border-warm-700 p-8 text-center", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(:class => classes, kwargs..., children...)
end

"""
    EmptyIcon(children...; class, kwargs...) -> VNode

Icon slot for an Empty state. Wraps an icon or illustration.
"""
function EmptyIcon(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("flex h-12 w-12 items-center justify-center rounded-full bg-warm-100 dark:bg-warm-900 text-warm-500 dark:text-warm-400", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(:class => classes, kwargs..., children...)
end

"""
    EmptyTitle(children...; class, kwargs...) -> VNode

Title text for an Empty state.
"""
function EmptyTitle(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("text-lg font-semibold text-warm-800 dark:text-warm-300", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Therapy.H3(:class => classes, kwargs..., children...)
end

"""
    EmptyDescription(children...; class, kwargs...) -> VNode

Descriptive text for an Empty state.
"""
function EmptyDescription(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("text-sm text-warm-600 dark:text-warm-400 max-w-sm", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Therapy.P(:class => classes, kwargs..., children...)
end

"""
    EmptyAction(children...; class, kwargs...) -> VNode

Action slot for an Empty state. Typically wraps a Button.
"""
function EmptyAction(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("mt-2", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(:class => classes, kwargs..., children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Empty,
        "Empty.jl",
        :styling,
        "Empty state placeholder with icon, title, description, and action",
        Symbol[],
        Symbol[],
        [:Empty, :EmptyIcon, :EmptyTitle, :EmptyDescription, :EmptyAction],
    ))
end
