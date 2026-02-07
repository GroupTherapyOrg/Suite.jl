# Separator — Suite.jl component docs page
#
# Showcases Separator with horizontal/vertical orientations.


function SeparatorPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3",
                "Separator"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "Visually or semantically separates content."
            )
        ),

        # Default Preview
        ComponentPreview(title="Horizontal", description="A horizontal separator dividing content.",
            Div(:class => "w-full max-w-sm space-y-4",
                Div(
                    H4(:class => "text-sm font-medium leading-none text-warm-800 dark:text-warm-300", "Suite.jl"),
                    P(:class => "text-sm text-warm-600 dark:text-warm-400 mt-1", "A component library for Julia.")
                ),
                Main.Separator(),
                Div(:class => "flex h-5 items-center space-x-4 text-sm",
                    Span(:class => "text-warm-800 dark:text-warm-300", "Blog"),
                    Main.Separator(orientation="vertical"),
                    Span(:class => "text-warm-800 dark:text-warm-300", "Docs"),
                    Main.Separator(orientation="vertical"),
                    Span(:class => "text-warm-800 dark:text-warm-300", "Source")
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "Usage"
            ),
            Main.CodeBlock(language="julia", """using Suite

Separator()
Separator(orientation="vertical")
Separator(decorative=false)""")
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
                        ApiRow("orientation", "String", "\"horizontal\"", "horizontal | vertical"),
                        ApiRow("decorative", "Bool", "true", "If true, hidden from accessibility tree"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute")
                    )
                )
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

SeparatorPage
