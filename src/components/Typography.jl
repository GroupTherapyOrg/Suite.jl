# SuiteTypography.jl — Suite.jl Typography Components
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; SuiteH1("Welcome")
# Usage via extract: include("components/Typography.jl"); SuiteH1(...)
#
# Reference: shadcn/ui Typography — https://ui.shadcn.com/docs/components/typography

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteH1, SuiteH2, SuiteH3, SuiteH4,
       SuiteP, SuiteBlockquote, SuiteInlineCode,
       SuiteLead, SuiteLarge, SuiteSmall, SuiteMuted

"""
    SuiteH1(children...; class, kwargs...) -> VNode

Large heading (h1). For page titles.
"""
function SuiteH1(children...; class::String="", kwargs...)
    classes = cn("scroll-m-20 text-4xl font-extrabold tracking-tight lg:text-5xl", class)
    H1(:class => classes, kwargs..., children...)
end

"""
    SuiteH2(children...; class, kwargs...) -> VNode

Section heading (h2) with bottom border.
"""
function SuiteH2(children...; class::String="", kwargs...)
    classes = cn("scroll-m-20 border-b border-warm-200 dark:border-warm-700 pb-2 text-3xl font-semibold tracking-tight first:mt-0", class)
    H2(:class => classes, kwargs..., children...)
end

"""
    SuiteH3(children...; class, kwargs...) -> VNode

Sub-section heading (h3).
"""
function SuiteH3(children...; class::String="", kwargs...)
    classes = cn("scroll-m-20 text-2xl font-semibold tracking-tight", class)
    H3(:class => classes, kwargs..., children...)
end

"""
    SuiteH4(children...; class, kwargs...) -> VNode

Minor heading (h4).
"""
function SuiteH4(children...; class::String="", kwargs...)
    classes = cn("scroll-m-20 text-xl font-semibold tracking-tight", class)
    H4(:class => classes, kwargs..., children...)
end

"""
    SuiteP(children...; class, kwargs...) -> VNode

Paragraph text with spacing.
"""
function SuiteP(children...; class::String="", kwargs...)
    classes = cn("leading-7 [&:not(:first-child)]:mt-6", class)
    P(:class => classes, kwargs..., children...)
end

"""
    SuiteBlockquote(children...; class, kwargs...) -> VNode

Styled blockquote with left border.
"""
function SuiteBlockquote(children...; class::String="", kwargs...)
    classes = cn("mt-6 border-l-2 border-warm-200 dark:border-warm-700 pl-6 italic text-warm-600 dark:text-warm-500", class)
    Blockquote(:class => classes, kwargs..., children...)
end

"""
    SuiteInlineCode(children...; class, kwargs...) -> VNode

Inline code snippet styling.
"""
function SuiteInlineCode(children...; class::String="", kwargs...)
    classes = cn("relative rounded bg-warm-100 dark:bg-warm-900 px-[0.3rem] py-[0.2rem] font-mono text-sm font-semibold", class)
    Code(:class => classes, kwargs..., children...)
end

"""
    SuiteLead(children...; class, kwargs...) -> VNode

Lead paragraph — larger, muted text for introductions.
"""
function SuiteLead(children...; class::String="", kwargs...)
    classes = cn("text-xl text-warm-600 dark:text-warm-500", class)
    P(:class => classes, kwargs..., children...)
end

"""
    SuiteLarge(children...; class, kwargs...) -> VNode

Large emphasized text.
"""
function SuiteLarge(children...; class::String="", kwargs...)
    classes = cn("text-lg font-semibold", class)
    Div(:class => classes, kwargs..., children...)
end

"""
    SuiteSmall(children...; class, kwargs...) -> VNode

Small text with medium weight.
"""
function SuiteSmall(children...; class::String="", kwargs...)
    classes = cn("text-sm font-medium leading-none", class)
    Span(:class => classes, kwargs..., children...)
end

"""
    SuiteMuted(children...; class, kwargs...) -> VNode

Muted secondary text.
"""
function SuiteMuted(children...; class::String="", kwargs...)
    classes = cn("text-sm text-warm-600 dark:text-warm-500", class)
    P(:class => classes, kwargs..., children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Typography,
        "Typography.jl",
        :styling,
        "Heading, paragraph, blockquote, code, and text styling components",
        Symbol[],
        Symbol[],
        [:SuiteH1, :SuiteH2, :SuiteH3, :SuiteH4, :SuiteP, :SuiteBlockquote,
         :SuiteInlineCode, :SuiteLead, :SuiteLarge, :SuiteSmall, :SuiteMuted],
    ))
end
