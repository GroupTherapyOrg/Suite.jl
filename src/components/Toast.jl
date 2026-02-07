# Toaster.jl — Suite.jl Toast Notification Component (Sonner-style)
#
# Tier: js_runtime (requires suite.js for toast queue, auto-dismiss, stacking, swipe)
# Suite Dependencies: none (leaf component)
# JS Modules: Toast
#
# Usage via package: using Suite; Toaster()
# Usage via extract: include("components/Toast.jl"); Toaster()
#
# Architecture:
#   - Toaster() renders an invisible container (placed once in layout)
#   - Toasts are triggered from client JS: Suite.toast("Hello")
#   - JS manages queue, stacking, auto-dismiss timers, swipe-to-dismiss
#   - Variants: default, success, error, warning, info
#   - Positions: top-left, top-center, top-right, bottom-left, bottom-center, bottom-right
#
# Client-side API (in browser JS):
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

"""
    Toaster(; position, duration, visible_toasts, class, kwargs...) -> VNode

A toast notification container. Place once in your layout (typically at the end of `<body>`).

Toasts are triggered from client-side JavaScript via `Suite.toast()`.

# Arguments
- `position::String="bottom-right"`: Where toasts appear. Options: "top-left", "top-center",
  "top-right", "bottom-left", "bottom-center", "bottom-right"
- `duration::Int=4000`: Default auto-dismiss duration in milliseconds. Use `Inf` for persistent.
- `visible_toasts::Int=3`: Maximum visible toasts in the stack.
- `class::String=""`: Additional CSS classes.
- `theme::Symbol=:default`: Theme preset.

# Examples
```julia
# In your Layout (place once):
function Layout(children...)
    Div(
        Nav(...),
        Main(children...),
        Footer(...),
        Toaster(),           # Default: bottom-right, 4s duration
        suite_script()
    )
end

# With custom position:
Toaster(position="top-center", duration=5000)
```

# Client-side API (JavaScript)
```javascript
// Show toasts from browser JS:
Suite.toast("File saved")
Suite.toast.success("Upload complete")
Suite.toast.error("Connection lost", { description: "Please try again" })
Suite.toast.warning("Low disk space")
Suite.toast.info("New version available", {
    action: { label: "Update", onClick: () => location.reload() }
})

// Dismiss:
const id = Suite.toast("Processing...")
Suite.toast.dismiss(id)
Suite.toast.dismissAll()
```
"""
function Toaster(;
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
        Symbol("data-suite-toaster") => "",
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
        :js_runtime,
        "Sonner-style toast notification system",
        Symbol[],
        [:Toast],
        [:Toaster],
    ))
end
