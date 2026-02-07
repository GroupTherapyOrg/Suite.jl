# Toolbar — Suite.jl component docs page

function ToolbarPage()
    ComponentsLayout(
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3", "Toolbar"),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A horizontal toolbar container with grouped actions and separators."
            )
        ),

        # Default
        ComponentPreview(title="Default", description="Toolbar with action groups separated by dividers.",
            Main.Toolbar(
                Main.ToolbarGroup(
                    Main.Button(size="icon", variant="ghost", "B"),
                    Main.Button(size="icon", variant="ghost", "I"),
                    Main.Button(size="icon", variant="ghost", "U"),
                ),
                Main.ToolbarSeparator(),
                Main.ToolbarGroup(
                    Main.Button(size="icon", variant="ghost", "⌗"),
                    Main.Button(size="icon", variant="ghost", "•"),
                ),
            )
        ),

        # Single Group
        ComponentPreview(title="Single Group", description="Toolbar with one group of actions.",
            Main.Toolbar(
                Main.ToolbarGroup(
                    Main.Button(size="sm", variant="ghost", "Cut"),
                    Main.Button(size="sm", variant="ghost", "Copy"),
                    Main.Button(size="sm", variant="ghost", "Paste"),
                ),
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4", "Usage"),
            Div(:class => "bg-warm-800 dark:bg-warm-950 rounded-md border border-warm-700 p-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-50",
                    Code(:class => "language-julia", """using Suite

Toolbar(
    ToolbarGroup(
        Button(size="icon", variant="ghost", "B"),
        Button(size="icon", variant="ghost", "I"),
    ),
    ToolbarSeparator(),
    ToolbarGroup(
        Button(size="icon", variant="ghost", "⌗"),
    ),
)""")
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4", "API Reference"),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "Toolbar"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                    )),
                    Tbody(
                        ApiRow("children", "Any", "-", "ToolbarGroup and ToolbarSeparator elements"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("theme", "Symbol", ":default", "Theme preset"),
                    )
                )
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "Sub-components"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Component"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description"),
                    )),
                    Tbody(
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs text-accent-600 dark:text-accent-400", "ToolbarGroup"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Groups related toolbar items with role=\"group\""),
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs text-accent-600 dark:text-accent-400", "ToolbarSeparator"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Vertical divider between groups"),
                        ),
                    )
                )
            ),
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

ToolbarPage
