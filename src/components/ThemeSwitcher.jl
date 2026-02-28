# ThemeSwitcher.jl — Suite.jl Theme Switcher Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; ThemeSwitcher()
# Usage via extract: include("components/ThemeSwitcher.jl"); ThemeSwitcher()
#
# Behavior:
#   - Renders a button with a palette icon
#   - Clicking opens a dropdown with 5 theme options
#   - Each option shows name, description, and color swatch
#   - Selecting a theme sets data-theme on <html> + persists to localStorage
#   - Signal-driven: BindModal(mode=23) handles all interaction via Wasm

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export ThemeSwitcher

# Theme metadata for the switcher UI
const _THEME_OPTIONS = [
    (name="Default", key="default", description="Purple — warm scholarly tones", swatch="#9558b2"),
    (name="Ocean", key="ocean", description="Blue — professional and confident", swatch="#2563eb"),
    (name="Minimal", key="minimal", description="Zinc — sharp and clean", swatch="#71717a"),
    (name="Nature", key="nature", description="Emerald — organic and earthy", swatch="#059669"),
    (name="Islands", key="islands", description="Glass panels — floating, blue-gray, modern", swatch="#548af7"),
]

#   ThemeSwitcher(; themes, class, kwargs...) -> VNode
#
# A theme switcher dropdown that lets users preview all 5 Suite.jl themes.
# Sets data-theme on <html> and persists to localStorage('suite-active-theme').
# Also requires theme CSS overrides in input.css for non-default themes.
# Examples: ThemeSwitcher(), ThemeSwitcher(class="ml-2")
@island function ThemeSwitcher(; themes=_THEME_OPTIONS, class::String="", kwargs...)
    is_active, set_active = create_signal(Int32(1))

    trigger_classes = cn("inline-flex items-center justify-center rounded-md p-2 hover:bg-warm-200 dark:hover:bg-warm-800 transition-colors cursor-pointer relative", class)

    Div(:class => "relative",
        Symbol("data-modal") => BindModal(is_active, Int32(23)),
        Symbol("data-theme-switcher") => "",
        kwargs...,
        # Trigger button — palette icon
        Therapy.Button(:type => "button",
            :class => trigger_classes,
            Symbol("data-theme-switcher-trigger") => "",
            :aria_label => "Switch theme",
            :aria_haspopup => "true",
            :aria_expanded => "false",
            :title => "Switch theme",
            # Palette/Paintbrush SVG icon
            Svg(:class => "w-5 h-5 text-warm-600 dark:text-warm-400",
                :fill => "none", :viewBox => "0 0 24 24", :stroke => "currentColor", :stroke_width => "2",
                Path(:stroke_linecap => "round", :stroke_linejoin => "round",
                     :d => "M4.098 19.902a3.75 3.75 0 005.304 0l6.401-6.402M6.75 21A3.75 3.75 0 013 17.25V4.125C3 3.504 3.504 3 4.125 3h5.25c.621 0 1.125.504 1.125 1.125v4.072M6.75 21a3.75 3.75 0 003.75-3.75V8.197M6.75 21h13.125c.621 0 1.125-.504 1.125-1.125v-5.25c0-.621-.504-1.125-1.125-1.125h-4.072M10.5 8.197l2.88-2.88c.438-.439 1.15-.439 1.59 0l3.712 3.713c.44.44.44 1.152 0 1.59l-2.879 2.88M6.75 17.25h.008v.008H6.75v-.008z")
            ),
        ),
        # Dropdown panel (hidden by default, positioned below trigger)
        Div(:class => "hidden absolute right-0 top-full mt-2 z-50 w-56 rounded-md border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-900 shadow-lg",
            Symbol("data-theme-switcher-content") => "",
            :role => "menu",
            :aria_label => "Theme options",
            Div(:class => "p-1",
                [_ThemeOption(opt) for opt in themes]...
            ),
        ),
    )
end

function _ThemeOption(opt)
    Therapy.Button(:type => "button",
        :class => "flex items-center gap-3 w-full rounded-sm px-2 py-2 text-sm cursor-pointer hover:bg-warm-100 dark:hover:bg-warm-800 transition-colors text-left",
        Symbol("data-theme-option") => opt.key,
        :role => "menuitem",
        # Color swatch
        Span(:class => "w-4 h-4 rounded-full shrink-0 border border-warm-200 dark:border-warm-700",
            :style => "background-color: $(opt.swatch)",
        ),
        # Name + description
        Span(:class => "flex flex-col",
            Span(:class => "font-medium text-warm-800 dark:text-warm-300 text-sm leading-none", opt.name),
            Span(:class => "text-warm-500 dark:text-warm-500 text-xs mt-0.5", opt.description),
        ),
        # Check mark for active theme (hidden by default, shown via JS)
        Svg(:class => "w-4 h-4 ml-auto text-accent-600 dark:text-accent-400 hidden",
            Symbol("data-theme-check") => opt.key,
            :fill => "none", :viewBox => "0 0 24 24", :stroke => "currentColor", :stroke_width => "2",
            Path(:stroke_linecap => "round", :stroke_linejoin => "round",
                 :d => "M5 13l4 4L19 7")
        ),
    )
end


# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :ThemeSwitcher,
        "ThemeSwitcher.jl",
        :island,
        "Theme switcher dropdown for previewing Suite.jl themes",
        Symbol[],
        [:ThemeSwitcher],
        [:ThemeSwitcher],
    ))
end
