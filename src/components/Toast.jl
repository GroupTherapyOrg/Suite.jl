# Toaster.jl — Suite.jl Toast Notification Component (Sonner-style)
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Toaster()
# Usage via extract: include("components/Toast.jl"); Toaster()
#
# Architecture:
#   - Toaster() renders an invisible container (placed once in layout)
#   - Toasts are triggered from client JS: Suite.toast("Hello")
#   - Data-attribute driven: toaster behavior via data-toaster-* attributes
#   - Variants: default, success, error, warning, info
#   - Positions: top-left, top-center, top-right, bottom-left, bottom-center, bottom-right
#
# Client-side API (in browser JS — exposed by Therapy.jl hydration):
#   Suite.toast("Hello")                           — default toast
#   Suite.toast.success("Saved!")                   — success variant
#   Suite.toast.error("Failed", {description: "..."})  — error with description
#   Suite.toast.dismiss(id)                         — dismiss specific toast
#   Suite.toast.dismissAll()                        — dismiss all toasts

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Toaster

#   Toaster(; position, duration, visible_toasts, class, kwargs...) -> VNode
#
# A toast notification container. Place once in your layout.
# Toasts are triggered via Suite.toast() in the browser.
# Args: position ("bottom-right" etc.), duration (4000ms), visible_toasts (3)
# Client API: Suite.toast("msg"), Suite.toast.success("msg"), .error, .warning, .info
# Dismiss: Suite.toast.dismiss(id), Suite.toast.dismissAll()
@island function Toaster(;
    theme::Symbol=:default,
    position::String="bottom-right",
    duration::Int=4000,
    visible_toasts::Int=3,
    class::String="",
    kwargs...
)
    classes = cn("", class)
    if theme !== :default
        t = get_theme(theme)
        classes = apply_theme(classes, t)
    end
    Section(
        :aria_label => "Notifications",
        :tabindex => "-1",
        Symbol("data-toaster") => "",
        Symbol("data-position") => position,
        Symbol("data-duration") => string(duration),
        Symbol("data-visible-toasts") => string(visible_toasts),
        :class => classes,
        kwargs...
    )
end


# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Toast,
        "Toast.jl",
        :island,
        "Sonner-style toast notification system",
        Symbol[],
        [:Toast],
        [:Toaster],
    ))
end
