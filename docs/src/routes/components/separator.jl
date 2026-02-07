# Separator — Suite.jl component docs page
#
# Showcases Separator with horizontal/vertical orientations.


function SeparatorPage()
    ComponentsLayout(
        # Header
        PageHeader("Separator", "Visually or semantically separates content."),

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
        UsageBlock("""using Suite

Separator()
Separator(orientation="vertical")
Separator(decorative=false)"""),

        # API Reference
        ApiTable(
            ApiRow("orientation", "String", "\"horizontal\"", "horizontal | vertical"),
            ApiRow("decorative", "Bool", "true", "If true, hidden from accessibility tree"),
            ApiRow("class", "String", "\"\"", "Additional CSS classes"),
            ApiRow("kwargs...", "Pair", "-", "Any HTML attribute"),
        )
    )
end


SeparatorPage
