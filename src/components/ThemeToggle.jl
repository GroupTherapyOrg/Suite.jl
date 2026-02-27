# ThemeToggle.jl — Suite.jl Theme Toggle Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; ThemeToggle()
# Usage via extract: include("components/ThemeToggle.jl"); ThemeToggle()
#
# Behavior:
#   - Renders a button with sun/moon SVG icon
#   - Signal-driven: create_signal(Int32) tracks dark/light state
#   - :dark_mode binding calls set_dark_mode import to toggle <html> dark class
#   - Persists preference to localStorage('therapy-theme') via set_dark_mode JS import
#   - Hydration syncs signal to actual theme state (localStorage or system preference)
#   - Include `suite_theme_script()` in <head> to prevent FOUC

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export ThemeToggle

#   ThemeToggle(; theme, class, kwargs...) -> IslandVNode
#
# A theme toggle button that switches between light and dark mode.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# Include `suite_theme_script()` in <head> to prevent flash of wrong theme.
# The :dark_mode binding auto-syncs the Wasm signal with actual theme state
# at hydration time, so the initial signal value (0) is just a placeholder.
#
# Examples: ThemeToggle(), ThemeToggle(class="ml-2")
@island function ThemeToggle(; theme::Symbol=:default, class::String="", kwargs...)
    # Signal for dark mode state (Int32: 0=light, 1=dark)
    # Initial value 0 is overridden at hydration by generate_theme_init()
    dark, set_dark = create_signal(Int32(0))

    classes = cn("inline-flex items-center justify-center rounded-md p-2 hover:bg-warm-200 dark:hover:bg-warm-800 transition-colors cursor-pointer", class)
    sun_classes = "hidden dark:block w-5 h-5 text-warm-300"
    moon_classes = "block dark:hidden w-5 h-5 text-warm-600"
    if theme !== :default
        t = get_theme(theme)
        classes = apply_theme(classes, t)
        sun_classes = apply_theme(sun_classes, t)
        moon_classes = apply_theme(moon_classes, t)
    end

    # :dark_mode prop triggers AnalyzedThemeBinding → set_dark_mode(value) on signal change
    Div(:dark_mode => dark,
        Therapy.Button(:type => "button",
            :class => classes,
            :aria_label => "Toggle dark mode",
            :title => "Toggle dark mode",
            :on_click => () -> set_dark(Int32(1) - dark()),
            kwargs...,
            # Sun icon (visible in dark mode)
            Svg(:class => sun_classes,
                :fill => "none", :viewBox => "0 0 24 24", :stroke => "currentColor", :stroke_width => "2",
                Path(:stroke_linecap => "round", :stroke_linejoin => "round",
                     :d => "M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z")
            ),
            # Moon icon (visible in light mode)
            Svg(:class => moon_classes,
                :fill => "none", :viewBox => "0 0 24 24", :stroke => "currentColor", :stroke_width => "2",
                Path(:stroke_linecap => "round", :stroke_linejoin => "round",
                     :d => "M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z")
            ),
        )
    )
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :ThemeToggle,
        "ThemeToggle.jl",
        :island,
        "Dark/light mode toggle button",
        Symbol[],
        Symbol[],
        [:ThemeToggle],
    ))
end
