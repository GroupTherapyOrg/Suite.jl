# Kbd — Suite.jl component docs page

function KbdPage()
    ComponentsLayout(
        # Header
        PageHeader("Kbd", "Displays keyboard shortcut keys as styled indicators."),

        # Default Preview
        ComponentPreview(title="Default", description="Single keyboard keys.",
            Div(:class => "flex items-center gap-2",
                Main.Kbd("Ctrl"),
                Main.Kbd("⌘"),
                Main.Kbd("Shift"),
                Main.Kbd("Enter"),
                Main.Kbd("Esc"),
            )
        ),

        # Composition
        ComponentPreview(title="Shortcut Composition", description="Combine keys to show shortcuts.",
            Div(:class => "space-y-3",
                Div(:class => "flex items-center gap-1",
                    Main.Kbd("Ctrl"), Span(:class => "text-warm-500 dark:text-warm-400 text-xs", "+"), Main.Kbd("C"),
                    Span(:class => "ml-3 text-sm text-warm-600 dark:text-warm-400", "Copy")
                ),
                Div(:class => "flex items-center gap-1",
                    Main.Kbd("⌘"), Span(:class => "text-warm-500 dark:text-warm-400 text-xs", "+"), Main.Kbd("K"),
                    Span(:class => "ml-3 text-sm text-warm-600 dark:text-warm-400", "Command palette")
                ),
                Div(:class => "flex items-center gap-1",
                    Main.Kbd("Ctrl"), Span(:class => "text-warm-500 dark:text-warm-400 text-xs", "+"), Main.Kbd("Shift"), Span(:class => "text-warm-500 dark:text-warm-400 text-xs", "+"), Main.Kbd("P"),
                    Span(:class => "ml-3 text-sm text-warm-600 dark:text-warm-400", "Quick open")
                ),
            )
        ),

        # Usage
        UsageBlock("""using Suite

# Single key
Kbd("Ctrl")

# Shortcut composition
Div(Kbd("Ctrl"), " + ", Kbd("Enter"))

# With description
Div(Kbd("⌘"), Kbd("K"), Span(" — Command palette"))"""),

        # API Reference
        ApiTable(
            ApiRow("children", "Any", "-", "Key text to display"),
            ApiRow("class", "String", "\"\"", "Additional CSS classes"),
            ApiRow("theme", "Symbol", ":default", "Theme preset"),
        )
    )
end


KbdPage
