# Widgets — Overview of Suite.jl's dual-mode widget system
#
# Shows how Suite.jl components work as both UI components (Therapy.jl)
# and reactive data widgets (Pluto @bind).

function WidgetsIndex()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3",
                "Widgets"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-400",
                "Suite.jl components as reactive data widgets — for Pluto notebooks and Therapy.jl apps."
            )
        ),

        Div(:class => "prose max-w-none",

            # The idea
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mt-10 mb-4",
                "The Big Idea"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Every Suite.jl interactive component serves double duty:"
            ),
            Div(:class => "grid md:grid-cols-2 gap-4 mb-6",
                Div(:class => "border border-warm-200 dark:border-warm-700 rounded-lg p-5 bg-warm-50/50 dark:bg-warm-900/50",
                    H3(:class => "text-lg font-serif font-semibold text-warm-800 dark:text-warm-300 mb-2", "UI Component"),
                    P(:class => "text-sm text-warm-600 dark:text-warm-400 mb-3",
                        "In a Therapy.jl app, call the component as a function. It returns a VNode that renders styled HTML."
                    ),
                    Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-md p-4 overflow-x-auto",
                        Pre(:class => "text-xs text-warm-100",
                            Code("Switch(checked=true)\nInput(type=\"email\", placeholder=\"you@example.com\")")
                        )
                    )
                ),
                Div(:class => "border border-warm-200 dark:border-warm-700 rounded-lg p-5 bg-warm-50/50 dark:bg-warm-900/50",
                    H3(:class => "text-lg font-serif font-semibold text-warm-800 dark:text-warm-300 mb-2", "Data Widget"),
                    P(:class => "text-sm text-warm-600 dark:text-warm-400 mb-3",
                        "In a Pluto notebook, pass a positional argument to get a bindable struct. Use with ", Code(:class => "text-xs bg-warm-200 dark:bg-warm-800 px-1 py-0.5 rounded", "@bind"), "."
                    ),
                    Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-md p-4 overflow-x-auto",
                        Pre(:class => "text-xs text-warm-100",
                            Code("@bind value SuiteSlider(1:100)\n@bind lang SuiteSelect([\"julia\" => \"Julia\"])")
                        )
                    )
                )
            ),

            Main.Alert(
                Main.AlertTitle("Same styling, different mode"),
                Main.AlertDescription("Both modes render with the same warm-neutral + accent design system. Your widgets look identical whether in a notebook or a web app.")
            ),

            # How disambiguation works
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mt-10 mb-4",
                "Positional vs Keyword"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "The calling convention determines which mode you get:"
            ),
            Main.Table(
                Main.TableHeader(
                    Main.TableRow(
                        Main.TableHead("Call Style"),
                        Main.TableHead("Returns"),
                        Main.TableHead("Use Case")
                    )
                ),
                Main.TableBody(
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "SuiteSlider(1:100)"),
                        Main.TableCell("Struct (widget)"),
                        Main.TableCell("Pluto @bind")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "SuiteSlider(; min=0, max=100)"),
                        Main.TableCell("VNode (HTML)"),
                        Main.TableCell("Therapy.jl rendering")
                    )
                )
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4 mt-4",
                "Positional argument = struct for ", Code(:class => "text-sm bg-warm-200 dark:bg-warm-800 px-1.5 py-0.5 rounded", "@bind"),
                ". Keyword-only = VNode for Therapy.jl. This keeps one function name for both contexts."
            ),

            # Widget mapping table
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mt-10 mb-4",
                "Widget Mapping"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Suite.jl provides styled replacements for every PlutoUI widget:"
            ),
            Main.Table(
                Main.TableHeader(
                    Main.TableRow(
                        Main.TableHead("PlutoUI"),
                        Main.TableHead("Suite.jl"),
                        Main.TableHead("Bound Type"),
                        Main.TableHead("Status")
                    )
                ),
                Main.TableBody(
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "Slider"),
                        Main.TableCell(class="font-mono text-xs", "SuiteSlider"),
                        Main.TableCell(class="font-mono text-xs", "eltype(range)"),
                        Main.TableCell(Main.Badge(variant="outline", "Planned"))
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "CheckBox"),
                        Main.TableCell(class="font-mono text-xs", "SuiteCheckbox"),
                        Main.TableCell(class="font-mono text-xs", "Bool"),
                        Main.TableCell(Main.Badge(variant="outline", "Planned"))
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "Switch"),
                        Main.TableCell(class="font-mono text-xs", "SuiteSwitch"),
                        Main.TableCell(class="font-mono text-xs", "Bool"),
                        Main.TableCell(Main.Badge("Available"))
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "Select"),
                        Main.TableCell(class="font-mono text-xs", "SuiteSelect"),
                        Main.TableCell(class="font-mono text-xs", "Key type"),
                        Main.TableCell(Main.Badge(variant="outline", "Planned"))
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "Radio"),
                        Main.TableCell(class="font-mono text-xs", "SuiteRadioGroup"),
                        Main.TableCell(class="font-mono text-xs", "Key type"),
                        Main.TableCell(Main.Badge(variant="outline", "Planned"))
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "TextField"),
                        Main.TableCell(class="font-mono text-xs", "SuiteInput"),
                        Main.TableCell(class="font-mono text-xs", "String"),
                        Main.TableCell(Main.Badge("Available"))
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "TextField (multi)"),
                        Main.TableCell(class="font-mono text-xs", "SuiteTextarea"),
                        Main.TableCell(class="font-mono text-xs", "String"),
                        Main.TableCell(Main.Badge("Available"))
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "DatePicker"),
                        Main.TableCell(class="font-mono text-xs", "SuiteDatePicker"),
                        Main.TableCell(class="font-mono text-xs", "Dates.Date"),
                        Main.TableCell(Main.Badge(variant="outline", "Planned"))
                    )
                )
            ),

            # Three tiers in widget context
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mt-10 mb-4",
                "Three Tiers, Two Modes"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Suite.jl's three implementation tiers interact with the dual-mode widget system:"
            ),
            Main.Table(
                Main.TableHeader(
                    Main.TableRow(
                        Main.TableHead("Tier"),
                        Main.TableHead("Therapy.jl Mode"),
                        Main.TableHead("Pluto Mode")
                    )
                ),
                Main.TableBody(
                    Main.TableRow(
                        Main.TableCell(class="font-medium", "Pure Styling"),
                        Main.TableCell("VNode with Tailwind classes"),
                        Main.TableCell("show(io, MIME\"text/html\"()) with same classes")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium", "Interactive"),
                        Main.TableCell("@island with create_signal"),
                        Main.TableCell("Inline <script> for interactivity")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium", "JS Runtime"),
                        Main.TableCell("suite.js auto-discovery"),
                        Main.TableCell("Bundled JS in widget HTML")
                    )
                )
            ),

            # Package extension
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mt-10 mb-4",
                "Zero-Cost Dependency"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "The Pluto integration uses Julia's package extension system. If you only use Therapy.jl, AbstractPlutoDingetjes is never loaded:"
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-100",
                    Code("""# Project.toml
[weakdeps]
AbstractPlutoDingetjes = "6e696c72-..."

[extensions]
SuitePlutoExt = "AbstractPlutoDingetjes"

# ext/SuitePlutoExt.jl — only loaded inside Pluto
module SuitePlutoExt
using Suite
import AbstractPlutoDingetjes.Bonds

Bonds.initial_value(s::Suite.SuiteSliderWidget) = s.default
Bonds.transform_value(s::Suite.SuiteSliderWidget, val) = s.values[val]
end""")
                )
            ),
            Main.Alert(
                Main.AlertTitle("No overhead"),
                Main.AlertDescription("In a Therapy.jl-only project, AbstractPlutoDingetjes is never imported. The widget structs exist but the Bonds protocol methods are only defined when Pluto loads the extension.")
            ),

            # Next steps
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mt-10 mb-4",
                "Next Steps"
            ),
            Ul(:class => "list-disc list-inside space-y-2 text-warm-600 dark:text-warm-400 mb-6",
                Li(
                    A(:href => "./widgets/bind/", :class => "text-accent-600 dark:text-accent-400 hover:underline", "The @bind Pattern"),
                    " — How the PlutoUI protocol works under the hood"
                ),
                Li(
                    A(:href => "./examples/", :class => "text-accent-600 dark:text-accent-400 hover:underline", "Examples"),
                    " — Full-page compositions showing components in action"
                ),
                Li(
                    A(:href => "./components/switch/", :class => "text-accent-600 dark:text-accent-400 hover:underline", "Switch"),
                    " — An interactive component that doubles as a widget"
                )
            )
        )
    )
end

WidgetsIndex
