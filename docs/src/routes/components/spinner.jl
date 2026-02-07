# Spinner — Suite.jl component docs page

function SpinnerPage()
    ComponentsLayout(
        PageHeader("Spinner", "An animated loading spinner indicator."),

        # Sizes
        ComponentPreview(title="Sizes", description="Three sizes: sm, default, and lg.",
            Div(:class => "flex items-center gap-6",
                Div(:class => "flex flex-col items-center gap-2",
                    Main.Spinner(size="sm"),
                    Span(:class => "text-xs text-warm-500 dark:text-warm-400", "sm"),
                ),
                Div(:class => "flex flex-col items-center gap-2",
                    Main.Spinner(),
                    Span(:class => "text-xs text-warm-500 dark:text-warm-400", "default"),
                ),
                Div(:class => "flex flex-col items-center gap-2",
                    Main.Spinner(size="lg"),
                    Span(:class => "text-xs text-warm-500 dark:text-warm-400", "lg"),
                ),
            )
        ),

        # Custom color
        ComponentPreview(title="Custom Color", description="Override color with custom classes.",
            Div(:class => "flex items-center gap-6",
                Main.Spinner(class="text-accent-secondary-600"),
                Main.Spinner(class="text-blue-500"),
                Main.Spinner(class="text-green-500"),
            )
        ),

        # Usage
        UsageBlock("""using Suite

Spinner()
Spinner(size="sm")
Spinner(size="lg")
Spinner(class="text-red-500")"""),

        # API Reference
        ApiTable(
            ApiRow("size", "String", "\"default\"", "Spinner size: \"sm\", \"default\", or \"lg\""),
            ApiRow("class", "String", "\"\"", "Additional CSS classes"),
            ApiRow("theme", "Symbol", ":default", "Theme preset"),
        )
    )
end


SpinnerPage
