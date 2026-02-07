# Footer.jl — Suite.jl Footer Component
#
# Tier: pure_styling
# Suite Dependencies: Separator
# JS Modules: none
#
# Usage via package: using Suite; SiteFooter(...)
# Usage via extract: include("components/Footer.jl"); SiteFooter(...)
#
# A semantic footer component with brand, links, and tagline sections.

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SiteFooter, FooterBrand, FooterLinks, FooterLink, FooterTagline

"""
    SiteFooter(children...; class, kwargs...) -> VNode

A site footer with branding, links, and tagline. Uses semantic `<footer>` element.

Named `SiteFooter` to avoid collision with Therapy.jl's `Footer` HTML element.

# Examples
```julia
SiteFooter(
    FooterBrand("GroupTherapyOrg"),
    FooterLinks(
        FooterLink("Therapy.jl", href="https://github.com/GroupTherapyOrg/Therapy.jl"),
        FooterLink("Suite.jl", href="https://github.com/GroupTherapyOrg/Suite.jl"),
    ),
    FooterTagline("Built with Therapy.jl — A reactive web framework for Julia"),
)
```
"""
function SiteFooter(children...; class::String="", kwargs...)
    classes = cn(
        "bg-warm-100 dark:bg-warm-900 mt-auto transition-colors duration-200",
        class
    )

    Footer(:class => classes, kwargs...,
        Div(:class => "max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8",
            Div(:class => "flex flex-col sm:flex-row items-center justify-between gap-4",
                children...
            )
        )
    )
end

"""
    FooterBrand(children...; class, kwargs...) -> VNode

Brand section of the footer. Typically contains the organization name.
"""
function FooterBrand(children...; class::String="", kwargs...)
    Div(:class => cn("flex items-center gap-4", class), kwargs...,
        children...
    )
end

"""
    FooterLinks(children...; class, kwargs...) -> VNode

Container for footer link items. Renders links with separators.
"""
function FooterLinks(children...; class::String="", kwargs...)
    # Interleave links with separator spans
    result = Any[]
    for (i, child) in enumerate(children)
        if i > 1
            push!(result, Span(:class => "text-warm-300 dark:text-warm-600", "/"))
        end
        push!(result, child)
    end
    Div(:class => cn("flex items-center gap-4", class), kwargs...,
        result...
    )
end

"""
    FooterLink(children...; href, class, kwargs...) -> VNode

A single link in the footer.
"""
function FooterLink(children...; href::String="#", class::String="", kwargs...)
    A(:href => href,
      :class => cn("text-sm text-warm-600 dark:text-warm-400 hover:text-accent-600 dark:hover:text-accent-400 transition-colors", class),
      :target => "_blank",
      kwargs...,
      children...)
end

"""
    FooterTagline(children...; class, kwargs...) -> VNode

A tagline or description text for the footer.
"""
function FooterTagline(children...; class::String="", kwargs...)
    P(:class => cn("text-warm-500 dark:text-warm-500 text-xs", class),
      kwargs...,
      children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :SiteFooter,
        "Footer.jl",
        :pure_styling,
        "Site footer with brand, links, and tagline sections",
        Symbol[],
        Symbol[],
        [:SiteFooter, :FooterBrand, :FooterLinks, :FooterLink, :FooterTagline],
    ))
end
