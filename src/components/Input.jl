# SuiteInput.jl — Suite.jl Input Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; SuiteInput(type="email", placeholder="Email")
# Usage via extract: include("components/Input.jl"); SuiteInput(...)
#
# Reference: shadcn/ui Input — https://ui.shadcn.com/docs/components/input

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteInput

"""
    SuiteInput(; type, class, kwargs...) -> VNode

A styled text input field.
Equivalent to shadcn/ui's Input component.

# Examples
```julia
SuiteInput(placeholder="Email")
SuiteInput(type="password", placeholder="Password")
SuiteInput(type="file")
SuiteInput(:disabled => true, placeholder="Disabled")
```
"""
function SuiteInput(; type::String="text", class::String="", kwargs...)
    classes = cn(
        "h-9 w-full min-w-0 rounded-md border border-warm-200 dark:border-warm-700 bg-transparent px-3 py-1 text-base shadow-sm transition-colors outline-none",
        "placeholder:text-warm-500 dark:placeholder:text-warm-600",
        "focus-visible:border-accent-600 focus-visible:ring-2 focus-visible:ring-accent-600/50",
        "disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50",
        "file:text-warm-800 dark:file:text-warm-300 file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium",
        "md:text-sm",
        class,
    )

    Input(:type => type, :class => classes, kwargs...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Input,
        "Input.jl",
        :styling,
        "Styled text input field",
        Symbol[],
        Symbol[],
        [:SuiteInput],
    ))
end
