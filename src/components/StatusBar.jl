# StatusBar.jl — Suite.jl StatusBar Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; StatusBar(StatusBarSection(StatusBarItem("Ready")))
# Usage via extract: include("components/StatusBar.jl"); StatusBar(...)
#
# IDE-style bottom status bar with left/center/right sections.
# Sessions.jl uses this for the bottom IDE status bar.

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export StatusBar, StatusBarSection, StatusBarItem

"""
    StatusBar(children...; class, kwargs...) -> VNode

An IDE-style horizontal status bar, typically at the bottom of the viewport.

Compose with StatusBarSection and StatusBarItem:

```julia
StatusBar(
    StatusBarSection(position="left",
        StatusBarItem("Ready"),
        StatusBarItem("UTF-8"),
    ),
    StatusBarSection(position="right",
        StatusBarItem("Ln 42, Col 8"),
        StatusBarItem("Julia 1.12"),
    ),
)
```
"""
function StatusBar(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("flex items-center justify-between border-t border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-900 px-3 py-0 h-7 text-xs", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(:class => classes, :role => "status", kwargs..., children...)
end

"""
    StatusBarSection(children...; position, class, kwargs...) -> VNode

A section of the status bar. Position controls alignment.

# Options
- `position`: `"left"` (default), `"center"`, or `"right"`
"""
function StatusBarSection(children...; position::String="left", class::String="", theme::Symbol=:default, kwargs...)
    position_classes = Dict(
        "left"   => "justify-start",
        "center" => "justify-center flex-1",
        "right"  => "justify-end ml-auto",
    )

    pc = get(position_classes, position, position_classes["left"])
    classes = cn("flex items-center gap-3", pc, class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(:class => classes, kwargs..., children...)
end

"""
    StatusBarItem(children...; clickable, class, kwargs...) -> VNode

A status indicator item. Can be clickable.

# Options
- `clickable`: If `true`, renders as a hover-interactive element (default: `false`)
"""
function StatusBarItem(children...; clickable::Bool=false, class::String="", theme::Symbol=:default, kwargs...)
    base = "inline-flex items-center gap-1.5 text-warm-600 dark:text-warm-400 whitespace-nowrap select-none"
    interactive = clickable ? "cursor-pointer hover:text-warm-800 dark:hover:text-warm-200 hover:bg-warm-100 dark:hover:bg-warm-800 rounded px-1.5 py-0.5 -my-0.5 transition-colors" : ""

    classes = cn(base, interactive, class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Span(:class => classes, kwargs..., children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :StatusBar,
        "StatusBar.jl",
        :styling,
        "IDE-style bottom status bar with sections",
        Symbol[],
        Symbol[],
        [:StatusBar, :StatusBarSection, :StatusBarItem],
    ))
end
