# widgets.jl — Suite.jl Widget Protocol + Widget Implementations
#
# Tier: widget (Island + @bind protocol)
#
# Widgets are interactive components that implement the bond protocol,
# enabling use with @bind in Pluto/Sessions.jl notebooks.
# A widget IS an island — it's a superset with bond protocol methods.
#
# Three-Tier Model:
#   1. Pure Styling (~20) — HTML + Tailwind, zero interactivity
#   2. Island (Wasm)  (~30) — @island compiled to WebAssembly
#   3. Widget (new)   — Island + @bind protocol (initial_value, transform_value, etc.)

# =============================================================================
# Abstract Widget Protocol
# =============================================================================

"""
    AbstractSuiteWidget

Abstract supertype for all Suite.jl widget structs.
Mirrors Sessions.jl's `AbstractWidget` and PlutoUI's `AbstractPlutoDingetjes.Bonds`.
"""
abstract type AbstractSuiteWidget end

"""
    initial_value(widget::AbstractSuiteWidget)

Return the initial Julia value before the browser renders.
Used for initial cell execution and running notebooks as scripts.
"""
initial_value(::AbstractSuiteWidget) = missing

"""
    possible_values(widget::AbstractSuiteWidget)

Return all possible values (before transformation).
Used by PlutoSliderServer.jl for precomputing notebook states.
"""
possible_values(::AbstractSuiteWidget) = nothing

"""
    transform_value(widget::AbstractSuiteWidget, val)

Convert a raw JavaScript value into a Julia value.
Typically maps an integer index back to the actual Julia value.
"""
transform_value(::AbstractSuiteWidget, val) = val

"""
    validate_value(widget::AbstractSuiteWidget, val)

Security validation for untrusted input on public PlutoSliderServer deployments.
Returns `true` if the value is acceptable.
"""
validate_value(::AbstractSuiteWidget, ::Any) = false

# =============================================================================
# Helper Functions
# =============================================================================

"""
    _downsample(values, max_steps) -> AbstractVector

Reduce a vector to at most `max_steps` evenly-spaced elements.
Preserves first and last elements.
"""
function _downsample(values::AbstractVector, max_steps::Integer)
    n = length(values)
    n <= max_steps && return values
    indices = round.(Int, range(1, n, length=max_steps))
    values[indices]
end

"""
    _closest(values, x)

Find the element in `values` nearest to `x`.
"""
function _closest(values::AbstractVector, x)
    _, idx = findmin(v -> abs(v - x), values)
    values[idx]
end

"""
    _slider_index(widget, val) -> Int

Find the 1-based index of `val` in the widget's values vector.
Falls back to the closest match if exact match not found.
"""
function _slider_index(s, val)
    idx = findfirst(isequal(val), s.values)
    idx !== nothing && return idx
    _, i = findmin(v -> abs(v - val), s.values)
    return i
end

# =============================================================================
# SliderWidget
# =============================================================================

"""
    SliderWidget{T} <: AbstractSuiteWidget

Widget struct for slider binding. Created by `Slider(values::AbstractVector; ...)`.

Fields:
- `values::Vector{T}` — the discrete values the slider can take
- `default::T` — initial value
- `show_value::Bool` — whether to display the current value
- `label::String` — optional label text
- `class::String` — additional CSS classes
- `theme::Symbol` — Suite.jl theme
"""
struct SliderWidget{T} <: AbstractSuiteWidget
    values::Vector{T}
    default::T
    show_value::Bool
    label::String
    class::String
    theme::Symbol
end

# --- Constructors (mirrors Sessions.jl's Slider constructor) ---

"""
    SliderWidget(values::AbstractVector; default=missing, show_value=true, ...)

Create a slider widget for use with `@bind`. Mirrors Sessions.jl's `Slider` constructor.

# Examples
```julia
@bind x Suite.SliderWidget(1:100)
@bind y Suite.SliderWidget(0.0:0.01:1.0; default=0.5)
@bind c Suite.SliderWidget(["red", "green", "blue"])
```
"""
function SliderWidget(values::AbstractVector{T};
        default=missing, show_value::Bool=true, label::String="",
        class::String="", theme::Symbol=:default,
        max_steps::Integer=1_000) where T
    vs = _downsample(collect(values), max_steps)
    d = default === missing ? first(vs) : _closest(vs, default)
    SliderWidget{T}(vs, d, show_value, label, class, theme)
end

