# Suite.jl Theme System
#
# Provides 4 pre-built themes that control the visual personality of components.
# Themes work via string substitution on Tailwind class strings.
# Default theme is a no-op (zero overhead).

export SuiteTheme, get_theme, resolve_theme, apply_theme, SUITE_THEMES

"""
A named theme that controls the visual personality of Suite.jl components.
"""
struct SuiteTheme
    name::Symbol
    color_scheme::Symbol
    accent::String
    accent_secondary::String
    neutral::String
    radius::String
    radius_sm::String
    ring::String
    font_weight::String
    shadow::String
    border_width::String
    description::String
end

const SUITE_THEMES = Dict{Symbol, SuiteTheme}(
    :default => SuiteTheme(
        :default, :auto,
        "accent", "accent-secondary", "warm",
        "rounded-md", "rounded-sm",
        "accent-600", "font-medium", "shadow-sm", "border",
        "The classic Suite.jl look — warm scholarly tones with purple accents",
    ),
    :ocean => SuiteTheme(
        :ocean, :auto,
        "blue", "rose", "warm",
        "rounded-lg", "rounded-md",
        "blue-500", "font-medium", "shadow-md", "border",
        "Cool blue accent — professional and confident",
    ),
    :minimal => SuiteTheme(
        :minimal, :auto,
        "zinc", "red", "slate",
        "rounded-none", "rounded-none",
        "zinc-500", "font-semibold", "shadow-none", "border",
        "Sharp and minimal — monospace-friendly, zero fluff",
    ),
    :nature => SuiteTheme(
        :nature, :auto,
        "emerald", "amber", "stone",
        "rounded-xl", "rounded-lg",
        "emerald-500", "font-medium", "shadow-sm", "border",
        "Organic earthy tones — green and stone, generous curves",
    ),
    :islands => SuiteTheme(
        :islands, :auto,
        "accent", "accent-secondary", "warm",
        "rounded-xl", "rounded-lg",
        "accent-600", "font-medium", "shadow-md", "border",
        "Islands — floating glass panels, blue-gray canvas, warm accents",
    ),
)

"""
    get_theme(name::Symbol) -> SuiteTheme

Look up a theme by name. Returns :default if not found.
"""
function get_theme(name::Symbol)
    get(SUITE_THEMES, name, SUITE_THEMES[:default])
end

"""
    resolve_theme(name::Symbol; kwargs...) -> SuiteTheme

Resolve a theme by name with optional fine-grained overrides.
Override kwargs match SuiteTheme field names.
"""
function resolve_theme(name::Symbol;
        accent=nothing, accent_secondary=nothing, neutral=nothing,
        radius=nothing, radius_sm=nothing, ring=nothing,
        font_weight=nothing, shadow=nothing, border_width=nothing,
        kwargs...)
    base = get_theme(name)

    # No overrides → return base directly
    if all(isnothing, (accent, accent_secondary, neutral, radius, radius_sm, ring, font_weight, shadow, border_width))
        return base
    end

    SuiteTheme(
        base.name, base.color_scheme,
        something(accent, base.accent),
        something(accent_secondary, base.accent_secondary),
        something(neutral, base.neutral),
        something(radius, base.radius),
        something(radius_sm, base.radius_sm),
        something(ring, base.ring),
        something(font_weight, base.font_weight),
        something(shadow, base.shadow),
        something(border_width, base.border_width),
        base.description,
    )
end

"""
    apply_theme(classes::String, t::SuiteTheme) -> String

Apply theme token substitutions to a class string.
Default theme is a no-op. Order: accent-secondary before accent (longer prefix first).
"""
function apply_theme(classes::String, t::SuiteTheme)
    t.name === :default && return classes
    result = classes

    # 1. accent-secondary FIRST (longer prefix)
    if t.accent_secondary != "accent-secondary"
        result = replace(result, "accent-secondary-" => "$(t.accent_secondary)-")
    end

    # 2. accent SECOND
    if t.accent != "accent"
        result = replace(result, "accent-" => "$(t.accent)-")
    end

    # 3. neutral (warm → slate/stone)
    if t.neutral != "warm"
        result = replace(result, "warm-" => "$(t.neutral)-")
    end

    # 4. Radius
    if t.radius != "rounded-md"
        result = replace(result, "rounded-md" => t.radius)
    end
    if t.radius_sm != "rounded-sm"
        result = replace(result, "rounded-sm" => t.radius_sm)
    end

    # 5. Shadow
    if t.shadow != "shadow-sm"
        result = replace(result, "shadow-sm" => t.shadow)
    end

    return result
end

"""
    apply_theme_to_source(source::String, t::SuiteTheme) -> String

Apply theme substitutions to an entire source file for extraction.
Same substitutions as apply_theme() but on full file content.
"""
apply_theme_to_source(source::String, t::SuiteTheme) = apply_theme(source, t)
