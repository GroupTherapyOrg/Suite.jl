# Widgets — The @bind Pattern
#
# Deep dive into how PlutoUI's @bind protocol works and how
# Suite.jl implements it for styled, accessible widgets.

function BindPage()
    ComponentsLayout(
        # Header
        PageHeader("The @bind Pattern", "How PlutoUI's reactive binding protocol works, and how Suite.jl implements it."),

        Div(:class => "prose max-w-none",

            # Overview
            SectionH2("How @bind Works"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "In Pluto notebooks, ", Main.InlineCode("@bind"),
                " creates a two-way connection between a Julia variable and an HTML widget:"
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Main.CodeBlock(language="julia", """@bind temperature Suite.Slider(0:100; default=20)

# `temperature` is now a reactive Julia variable.
# Moving the slider updates it, re-executing dependent cells.""")
            ),

            # The flow
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "The lifecycle:"
            ),
            Ol(:class => "list-decimal list-inside space-y-2 text-warm-600 dark:text-warm-400 mb-6",
                Li("Julia calls ", Main.InlineCode("show(io, MIME\"text/html\"(), widget)"), " to render styled HTML"),
                Li("Pluto attaches an event listener to the outermost element"),
                Li("User interacts — the element dispatches an ", Main.InlineCode("input"), " event"),
                Li("Pluto reads ", Main.InlineCode("element.value"), " from JavaScript"),
                Li("Julia calls ", Main.InlineCode("transform_value(widget, js_value)"), " to convert back"),
                Li("The bound variable updates and dependent cells re-execute")
            ),

            # Four protocol methods
            SectionH2("The Four Protocol Methods"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Suite.jl implements these methods from ", Main.InlineCode("AbstractPlutoDingetjes.Bonds"),
                " for each widget type:"
            ),

            # initial_value
            SectionH3("initial_value(widget)"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Returns the Julia value before the browser renders. Used for initial cell execution and running notebooks as scripts."
            ),
            Main.CodeBlock(language="julia", "initial_value(s::SliderWidget) = s.default  # e.g., 50"),

            # transform_value
            SectionH3("transform_value(widget, value_from_js)"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Converts the raw JavaScript value into a Julia value. This is the key innovation — it enables binding arbitrary Julia objects via index mapping."
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-4 mb-6 overflow-x-auto",
                Main.CodeBlock(language="julia", """# Slider: JS sends integer index → map to Julia value
transform_value(s::SliderWidget, idx) = s.values[idx]

# Checkbox: JS sends boolean directly
transform_value(c::CheckboxWidget, val) = val""")
            ),

            # possible_values
            SectionH3("possible_values(widget)"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Returns all possible values (before transformation). Used by PlutoSliderServer.jl for precomputing notebook states."
            ),
            Main.CodeBlock(language="julia", "possible_values(s::SliderWidget) = 1:length(s.values)  # indices"),

            # validate_value
            SectionH3("validate_value(widget, value_from_js)"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Security validation for untrusted input on public PlutoSliderServer deployments. Values are validated before transformation."
            ),
            Main.CodeBlock(language="julia", "validate_value(s::SliderWidget, val) = val isa Integer && 1 <= val <= length(s.values)"),

            Main.Separator(),

            # The index-mapping pattern
            SectionH2("The Index-Mapping Pattern"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "The most important design pattern in the @bind protocol. Widgets that support arbitrary Julia values do not send those values to JavaScript. Instead:"
            ),
            Ol(:class => "list-decimal list-inside space-y-2 text-warm-600 dark:text-warm-400 mb-6",
                Li("Julia stores a vector of values and assigns integer indices"),
                Li("HTML uses indices as the input value"),
                Li("JavaScript sends the index (integer) back to Julia"),
                Li(Main.InlineCode("transform_value"), " maps the index back to the Julia value")
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "This enables binding to arbitrary Julia objects — even functions or structs:"
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Main.CodeBlock(language="julia", """# Bind to Julia functions!
@bind transform Suite.Select([
    sin => "Sine",
    cos => "Cosine",
    tan => "Tangent"
])

# `transform` is now a Julia function (sin, cos, or tan)
plot(transform, 0:0.1:2\u03c0)""")
            ),
            Main.Alert(
                Main.AlertTitle("Why indices?"),
                Main.AlertDescription("JavaScript can only send JSON-serializable values (strings, numbers, booleans). By sending integer indices and mapping back, Suite.jl can bind to any Julia type — functions, custom structs, even modules.")
            ),

            Main.Separator(),

            # The HTML contract
            SectionH2("The HTML Contract"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "For Pluto to connect a widget, its rendered HTML must follow these rules:"
            ),
            Ul(:class => "list-disc list-inside space-y-2 text-warm-600 dark:text-warm-400 mb-6",
                Li("The outermost element is what Pluto attaches the event listener to"),
                Li("The element must have a ", Main.InlineCode(".value"), " property readable from JavaScript"),
                Li("The element must dispatch ", Main.InlineCode("CustomEvent(\"input\")"), " when the value changes"),
                Li("Native inputs (", Main.InlineCode("<input>"), ", ", Main.InlineCode("<select>"), ") satisfy this automatically")
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "For custom widgets (like Suite.jl's styled Switch), use ", Main.InlineCode("Object.defineProperty"),
                " to define a custom ", Main.InlineCode(".value"), " getter on the outer element."
            ),

            Main.Separator(),

            # Full example
            SectionH2("Full Example: Suite.Slider"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Here's how a complete dual-mode widget is implemented:"
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Main.CodeBlock(language="julia", """# --- Widget struct (for @bind) ---
struct SliderWidget{T} <: AbstractSuiteWidget
    values::Vector{T}
    default::T
    show_value::Bool
end

# Positional arg → struct (widget mode, mirrors Sessions.jl)
function Slider(values::AbstractVector{T};
        default=missing, show_value::Bool=true,
        max_steps::Integer=1_000) where T
    vs = _downsample(collect(values), max_steps)
    d = default === missing ? first(vs) : _closest(vs, default)
    SliderWidget(vs, d, show_value)
end

# Keyword-only → VNode (island mode for Therapy.jl)
@island function Slider(; min=0, max=100, step=1, ...)
    # ... Wasm-compiled interactive slider
end

# --- Bond protocol ---
initial_value(s::SliderWidget) = s.default
possible_values(s::SliderWidget) = 1:length(s.values)
transform_value(s::SliderWidget, idx) = s.values[idx]
validate_value(s::SliderWidget, val) =
    val isa Integer && 1 <= val <= length(s.values)

# --- HTML rendering (for @bind in notebooks) ---
function Base.show(io::IO, ::MIME"text/html", s::SliderWidget)
    idx = _slider_index(s, s.default)
    # Renders styled <input type="range"> with index mapping
    # + inline <script> for .value property + input event
end""")
            ),

            # Therapy.jl reactivity comparison
            SectionH2("Pluto vs Therapy.jl Reactivity"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "The two systems use different reactivity models, but the widget looks the same:"
            ),
            Main.Table(
                Main.TableHeader(
                    Main.TableRow(
                        Main.TableHead(""),
                        Main.TableHead("Pluto"),
                        Main.TableHead("Therapy.jl")
                    )
                ),
                Main.TableBody(
                    Main.TableRow(
                        Main.TableCell(class="font-medium", "Reactivity"),
                        Main.TableCell("Cell re-execution"),
                        Main.TableCell("Fine-grained signals")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium", "Binding"),
                        Main.TableCell(class="font-mono text-xs", "@bind x widget"),
                        Main.TableCell(class="font-mono text-xs", "create_signal()")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium", "State flow"),
                        Main.TableCell("JS → JSON → Julia → cells"),
                        Main.TableCell("JS → WebSocket → signal → DOM")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium", "Granularity"),
                        Main.TableCell("Entire cell"),
                        Main.TableCell("Individual DOM nodes")
                    )
                )
            ),

            # Next steps
            SectionH2("Next Steps"),
            Ul(:class => "list-disc list-inside space-y-2 text-warm-600 dark:text-warm-400 mb-6",
                Li(
                    A(:href => "./widgets/", :class => "text-accent-600 dark:text-accent-400 hover:underline", "Widget Overview"),
                    " — Full mapping table and dual-mode architecture"
                ),
                Li(
                    A(:href => "./components/switch/", :class => "text-accent-600 dark:text-accent-400 hover:underline", "Switch"),
                    " — An interactive component available as a widget today"
                ),
                Li(
                    A(:href => "./components/toggle/", :class => "text-accent-600 dark:text-accent-400 hover:underline", "Toggle"),
                    " — Toggle component with pressed/unpressed state"
                )
            )
        )
    )
end

BindPage
