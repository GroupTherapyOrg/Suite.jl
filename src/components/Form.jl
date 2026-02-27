# Form.jl — Suite.jl Form Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Form(...)
# Usage via extract: include("components/Form.jl"); Form(...)
#
# Behavior (matches shadcn/ui Form pattern):
#   - Per-field validation with error messages
#   - ARIA: aria-invalid, aria-describedby linking
#   - Label → Control → Description → Message ID linking
#   - Submit prevention when invalid
#   - Validation modes: onSubmit, onChange, onBlur
#   - Signal-driven: BindModal(mode=17) handles all validation via Wasm

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Form, FormField, FormItem, FormLabel,
       FormControl, FormDescription, FormMessage

# Counter for unique form field IDs
const _FORM_ID_COUNTER = Ref(0)

function _form_next_id()
    _FORM_ID_COUNTER[] += 1
    "suite-form-$(string(_FORM_ID_COUNTER[], base=16))"
end

#   Form(children...; action, method, validate_on, class, theme, kwargs...) -> IslandVNode
#
# A form container with client-side validation support.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# Props:
# - `action::String=""`: Form action URL
# - `method::String="post"`: Form method
# - `validate_on::String="submit"`: Validation mode — "submit", "change", or "blur"
# - `class::String=""`: Additional CSS classes
# - `theme::Symbol=:default`: Theme name
@island function Form(children...; action::String="", method::String="post",
                   validate_on::String="submit", class::String="",
                   theme::Symbol=:default, kwargs...)
    is_active, set_active = create_signal(Int32(1))

    id = "suite-form-" * string(rand(UInt32), base=16)
    form_classes = cn("space-y-6", class)
    theme !== :default && (form_classes = apply_theme(form_classes, get_theme(theme)))

    Therapy.Form(:class => form_classes,
         Symbol("data-modal") => BindModal(is_active, Int32(17)),
         :action => action,
         :method => method,
         Symbol("data-suite-form") => id,
         Symbol("data-suite-form-validate-on") => validate_on,
         :novalidate => "novalidate",
         kwargs...,
         children...)
end

"""
    FormField(children...; name, required, min_length, max_length, pattern, pattern_message, min, max, custom_message, kwargs...) -> VNode

A form field container that manages validation rules for a named field.
Wraps FormItem and its contents.

# Arguments
- `name::String`: Field name (required)
- `required::Bool=false`: Whether the field is required
- `required_message::String="This field is required"`: Custom required error message
- `min_length::Int=0`: Minimum length (0 = no minimum)
- `min_length_message::String=""`: Custom min length error message
- `max_length::Int=0`: Maximum length (0 = no maximum)
- `max_length_message::String=""`: Custom max length error message
- `pattern::String=""`: Regex pattern for validation
- `pattern_message::String=""`: Custom pattern error message
- `min::String=""`: Minimum value (for number inputs)
- `max::String=""`: Maximum value (for number inputs)
- `custom_message::String=""`: Default error message for any validation failure
"""
function FormField(children...; name::String,
                        required::Bool=false,
                        required_message::String="This field is required",
                        min_length::Int=0,
                        min_length_message::String="",
                        max_length::Int=0,
                        max_length_message::String="",
                        pattern::String="",
                        pattern_message::String="",
                        min::String="",
                        max::String="",
                        custom_message::String="",
                        theme::Symbol=:default,
                        kwargs...)
    field_id = _form_next_id()

    # Build validation attributes
    attrs = Pair{Symbol,String}[
        Symbol("data-suite-form-field") => name,
        Symbol("data-suite-form-field-id") => field_id,
    ]

    required && push!(attrs, Symbol("data-suite-form-required") => required_message)
    min_length > 0 && push!(attrs, Symbol("data-suite-form-min-length") => string(min_length))
    min_length > 0 && min_length_message != "" && push!(attrs, Symbol("data-suite-form-min-length-message") => min_length_message)
    max_length > 0 && push!(attrs, Symbol("data-suite-form-max-length") => string(max_length))
    max_length > 0 && max_length_message != "" && push!(attrs, Symbol("data-suite-form-max-length-message") => max_length_message)
    pattern != "" && push!(attrs, Symbol("data-suite-form-pattern") => pattern)
    pattern != "" && pattern_message != "" && push!(attrs, Symbol("data-suite-form-pattern-message") => pattern_message)
    min != "" && push!(attrs, Symbol("data-suite-form-min") => min)
    max != "" && push!(attrs, Symbol("data-suite-form-max") => max)
    custom_message != "" && push!(attrs, Symbol("data-suite-form-custom-message") => custom_message)

    Div(attrs..., kwargs..., children...)
end

"""
    FormItem(children...; class, kwargs...) -> VNode

Layout container for a single form field. Groups label, control, description, and message.
"""
function FormItem(children...; class::String="", theme::Symbol=:default, kwargs...)
    item_classes = cn("grid gap-2", class)
    theme !== :default && (item_classes = apply_theme(item_classes, get_theme(theme)))
    Div(:class => item_classes,
        Symbol("data-suite-form-item") => "",
        kwargs...,
        children...)
end

"""
    FormLabel(children...; class, kwargs...) -> VNode

Accessible label for a form field. Automatically links to the form control via `for` attribute.
Turns red when the field has a validation error.
"""
function FormLabel(children...; class::String="", theme::Symbol=:default, kwargs...)
    label_classes = cn("text-sm font-medium text-warm-800 dark:text-warm-300 data-[error=true]:text-accent-secondary-600 dark:data-[error=true]:text-accent-secondary-500", class)
    theme !== :default && (label_classes = apply_theme(label_classes, get_theme(theme)))
    Therapy.Label(:class => label_classes,
          Symbol("data-suite-form-label") => "",
          kwargs...,
          children...)
end

"""
    FormControl(children...; kwargs...) -> VNode

Wrapper for the actual form control (input, select, textarea, etc.).
Injects ARIA attributes (aria-invalid, aria-describedby) via JS runtime.
"""
function FormControl(children...; kwargs...)
    Div(Symbol("data-suite-form-control") => "",
        :style => "display:contents",
        kwargs...,
        children...)
end

"""
    FormDescription(children...; class, kwargs...) -> VNode

Helper text for a form field. Linked to the control via `aria-describedby`.
"""
function FormDescription(children...; class::String="", theme::Symbol=:default, kwargs...)
    desc_classes = cn("text-sm text-warm-600 dark:text-warm-500", class)
    theme !== :default && (desc_classes = apply_theme(desc_classes, get_theme(theme)))
    P(:class => desc_classes,
      Symbol("data-suite-form-description") => "",
      kwargs...,
      children...)
end

"""
    FormMessage(children...; class, kwargs...) -> VNode

Error message for a form field. Hidden by default, shown when validation fails.
"""
function FormMessage(children...; class::String="", theme::Symbol=:default, kwargs...)
    msg_classes = cn("text-sm text-accent-secondary-600 dark:text-accent-secondary-500 hidden", class)
    theme !== :default && (msg_classes = apply_theme(msg_classes, get_theme(theme)))
    P(:class => msg_classes,
      Symbol("data-suite-form-message") => "",
      :role => "alert",
      Symbol("aria-live") => "polite",
      kwargs...,
      children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Form,
        "Form.jl",
        :island,
        "Form with per-field validation, error messages, and accessibility",
        Symbol[],
        Symbol[],
        [:Form, :FormField, :FormItem, :FormLabel,
         :FormControl, :FormDescription, :FormMessage],
    ))
end
