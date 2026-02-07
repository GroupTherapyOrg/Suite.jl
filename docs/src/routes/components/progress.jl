# Progress — Suite.jl component docs page
#
# Showcases Progress bar with different values.


function ProgressPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3",
                "Progress"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "Displays an indicator showing the completion progress of a task."
            )
        ),

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
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "Usage"
            ),
            Main.CodeBlock(language="julia", """using Suite

Progress(value=33)
Progress(value=75, class="w-[60%]")""")
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "API Reference"
            ),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(
                        Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                        )
                    ),
                    Tbody(
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
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "role=\"progressbar\""),
                " and appropriate ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "aria-valuenow"),
                ", ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "aria-valuemin"),
                ", ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "aria-valuemax"),
                " attributes."
            )
        )
    )
end

function ApiRow(prop, type, default, description)
    Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
        Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", prop),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", type),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", default),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", description)
    )
end

ProgressPage
