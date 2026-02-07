# SuiteTextarea.jl — Suite.jl Textarea Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; SuiteTextarea(placeholder="Enter text...")
# Usage via extract: include("components/Textarea.jl"); SuiteTextarea(...)
#
# Reference: shadcn/ui Textarea — https://ui.shadcn.com/docs/components/textarea

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteTextarea

"""
    SuiteTextarea(; class, kwargs...) -> VNode

A styled multi-line text input.
Equivalent to shadcn/ui's Textarea component.

# Examples
```julia
SuiteTextarea(placeholder="Type your message here.")
SuiteTextarea(:rows => "5", placeholder="Bio")
SuiteTextarea(:disabled => true, placeholder="Disabled")
```
"""
function SuiteTextarea(; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn(
        "min-h-16 w-full rounded-md border border-warm-200 dark:border-warm-700 bg-transparent px-3 py-2 text-base shadow-sm transition-colors outline-none",
        "placeholder:text-warm-500 dark:placeholder:text-warm-600",
        "focus-visible:border-accent-600 focus-visible:ring-2 focus-visible:ring-accent-600/50",
        "disabled:cursor-not-allowed disabled:opacity-50",
        "md:text-sm",
        class,
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Textarea(:class => classes, kwargs...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Textarea,
        "Textarea.jl",
        :styling,
        "Styled multi-line text input",
        Symbol[],
        Symbol[],
        [:SuiteTextarea],
    ))
end
