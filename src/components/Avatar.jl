# SuiteAvatar.jl — Suite.jl Avatar Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; SuiteAvatar(SuiteAvatarImage(src="/avatar.jpg", alt="User"))
# Usage via extract: include("components/Avatar.jl"); SuiteAvatar(...)
#
# Reference: shadcn/ui Avatar — https://ui.shadcn.com/docs/components/avatar

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteAvatar, SuiteAvatarImage, SuiteAvatarFallback

"""
    SuiteAvatar(children...; size, class, kwargs...) -> VNode

A circular avatar container for user images with fallback.
Equivalent to shadcn/ui's Avatar component.

# Sizes
- `"default"`: 2rem (size-8)
- `"sm"`: 1.5rem (size-6)
- `"lg"`: 2.5rem (size-10)

# Examples
```julia
SuiteAvatar(
    SuiteAvatarImage(src="/avatar.jpg", alt="User"),
    SuiteAvatarFallback("JD"),
)
SuiteAvatar(size="lg",
    SuiteAvatarFallback("AB"),
)
```
"""
function SuiteAvatar(children...; size::String="default", class::String="", kwargs...)
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
    SuiteAvatarImage(; src, alt, class, kwargs...) -> VNode

Image displayed inside a SuiteAvatar.
"""
function SuiteAvatarImage(; src::String="", alt::String="", class::String="", kwargs...)
    classes = cn("aspect-square size-full", class)
    Img(:src => src, :alt => alt, :class => classes, kwargs...)
end

"""
    SuiteAvatarFallback(children...; class, kwargs...) -> VNode

Fallback content (initials/icon) shown when avatar image is unavailable.
"""
function SuiteAvatarFallback(children...; class::String="", kwargs...)
    classes = cn(
        "flex size-full items-center justify-center rounded-full text-sm",
        "bg-warm-100 dark:bg-warm-900 text-warm-600 dark:text-warm-500",
        class,
    )
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
        [:SuiteAvatar, :SuiteAvatarImage, :SuiteAvatarFallback],
    ))
end
