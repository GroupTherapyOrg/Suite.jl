# SiteNav.jl — Suite.jl Site Navigation Component
#
# Tier: composite (combines Sheet, ThemeToggle, ThemeSwitcher, Separator)
# Suite Dependencies: Sheet, ThemeToggle, ThemeSwitcher, Separator
# JS Modules: none (delegates to Sheet's JS)
#
# Shared navbar pattern for all GroupTherapyOrg doc sites.
# Renders NavLink (from Therapy.jl) for SPA-aware active state highlighting.
#
# Usage:
#   Suite.SiteNav(
#       brand_element,
#       [(href="./", label="Home", exact=true), (href="./features/", label="Features")],
#       "https://github.com/GroupTherapyOrg/WasmTarget.jl";
#       mobile_title="WasmTarget.jl",
#       mobile_sections=[(title="Explore", links=[(href="./features/", label="Features")])]
#   )

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SiteNav

# Shared SVG icons
const _SITENAV_GITHUB_SVG = Svg(:class => "h-5 w-5", :fill => "currentColor", :viewBox => "0 0 24 24",
    Path(:d => "M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z")
)

const _SITENAV_HAMBURGER_SVG = Svg(:class => "h-5 w-5", :fill => "none", :viewBox => "0 0 24 24",
    :stroke => "currentColor", :stroke_width => "2",
    Path(:stroke_linecap => "round", :stroke_linejoin => "round",
         :d => "M4 6h16M4 12h16M4 18h16")
)

# CSS class constants
const _SITENAV_LINK_CLASS = "text-sm font-medium text-warm-600 dark:text-warm-400 hover:text-accent-600 dark:hover:text-accent-400 transition-colors"
const _SITENAV_LINK_ACTIVE = "text-accent-700 dark:text-accent-400"
const _SITENAV_MOBILE_LINK_CLASS = "text-sm text-warm-700 dark:text-warm-300 hover:text-accent-600 dark:hover:text-accent-400 py-1.5 px-2 rounded-md hover:bg-warm-100 dark:hover:bg-warm-800 transition-colors"
const _SITENAV_GITHUB_CLASS = "text-warm-600 hover:text-warm-800 dark:text-warm-400 dark:hover:text-warm-200 transition-colors"
const _SITENAV_SECTION_CLASS = "text-xs font-semibold text-warm-500 dark:text-warm-500 uppercase tracking-wider"

"""
    SiteNav(brand, links, github_url; mobile_title, mobile_sections, class, kwargs...) -> VNode

Shared site navigation bar for GroupTherapyOrg doc sites.

Renders a responsive navbar with:
- Desktop: horizontal NavLink list + GitHub icon + ThemeSwitcher + ThemeToggle
- Mobile: hamburger Sheet with optional grouped sections

# Arguments
- `brand`: HTML element for the logo/wordmark (rendered as-is)
- `links`: Vector of NamedTuples for desktop nav links.
  Each tuple: `(href="./path/", label="Label")` with optional `exact=true`.
- `github_url`: String URL for the GitHub icon link

# Keyword Arguments
- `mobile_title`: String for Sheet title (default: "Navigation")
- `mobile_sections`: Optional Vector of NamedTuples for mobile nav sections.
  Each tuple: `(title="Section", links=[(href="./path/", label="Label"), ...])`.
  If not provided, desktop `links` are used as a flat list in mobile.
- `class`: Additional CSS classes for the header element

# Example
```julia
Suite.SiteNav(
    MyLogo(),
    [
        (href="./", label="Home", exact=true),
        (href="./features/", label="Features"),
        (href="./api/", label="API", exact=true),
    ],
    "https://github.com/GroupTherapyOrg/MyPackage.jl";
    mobile_title="MyPackage.jl",
    mobile_sections=[
        (title="Explore", links=[
            (href="./features/", label="Features"),
            (href="./api/", label="API Reference"),
        ]),
    ]
)
```
"""
function SiteNav(brand, links::Vector, github_url::String;
                 mobile_title::String="Navigation",
                 mobile_sections=nothing,
                 class::String="",
                 kwargs...)

    desktop = _sitenav_desktop(brand, links, github_url)
    mobile = _sitenav_mobile(links, github_url, mobile_title, mobile_sections)

    Header(:class => cn("bg-warm-100 dark:bg-warm-900 border-b border-warm-200 dark:border-warm-700 transition-colors duration-200", class), kwargs...,
        Div(:class => "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8",
            Div(:class => "flex items-center justify-between h-16",
                # Logo
                Div(:class => "flex items-center",
                    brand,
                ),
                # Desktop: Nav + utilities
                Div(:class => "hidden md:flex md:items-center md:gap-2",
                    desktop,
                    Div(:class => "flex items-center gap-2 ml-4",
                        A(:href => github_url,
                          :class => _SITENAV_GITHUB_CLASS,
                          :target => "_blank",
                          _SITENAV_GITHUB_SVG
                        ),
                        ThemeSwitcher(),
                        ThemeToggle(),
                    ),
                ),
                # Mobile: Hamburger Sheet
                Div(:class => "flex items-center md:hidden",
                    mobile,
                ),
            )
        )
    )
end

# --- Internal helpers ---

function _sitenav_desktop(brand, links::Vector, github_url::String)
    navlinks = map(links) do link
        exact = get(link, :exact, false)
        Therapy.NavLink(link.href, link.label,
            class=_SITENAV_LINK_CLASS,
            active_class=_SITENAV_LINK_ACTIVE,
            exact=exact)
    end
    Nav(:class => "flex items-center gap-6", navlinks...)
end

function _sitenav_mobile(links::Vector, github_url::String, title::String, sections)
    # Build mobile link list
    mobile_content = if sections !== nothing
        _sitenav_mobile_sections(sections)
    else
        # Flat list from desktop links
        map(links) do link
            A(:href => link.href,
              :class => _SITENAV_MOBILE_LINK_CLASS,
              link.label)
        end
    end

    Sheet(
        SheetTrigger(
            :class => "text-warm-600 dark:text-warm-400 hover:text-warm-800 dark:hover:text-warm-200",
            :aria_label => "Open menu",
            _SITENAV_HAMBURGER_SVG
        ),
        SheetContent(side="left",
            SheetHeader(
                SheetTitle(title),
                SheetDescription("Navigation"),
            ),
            Nav(:class => "flex flex-col gap-2 mt-4",
                # Home link (always first)
                A(:href => "./",
                  :class => _SITENAV_MOBILE_LINK_CLASS,
                  "Home"),
                mobile_content...,
                # Separator + utilities
                Separator(class="my-4"),
                Div(:class => "flex items-center gap-4",
                    A(:href => github_url,
                      :class => _SITENAV_GITHUB_CLASS,
                      :target => "_blank",
                      _SITENAV_GITHUB_SVG
                    ),
                    ThemeSwitcher(),
                    ThemeToggle(),
                ),
            ),
        ),
    )
end

function _sitenav_mobile_sections(sections)
    result = Any[]
    for section in sections
        # Section header
        push!(result, Div(:class => "mt-2",
            Span(:class => _SITENAV_SECTION_CLASS, section.title)
        ))
        # Section links
        for link in section.links
            push!(result, A(:href => link.href,
                :class => _SITENAV_MOBILE_LINK_CLASS,
                link.label))
        end
    end
    result
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :SiteNav,
        "SiteNav.jl",
        :composite,
        "Shared site navigation bar for doc sites",
        [:Sheet, :ThemeToggle, :ThemeSwitcher, :Separator],
        Symbol[],
        [:SiteNav],
    ))
end
