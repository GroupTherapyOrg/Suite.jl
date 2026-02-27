# Carousel.jl — Suite.jl Carousel Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none
# JS Modules: none
#
# Usage via package: using Suite; Carousel(CarouselContent(CarouselItem("Slide 1"), ...))
# Usage via extract: include("components/Carousel.jl"); Carousel(...)
#
# Scrollable content slider with snap points, previous/next buttons,
# dot indicators, and keyboard navigation.
# Signal-driven: BindModal(mode=20) handles all interaction via Wasm
#
# Reference: shadcn/ui Carousel (Embla Carousel) — simplified to CSS scroll-snap

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- SVG Icons ---
const _CAROUSEL_PREV_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>"""
const _CAROUSEL_NEXT_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>"""

# --- Component Implementation ---

export Carousel, CarouselContent, CarouselItem, CarouselPrevious, CarouselNext

#   Carousel(children...; orientation, loop, autoplay, autoplay_interval, class, kwargs...) -> VNode
#
# A scrollable content slider with snap-point navigation.
# Options: orientation ("horizontal"/"vertical"), loop (Bool), autoplay (Bool), autoplay_interval (Int ms)
# Examples: Carousel(CarouselContent(CarouselItem("1"), ...), CarouselPrevious(), CarouselNext())
@island function Carousel(children...; orientation::String="horizontal",
                  loop::Bool=false, autoplay::Bool=false,
                  autoplay_interval::Int=4000,
                  class::String="", theme::Symbol=:default, kwargs...)
    is_active, set_active = create_signal(Int32(1))

    classes = cn("relative group", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(:class => classes,
        Symbol("data-modal") => BindModal(is_active, Int32(20)),
        Symbol("data-carousel-orientation") => orientation,
        Symbol("data-carousel-loop") => string(loop),
        Symbol("data-carousel-autoplay") => string(autoplay),
        Symbol("data-carousel-autoplay-interval") => string(autoplay_interval),
        :role => "region",
        Symbol("aria-roledescription") => "carousel",
        Symbol("aria-label") => "Carousel",
        kwargs...,
        children...,
    )
end

"""
    CarouselContent(children...; class, kwargs...) -> VNode

Container for carousel slides. Wraps CarouselItem elements.
"""
function CarouselContent(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("flex overflow-hidden scroll-smooth snap-x snap-mandatory", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(:class => "overflow-hidden",
        :data_carousel_viewport => "true",
        Div(:class => classes,
            :data_carousel_content => "true",
            kwargs...,
            children...,
        )
    )
end

"""
    CarouselItem(children...; class, kwargs...) -> VNode

A single slide within the carousel.
"""
function CarouselItem(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("min-w-0 shrink-0 grow-0 basis-full snap-start pl-4 first:pl-0", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(:class => classes,
        :role => "group",
        Symbol("aria-roledescription") => "slide",
        :data_carousel_item => "true",
        kwargs...,
        children...,
    )
end

"""
    CarouselPrevious(; class, kwargs...) -> VNode

Previous slide navigation button.
"""
function CarouselPrevious(; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn(
        "absolute left-2 top-1/2 -translate-y-1/2 z-10",
        "inline-flex items-center justify-center cursor-pointer",
        "h-8 w-8 rounded-full",
        "border border-warm-200 dark:border-warm-700",
        "bg-warm-50/90 dark:bg-warm-900/90 backdrop-blur-sm",
        "text-warm-700 dark:text-warm-300",
        "hover:bg-warm-100 dark:hover:bg-warm-800",
        "disabled:opacity-50 disabled:pointer-events-none",
        "transition-colors",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Therapy.Button(:class => classes,
        :data_carousel_prev => "true",
        Symbol("aria-label") => "Previous slide",
        kwargs...,
        RawHtml(_CAROUSEL_PREV_SVG),
    )
end

"""
    CarouselNext(; class, kwargs...) -> VNode

Next slide navigation button.
"""
function CarouselNext(; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn(
        "absolute right-2 top-1/2 -translate-y-1/2 z-10",
        "inline-flex items-center justify-center cursor-pointer",
        "h-8 w-8 rounded-full",
        "border border-warm-200 dark:border-warm-700",
        "bg-warm-50/90 dark:bg-warm-900/90 backdrop-blur-sm",
        "text-warm-700 dark:text-warm-300",
        "hover:bg-warm-100 dark:hover:bg-warm-800",
        "disabled:opacity-50 disabled:pointer-events-none",
        "transition-colors",
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Therapy.Button(:class => classes,
        :data_carousel_next => "true",
        Symbol("aria-label") => "Next slide",
        kwargs...,
        RawHtml(_CAROUSEL_NEXT_SVG),
    )
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Carousel,
        "Carousel.jl",
        :island,
        "Scrollable content slider with snap navigation",
        Symbol[],
        [:Carousel],
        [:Carousel, :CarouselContent, :CarouselItem, :CarouselPrevious, :CarouselNext],
    ))
end
