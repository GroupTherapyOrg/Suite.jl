# Widgets — Slider
#
# Documentation for Suite.Slider widget mode (positional-arg dispatch).
# Shows usage with @bind, API reference, and bond protocol details.

function SliderWidgetPage()
    WidgetsLayout(
        # Header
        PageHeader("Slider Widget", "A range slider for @bind — maps discrete Julia values to an HTML range input via index mapping."),

        Div(:class => "prose max-w-none",

            # Live preview
            SectionH2("Preview"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "A rendered SliderWidget as it appears in a notebook:"
            ),
            Div(:class => "border border-warm-200 dark:border-warm-700 rounded-lg p-6 bg-warm-50/50 dark:bg-warm-900/50 mb-6",
                RawHtml(let io = IOBuffer()
                    show(io, MIME"text/html"(), Main.Slider(1:100; label="Temperature"))
                    String(take!(io))
                end)
            ),

            # Basic usage
            SectionH2("Usage"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Pass a positional ", Main.InlineCode("AbstractVector"), " argument to get a widget struct for ",
                Main.InlineCode("@bind"), ". Keyword-only calls still produce a VNode (island)."
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Main.CodeBlock(language="julia", """using Suite

# Widget mode (positional arg → struct for @bind)
@bind temperature Suite.Slider(0:100; default=20)
@bind opacity Suite.Slider(0.0:0.01:1.0; default=0.5)
@bind color Suite.Slider(["red", "green", "blue"]; default="green")

# Island mode (keyword-only → VNode for Therapy.jl)
Suite.Slider(; min=0, max=100, default_value=50)""")
            ),

            # Options
            SectionH2("Options"),
            Main.Table(
                Main.TableHeader(
                    Main.TableRow(
                        Main.TableHead("Kwarg"),
                        Main.TableHead("Type"),
                        Main.TableHead("Default"),
                        Main.TableHead("Description")
                    )
                ),
                Main.TableBody(
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "default"),
                        Main.TableCell(class="font-mono text-xs", "eltype(values)"),
                        Main.TableCell(class="font-mono text-xs", "first(values)"),
                        Main.TableCell("Initial value (snaps to nearest)")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "show_value"),
                        Main.TableCell(class="font-mono text-xs", "Bool"),
                        Main.TableCell(class="font-mono text-xs", "true"),
                        Main.TableCell("Display current value next to slider")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "label"),
                        Main.TableCell(class="font-mono text-xs", "String"),
                        Main.TableCell(class="font-mono text-xs", "\"\""),
                        Main.TableCell("Label text shown before slider")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "class"),
                        Main.TableCell(class="font-mono text-xs", "String"),
                        Main.TableCell(class="font-mono text-xs", "\"\""),
                        Main.TableCell("Additional CSS classes on wrapper")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "theme"),
                        Main.TableCell(class="font-mono text-xs", "Symbol"),
                        Main.TableCell(class="font-mono text-xs", ":default"),
                        Main.TableCell("Suite.jl theme")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "max_steps"),
                        Main.TableCell(class="font-mono text-xs", "Integer"),
                        Main.TableCell(class="font-mono text-xs", "1_000"),
                        Main.TableCell("Downsample values to at most N steps")
                    )
                )
            ),

            # Bond protocol
            Main.Separator(),
            SectionH2("Bond Protocol"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "The SliderWidget implements the full bond protocol using index mapping:"
            ),
            Main.Table(
                Main.TableHeader(
                    Main.TableRow(
                        Main.TableHead("Method"),
                        Main.TableHead("Returns"),
                        Main.TableHead("Description")
                    )
                ),
                Main.TableBody(
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "initial_value(s)"),
                        Main.TableCell(class="font-mono text-xs", "s.default"),
                        Main.TableCell("Initial Julia value before browser renders")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "possible_values(s)"),
                        Main.TableCell(class="font-mono text-xs", "1:length(s.values)"),
                        Main.TableCell("Integer indices for precomputing states")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "transform_value(s, idx)"),
                        Main.TableCell(class="font-mono text-xs", "s.values[idx]"),
                        Main.TableCell("Map index back to Julia value")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "validate_value(s, val)"),
                        Main.TableCell(class="font-mono text-xs", "Bool"),
                        Main.TableCell("Check index is Integer in valid range")
                    )
                )
            ),

            # Index mapping explanation
            SectionH3("Index Mapping"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "The HTML range input goes from 1 to ", Main.InlineCode("length(values)"),
                ". JavaScript sends the integer index, and ", Main.InlineCode("transform_value"),
                " maps it back to the actual Julia value. This enables binding to any Julia type."
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Main.CodeBlock(language="julia", """s = Suite.Slider(["low", "medium", "high"])

# HTML: <input type="range" min="1" max="3" value="1">
# User drags to position 2 → JS sends index 2
# transform_value(s, 2) → "medium"
# The bound variable becomes "medium" """)
            ),

            # Examples
            Main.Separator(),
            SectionH2("Examples"),

            SectionH3("Integer Range"),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Main.CodeBlock(language="julia", "@bind n Suite.Slider(1:100)\n# n is an Int in 1:100")
            ),

            SectionH3("Float Range"),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Main.CodeBlock(language="julia", "@bind alpha Suite.Slider(0.0:0.01:1.0; default=0.5)\n# alpha is a Float64 in 0.0:0.01:1.0")
            ),

            SectionH3("Arbitrary Values"),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Main.CodeBlock(language="julia", """@bind city Suite.Slider(["NYC", "LA", "Chicago", "Houston"])
# city is a String""")
            ),

            SectionH3("With Label"),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Main.CodeBlock(language="julia", """@bind temp Suite.Slider(0:100; default=20, label="Temperature")""")
            ),

            # Next steps
            SectionH2("Next Steps"),
            Ul(:class => "list-disc list-inside space-y-2 text-warm-600 dark:text-warm-400 mb-6",
                Li(
                    A(:href => "./widgets/bind/", :class => "text-accent-600 dark:text-accent-400 hover:underline", "The @bind Pattern"),
                    " — How the bond protocol works under the hood"
                ),
                Li(
                    A(:href => "./widgets/", :class => "text-accent-600 dark:text-accent-400 hover:underline", "Widget Overview"),
                    " — Full mapping table and three-tier architecture"
                ),
                Li(
                    A(:href => "./components/slider/", :class => "text-accent-600 dark:text-accent-400 hover:underline", "Slider Island"),
                    " — The Wasm-powered island version of Slider"
                )
            )
        )
    )
end

SliderWidgetPage
