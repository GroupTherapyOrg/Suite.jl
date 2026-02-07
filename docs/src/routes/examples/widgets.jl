# Widget Showcase — interactive widget playground
#
# Shows Suite.jl's bindable components in action, demonstrating
# how they look and behave in both UI and widget modes.

function WidgetsExample()
    Div(:class => "max-w-4xl mx-auto py-8",
        # Header
        PageHeader("Widget Showcase", "Interactive components that double as Pluto @bind widgets."),

        Div(:class => "grid gap-8",

            # Available widgets
            SectionH2( "Available Now"),

            # Switch widget
            Main.Card(
                Main.CardHeader(
                    Main.CardTitle("Switch"),
                    Main.CardDescription("Boolean toggle — works as UI component and @bind widget.")
                ),
                Main.CardContent(
                    Div(:class => "grid md:grid-cols-2 gap-6",
                        # Live demo
                        Div(:class => "space-y-4",
                            H4(:class => "text-sm font-medium text-warm-800 dark:text-warm-300 mb-3", "Live Demo"),
                            Div(:class => "space-y-3",
                                Div(:class => "flex items-center justify-between",
                                    Main.Label("Dark mode"),
                                    Main.Switch(checked=true)
                                ),
                                Div(:class => "flex items-center justify-between",
                                    Main.Label("Notifications"),
                                    Main.Switch()
                                ),
                                Div(:class => "flex items-center justify-between",
                                    Main.Label("Disabled"),
                                    Main.Switch(disabled=true)
                                )
                            )
                        ),
                        # Code
                        Div(
                            H4(:class => "text-sm font-medium text-warm-800 dark:text-warm-300 mb-3", "Usage"),
                            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-md p-4 overflow-x-auto",
                                Main.CodeBlock(language="julia", """# Therapy.jl mode
Switch(checked=true)

# Pluto @bind mode
@bind dark SuiteSwitch(; default=false)""")
                            )
                        )
                    )
                )
            ),

            # Toggle widget
            Main.Card(
                Main.CardHeader(
                    Main.CardTitle("Toggle"),
                    Main.CardDescription("Pressed/unpressed button — ideal for boolean feature flags.")
                ),
                Main.CardContent(
                    Div(:class => "grid md:grid-cols-2 gap-6",
                        Div(:class => "space-y-4",
                            H4(:class => "text-sm font-medium text-warm-800 dark:text-warm-300 mb-3", "Live Demo"),
                            Div(:class => "flex flex-wrap gap-3",
                                Main.Toggle("Bold"),
                                Main.Toggle(variant="outline", "Italic"),
                                Main.Toggle(pressed=true, "Underline"),
                                Main.Toggle(disabled=true, "Disabled")
                            )
                        ),
                        Div(
                            H4(:class => "text-sm font-medium text-warm-800 dark:text-warm-300 mb-3", "Usage"),
                            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-md p-4 overflow-x-auto",
                                Main.CodeBlock(language="julia", """# Therapy.jl mode
Toggle(pressed=true, "Bold")
Toggle(variant="outline", "Italic")""")
                            )
                        )
                    )
                )
            ),

            # Toggle Group widget
            Main.Card(
                Main.CardHeader(
                    Main.CardTitle("Toggle Group"),
                    Main.CardDescription("Single or multiple selection from a group of toggle buttons.")
                ),
                Main.CardContent(
                    Div(:class => "grid md:grid-cols-2 gap-6",
                        Div(:class => "space-y-4",
                            H4(:class => "text-sm font-medium text-warm-800 dark:text-warm-300 mb-3", "Live Demo"),
                            Div(:class => "space-y-4",
                                Div(
                                    P(:class => "text-xs text-warm-500 dark:text-warm-500 mb-2", "Single select"),
                                    Main.ToggleGroup(type="single", default_value="center",
                                        Main.ToggleGroupItem(value="left", "Left"),
                                        Main.ToggleGroupItem(value="center", "Center"),
                                        Main.ToggleGroupItem(value="right", "Right")
                                    )
                                ),
                                Div(
                                    P(:class => "text-xs text-warm-500 dark:text-warm-500 mb-2", "Multiple select"),
                                    Main.ToggleGroup(type="multiple", default_value="bold,italic",
                                        Main.ToggleGroupItem(value="bold", "B"),
                                        Main.ToggleGroupItem(value="italic", "I"),
                                        Main.ToggleGroupItem(value="underline", "U")
                                    )
                                )
                            )
                        ),
                        Div(
                            H4(:class => "text-sm font-medium text-warm-800 dark:text-warm-300 mb-3", "Usage"),
                            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-md p-4 overflow-x-auto",
                                Main.CodeBlock(language="julia", """# Single selection
ToggleGroup(type="single",
    ToggleGroupItem(value="left", "L"),
    ToggleGroupItem(value="center", "C"),
    ToggleGroupItem(value="right", "R")
)""")
                            )
                        )
                    )
                )
            ),

            # Input & Textarea (available as styling-only widgets)
            Main.Card(
                Main.CardHeader(
                    Main.CardTitle("Input & Textarea"),
                    Main.CardDescription("Text input fields — bind to String values in Pluto.")
                ),
                Main.CardContent(
                    Div(:class => "grid md:grid-cols-2 gap-6",
                        Div(:class => "space-y-4",
                            H4(:class => "text-sm font-medium text-warm-800 dark:text-warm-300 mb-3", "Live Demo"),
                            Div(:class => "grid gap-3",
                                Div(:class => "grid gap-1.5",
                                    Main.Label("Name"),
                                    Main.Input(placeholder="Julia Developer")
                                ),
                                Div(:class => "grid gap-1.5",
                                    Main.Label("Email"),
                                    Main.Input(type="email", placeholder="you@example.com")
                                ),
                                Div(:class => "grid gap-1.5",
                                    Main.Label("Bio"),
                                    Main.Textarea(placeholder="Tell us about yourself...", class="min-h-20")
                                )
                            )
                        ),
                        Div(
                            H4(:class => "text-sm font-medium text-warm-800 dark:text-warm-300 mb-3", "Usage"),
                            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-md p-4 overflow-x-auto",
                                Main.CodeBlock(language="julia", """# Therapy.jl mode
Input(type="email", placeholder="...")
Textarea(placeholder="...")

# Pluto @bind mode
@bind name SuiteInput(; default="")
@bind bio SuiteTextarea(; default="")""")
                            )
                        )
                    )
                )
            ),

            Main.Separator(),

            # Planned widgets
            SectionH2( "Coming Soon"),
            P(:class => "text-warm-600 dark:text-warm-400 mb-6",
                "These widgets are designed and will implement the full @bind protocol with index-mapping."
            ),

            Div(:class => "grid sm:grid-cols-2 md:grid-cols-3 gap-4",
                _PlannedWidget("Slider", "Numeric range input with track and thumb.", "@bind x SuiteSlider(1:100)"),
                _PlannedWidget("Checkbox", "Boolean checkbox with label.", "@bind ok SuiteCheckbox()"),
                _PlannedWidget("Select", "Dropdown selection from options.", "@bind lang SuiteSelect([...])"),
                _PlannedWidget("Radio Group", "Radio button group selection.", "@bind size SuiteRadioGroup([...])"),
                _PlannedWidget("Date Picker", "Calendar-based date selection.", "@bind date SuiteDatePicker()"),
                _PlannedWidget("Color Picker", "Color selection returning RGB.", "@bind color SuiteColorPicker()")
            ),

            # How it all connects
            Main.Separator(),

            Div(:class => "text-center py-6",
                P(:class => "text-warm-600 dark:text-warm-400 mb-4",
                    "Learn more about the underlying protocol:"
                ),
                Div(:class => "flex justify-center gap-3",
                    Main.Button(variant="default",
                        A(:href => "./widgets/", :class => "text-white no-underline", "Widget Overview")
                    ),
                    Main.Button(variant="outline",
                        A(:href => "./widgets/bind/", :class => "no-underline text-warm-800 dark:text-warm-300", "The @bind Pattern")
                    )
                )
            )
        )
    )
end

function _PlannedWidget(title, description, code)
    Div(:class => "border border-warm-200 dark:border-warm-700 rounded-lg p-4 bg-warm-50/50 dark:bg-warm-900/50",
        Div(:class => "flex items-start justify-between mb-2",
            H4(:class => "text-sm font-medium text-warm-800 dark:text-warm-300", title),
            Main.Badge(variant="outline", class="text-[10px]", "Planned")
        ),
        P(:class => "text-xs text-warm-600 dark:text-warm-400 mb-3", description),
        Div(:class => "bg-warm-900 dark:bg-warm-950 rounded px-3 py-2",
            Main.InlineCode(code)
        )
    )
end

WidgetsExample
