# Progress — Suite.jl component docs page
#
# Showcases Progress bar with different values.


function ProgressPage()
    ComponentsLayout(
        # Header
        PageHeader("Progress", "Displays an indicator showing the completion progress of a task."),

        # Default Preview
        ComponentPreview(title="Default", description="Progress bar at 33%.",
            Main.Progress(value=33, class="w-[60%]")
        ),

        # Multiple Values
        ComponentPreview(title="Values", description="Progress bars at different completion levels.",
            Div(:class => "space-y-4 w-[60%]",
                Div(:class => "space-y-1",
                    Span(:class => "text-sm text-warm-600 dark:text-warm-400", "0%"),
                    Main.Progress(value=0)
                ),
                Div(:class => "space-y-1",
                    Span(:class => "text-sm text-warm-600 dark:text-warm-400", "25%"),
                    Main.Progress(value=25)
                ),
                Div(:class => "space-y-1",
                    Span(:class => "text-sm text-warm-600 dark:text-warm-400", "50%"),
                    Main.Progress(value=50)
                ),
                Div(:class => "space-y-1",
                    Span(:class => "text-sm text-warm-600 dark:text-warm-400", "75%"),
                    Main.Progress(value=75)
                ),
                Div(:class => "space-y-1",
                    Span(:class => "text-sm text-warm-600 dark:text-warm-400", "100%"),
                    Main.Progress(value=100)
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            SectionH2("Usage"),
            Main.CodeBlock(language="julia", """using Suite

Progress(value=33)
Progress(value=75, class="w-[60%]")""")
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(
                        Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                        )
                    ),
                    Main.TableBody(
                        ApiRow("value", "Real", "0", "Progress percentage (0-100, clamped)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute")
                    )
                )
            ),

            # Accessibility
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "Accessibility"),
            P(:class => "text-sm text-warm-600 dark:text-warm-400",
                "Renders with ",
                Main.InlineCode("role=\"progressbar\""),
                " and appropriate ",
                Main.InlineCode("aria-valuenow"),
                ", ",
                Main.InlineCode("aria-valuemin"),
                ", ",
                Main.InlineCode("aria-valuemax"),
                " attributes."
            )
        )
    )
end


ProgressPage
