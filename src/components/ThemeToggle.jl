# SuiteThemeToggle.jl — Suite.jl Theme Toggle Component
#
# Tier: js_runtime (requires suite.js for dark class toggle + localStorage)
# Suite Dependencies: none (leaf component)
# JS Modules: ThemeToggle
#
# Usage via package: using Suite; SuiteThemeToggle()
# Usage via extract: include("components/ThemeToggle.jl"); SuiteThemeToggle()
#
# Behavior:
#   - Renders a button with sun/moon SVG icon
#   - JS discovers via data-suite-theme-toggle attribute
#   - Toggles `dark` class on <html> element
#   - Persists preference to localStorage('therapy-theme')
#   - Respects system prefers-color-scheme as default

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteThemeToggle

"""
    SuiteThemeToggle(; class, kwargs...) -> VNode

A theme toggle button that switches between light and dark mode.

Requires `suite_script()` in your layout for JS behavior.
Also include `suite_theme_script()` in `<head>` to prevent flash of wrong theme.

# Examples
```julia
# In layout <head> (prevents FOUC):
suite_theme_script()

# In navbar:
SuiteThemeToggle()

# With custom class:
SuiteThemeToggle(class="ml-2")
```
"""
function SuiteThemeToggle(; theme::Symbol=:default, class::String="", kwargs...)
    classes = cn("inline-flex items-center justify-center rounded-md p-2 hover:bg-warm-200 dark:hover:bg-warm-800 transition-colors cursor-pointer", class)
    sun_classes = "hidden dark:block w-5 h-5 text-warm-300"
    moon_classes = "block dark:hidden w-5 h-5 text-warm-600"
    if theme !== :default
        t = get_theme(theme)
        classes = apply_theme(classes, t)
        sun_classes = apply_theme(sun_classes, t)
        moon_classes = apply_theme(moon_classes, t)
    end
    Button(:type => "button",
           :class => classes,
           Symbol("data-suite-theme-toggle") => "",
           :aria_label => "Toggle dark mode",
           :title => "Toggle dark mode",
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
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :ThemeToggle,
        "ThemeToggle.jl",
        :js_runtime,
        "Dark/light mode toggle button",
        Symbol[],
        [:ThemeToggle],
        [:SuiteThemeToggle],
    ))
end
