# Carousel.jl — Suite.jl Carousel Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none
# JS Modules: none
#
# Usage via package: using Suite; Carousel(CarouselContent(CarouselItem("Slide 1"), ...))
# Usage via extract: include("components/Carousel.jl"); Carousel(...)
#
# Signal-driven slide navigation: prev/next buttons cycle through slides.
# Uses match_descendants binding: current slide gets data-state="open",
# others get data-state="closed" and are hidden via CSS.
#
# Reference: shadcn/ui Carousel — simplified to show/hide with Wasm signals

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- SVG Icons ---
const _CAROUSEL_PREV_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>"""
const _CAROUSEL_NEXT_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>"""

# --- Component Implementation ---

export Carousel, CarouselContent, CarouselItem, CarouselPrevious, CarouselNext

# SSR helper: walk Carousel children, inject data-index + initial data-state.
# Returns slide count. Slides get 0..N-1, prev button gets 100, next button gets 101.
function _carousel_ssr_setup!(children)
    slide_idx = 0
    for child in children
        child isa VNode || continue
        # CarouselContent viewport wrapper -> content container -> items
        if haskey(child.props, :data_carousel_viewport)
            for content_wrapper in child.children
                content_wrapper isa VNode || continue
                if haskey(content_wrapper.props, :data_carousel_content)
                    for item in content_wrapper.children
                        item isa VNode || continue
                        if haskey(item.props, :data_carousel_item)
                            item.props[Symbol("data-index")] = string(slide_idx)
                            item.props[Symbol("data-state")] = slide_idx == 0 ? "open" : "closed"
                            slide_idx += 1
                        end
                    end
                end
            end
        end
        # Nav buttons
        if haskey(child.props, :data_carousel_prev)
            child.props[Symbol("data-index")] = "100"
            child.props[Symbol("data-state")] = "closed"
        end
        if haskey(child.props, :data_carousel_next)
            child.props[Symbol("data-index")] = "101"
            child.props[Symbol("data-state")] = "closed"
        end
    end
    return slide_idx
end

#   Carousel(children...; loop, class, kwargs...) -> IslandVNode
#
# A slide-based content viewer with prev/next navigation.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# Uses a single signal for current slide index (0-based).
# The v2 pipeline compiles this to a Wasm module with 1 signal and 1 handler.
# DOM bindings are auto-registered on all [data-index] descendants.
#
# Props:
#   loop: whether navigation wraps around (Bool, default false)
#
# Examples:
#   Carousel(CarouselContent(CarouselItem("1"), CarouselItem("2")), CarouselPrevious(), CarouselNext())
#   Carousel(loop=true, CarouselContent(CarouselItem("1"), ...), CarouselPrevious(), CarouselNext())
@island function Carousel(children...; loop::Bool=false,
                          class::String="", theme::Symbol=:default, kwargs...)
    # Compilable: 1 signal for current slide index (starts at 0)
    active, set_active = create_signal(Int32(0))

    # Compilable: match bindings (data-state = open when signal == data-index)
    compiled_register_match_descendants(Int32(1), Int32(0))

    # SSR-only: walk children, inject data-index + initial data-state
    _carousel_ssr_setup!(children)

    classes = cn("relative group", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(:class => classes,
        Symbol("data-carousel") => "",
        :role => "region",
        Symbol("aria-roledescription") => "carousel",
        Symbol("aria-label") => "Carousel",
        :on_click => () -> begin
            idx = compiled_get_event_data_index()
            if idx == Int32(100)
                # Prev button
                current = active()
                new_idx = current - Int32(1)
                l = compiled_get_prop_i32(Int32(0))  # _l = loop flag
                n = compiled_get_prop_i32(Int32(1))  # _n = slide count
                # NOTE: Avoid if-else — WasmTarget.jl codegen places else branch
                # outside the if block (no wasm else opcode emitted). Use two
                # independent if blocks with opposite conditions instead.
                if new_idx < Int32(0)
                    if l == Int32(1)
                        set_active(n - Int32(1))
                    end
                end
                if new_idx >= Int32(0)
                    set_active(new_idx)
                end
            end
            if idx == Int32(101)
                # Next button
                current = active()
                new_idx = current + Int32(1)
                l = compiled_get_prop_i32(Int32(0))
                n = compiled_get_prop_i32(Int32(1))
                if new_idx >= n
                    if l == Int32(1)
                        set_active(Int32(0))
                    end
                end
                if new_idx < n
                    set_active(new_idx)
                end
            end
        end,
        kwargs..., children...)
end

"""
    CarouselContent(children...; class, kwargs...) -> VNode

Container for carousel slides. Wraps CarouselItem elements.
"""
function CarouselContent(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("flex overflow-hidden", class)
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
    classes = cn("min-w-0 shrink-0 grow-0 w-full data-[state=closed]:hidden", class)
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

# --- Hydration Support ---

const _CAROUSEL_PROPS_TRANSFORM = (props, args) -> begin
    # Count slides by walking CarouselContent -> viewport -> content -> items
    slide_count = 0
    for arg in args
        if arg isa Therapy.VNode && haskey(arg.props, :data_carousel_viewport)
            for content_wrapper in arg.children
                if content_wrapper isa Therapy.VNode && haskey(content_wrapper.props, :data_carousel_content)
                    for item in content_wrapper.children
                        if item isa Therapy.VNode && haskey(item.props, :data_carousel_item)
                            slide_count += 1
                        end
                    end
                end
            end
        end
    end

    loop_flag = get(props, :loop, false) ? 1 : 0

    props[:_l] = loop_flag
    props[:_n] = slide_count
end


# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Carousel,
        "Carousel.jl",
        :island,
        "Slide-based content viewer with prev/next navigation",
        Symbol[],
        Symbol[],
        [:Carousel, :CarouselContent, :CarouselItem, :CarouselPrevious, :CarouselNext],
    ))
end
