# Kbd — Suite.jl component docs page

function KbdPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3",
                "Kbd"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "Displays keyboard shortcut keys as styled indicators."
            )
        ),

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
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4", "Usage"),
            Div(:class => "bg-warm-800 dark:bg-warm-950 rounded-md border border-warm-700 p-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-50",
                    Code(:class => "language-julia", """using Suite

# Single key
Kbd("Ctrl")

# Shortcut composition
Div(Kbd("Ctrl"), " + ", Kbd("Enter"))

# With description
Div(Kbd("⌘"), Kbd("K"), Span(" — Command palette"))""")
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4", "API Reference"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                    )),
                    Tbody(
                        ApiRow("children", "Any", "-", "Key text to display"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("theme", "Symbol", ":default", "Theme preset"),
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

KbdPage