SliderWidget(range::AbstractRange; kwargs...) = SliderWidget(collect(range); kwargs...)

# --- Bond Protocol ---

initial_value(s::SliderWidget) = s.default
possible_values(s::SliderWidget) = 1:length(s.values)
transform_value(s::SliderWidget, idx) = s.values[idx]

function validate_value(s::SliderWidget, val)
    val isa Integer && 1 <= val <= length(s.values)
end

# --- HTML Rendering (for Pluto / Sessions.jl @bind) ---

function Base.show(io::IO, ::MIME"text/html", s::SliderWidget)
    n = length(s.values)
    idx = _slider_index(s, s.default)
    id = "suite-slider-" * string(rand(UInt32), base=16)

    # Wrapper classes
    wrapper_cls = "inline-flex items-center gap-3 font-sans"
    if !isempty(s.class)
        wrapper_cls *= " " * s.class
    end

    # Track classes (warm neutral + accent)
    track_cls = string(
        "h-1.5 rounded-full appearance-none cursor-pointer bg-warm-200 dark:bg-warm-700 ",
        "accent-accent-600 ",
        "[&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:w-4 [&::-webkit-slider-thumb]:h-4 ",
        "[&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-accent-600 ",
        "[&::-webkit-slider-thumb]:border [&::-webkit-slider-thumb]:border-accent-700 ",
        "[&::-webkit-slider-thumb]:shadow-sm [&::-webkit-slider-thumb]:cursor-pointer ",
        "[&::-moz-range-thumb]:w-4 [&::-moz-range-thumb]:h-4 ",
        "[&::-moz-range-thumb]:rounded-full [&::-moz-range-thumb]:bg-accent-600 ",
        "[&::-moz-range-thumb]:border [&::-moz-range-thumb]:border-accent-700 ",
        "[&::-moz-range-thumb]:shadow-sm [&::-moz-range-thumb]:cursor-pointer ",
        "[&::-moz-range-track]:bg-warm-200 dark:[&::-moz-range-track]:bg-warm-700 ",
        "[&::-moz-range-track]:rounded-full [&::-moz-range-track]:h-1.5",
    )

    print(io, "<span id=\"", id, "\" class=\"", wrapper_cls, "\">")

    # Optional label
    if !isempty(s.label)
        print(io, "<label class=\"text-sm font-medium text-warm-700 dark:text-warm-300\">",
              s.label, "</label>")
    end

    # Range input (index-mapped: 1..N)
    print(io, "<input type=\"range\" min=\"1\" max=\"", n,
          "\" value=\"", idx,
          "\" class=\"w-48 ", track_cls, "\">")

    # Optional value display
    if s.show_value
        print(io, "<span class=\"text-sm tabular-nums text-warm-600 dark:text-warm-400 min-w-[3ch] text-right\" data-slider-display>",
              s.default, "</span>")
    end

    print(io, "</span>")

    # Inline script: define .value on outer span, update display on input
    print(io, "<script>")
    print(io, "(function(){")
    print(io, "var el=document.getElementById('", id, "');")
    print(io, "var inp=el.querySelector('input');")
    print(io, "var vals=", _values_json(s.values), ";")
    print(io, "Object.defineProperty(el,'value',{get:function(){return inp.valueAsNumber},configurable:true});")
    if s.show_value
        print(io, "var disp=el.querySelector('[data-slider-display]');")
        print(io, "inp.addEventListener('input',function(){")
        print(io, "disp.textContent=vals[inp.valueAsNumber-1];")
        print(io, "el.dispatchEvent(new CustomEvent('input'));")
        print(io, "});")
    else
        print(io, "inp.addEventListener('input',function(){")
        print(io, "el.dispatchEvent(new CustomEvent('input'));")
        print(io, "});")
    end
    print(io, "})();")
    print(io, "</script>")
end

"""
    _values_json(values) -> String

Serialize a vector to a JSON array string for inline JS.
"""
function _values_json(values::Vector)
    buf = IOBuffer()
    print(buf, "[")
    for (i, v) in enumerate(values)
        i > 1 && print(buf, ",")
        if v isa AbstractString
            print(buf, "\"", replace(v, "\"" => "\\\""), "\"")
        else
            print(buf, v)
        end
    end
    print(buf, "]")
    String(take!(buf))
end

# --- Plain text rendering ---

function Base.show(io::IO, ::MIME"text/plain", s::SliderWidget)
    print(io, "SliderWidget($(length(s.values)) values, default=$(s.default))")
end
