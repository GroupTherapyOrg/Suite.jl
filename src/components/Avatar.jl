# Avatar.jl — Suite.jl Avatar Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Avatar(AvatarImage(src="/avatar.jpg", alt="User"))
# Usage via extract: include("components/Avatar.jl"); Avatar(...)
#
# Reference: shadcn/ui Avatar — https://ui.shadcn.com/docs/components/avatar

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Avatar, AvatarImage, AvatarFallback

"""
    Avatar(children...; size, class, kwargs...) -> VNode

A circular avatar container for user images with fallback.
Equivalent to shadcn/ui's Avatar component.

# Sizes
- `"default"`: 2rem (size-8)
- `"sm"`: 1.5rem (size-6)
- `"lg"`: 2.5rem (size-10)

# Examples
```julia
Avatar(
    AvatarImage(src="/avatar.jpg", alt="User"),
    AvatarFallback("JD"),
)
Avatar(size="lg",
    AvatarFallback("AB"),
)
```
"""
function Avatar(children...; size::String="default", class::String="", kwargs...)
    size_classes = Dict(
        "default" => "size-8",
        "sm"      => "size-6",
        "lg"      => "size-10",
    )

    sc = get(size_classes, size, size_classes["default"])
    classes = cn("relative flex shrink-0 overflow-hidden rounded-full select-none", sc, class)

    Span(:class => classes, kwargs..., children...)
end

"""
    AvatarImage(; src, alt, class, kwargs...) -> VNode

Image displayed inside a Avatar.
"""
function AvatarImage(; src::String="", alt::String="", class::String="", kwargs...)
    classes = cn("aspect-square size-full", class)
    Img(:src => src, :alt => alt, :class => classes, kwargs...)
end

"""
    AvatarFallback(children...; class, kwargs...) -> VNode

Fallback content (initials/icon) shown when avatar image is unavailable.
"""
function AvatarFallback(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn(
        "flex size-full items-center justify-center rounded-full text-sm",
        "bg-warm-100 dark:bg-warm-900 text-warm-600 dark:text-warm-500",
        class,
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    Span(:class => classes, kwargs..., children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Avatar,
        "Avatar.jl",
        :styling,
        "Circular avatar with image and fallback",
        Symbol[],
        Symbol[],
        [:Avatar, :AvatarImage, :AvatarFallback],
    ))
end
