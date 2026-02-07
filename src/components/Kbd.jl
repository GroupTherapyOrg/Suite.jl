# Kbd.jl — Suite.jl Kbd Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Kbd("Ctrl")
# Usage via extract: include("components/Kbd.jl"); Kbd("Ctrl")
#
# Renders keyboard shortcut keys as styled <kbd> elements.
# Sessions.jl uses this to display keyboard shortcuts in the UI.

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Kbd

"""
    Kbd(children...; class, kwargs...) -> VNode

A styled keyboard key indicator, rendering text as a `<kbd>` element.

# Examples
```julia
Kbd("Ctrl")
Div(Kbd("Ctrl"), " + ", Kbd("Enter"))
Div(Kbd("⌘"), Kbd("K"))
```
"""
function Kbd(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn(
        "pointer-events-none inline-flex h-5 items-center justify-center gap-1 rounded border border-warm-200 dark:border-warm-700 bg-warm-100 dark:bg-warm-900 px-1.5 font-mono text-[10px] font-medium text-warm-600 dark:text-warm-400 select-none",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    props = Dict{Symbol, Any}(:class => classes)
    for (k, v) in kwargs
        props[k] = v
    end
    VNode(:kbd, props, collect(Any, children))
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Kbd,
        "Kbd.jl",
        :styling,
        "Keyboard shortcut key indicator",
        Symbol[],
        Symbol[],
        [:Kbd],
    ))
end
