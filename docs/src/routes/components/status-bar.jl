# StatusBar — Suite.jl component docs page

function StatusBarPage()
    ComponentsLayout(
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3", "Status Bar"),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "An IDE-style horizontal status bar for displaying contextual information."
            )
        ),

        # Default
        ComponentPreview(title="Default", description="Status bar with left and right sections.",
            Div(:class => "w-full border border-warm-200 dark:border-warm-700 rounded-lg overflow-hidden",
                Main.StatusBar(
                    Main.StatusBarSection(position="left",
                        Main.StatusBarItem("Ready"),
                        Main.StatusBarItem("UTF-8"),
                    ),
                    Main.StatusBarSection(position="right",
                        Main.StatusBarItem("Ln 42, Col 8"),
                        Main.StatusBarItem("Julia 1.12"),
                    ),
                )
            )
        ),

        # Clickable Items
        ComponentPreview(title="Clickable Items", description="Status bar items that respond to hover.",
            Div(:class => "w-full border border-warm-200 dark:border-warm-700 rounded-lg overflow-hidden",
                Main.StatusBar(
                    Main.StatusBarSection(position="left",
                        Main.StatusBarItem("main", clickable=true),
                        Main.StatusBarItem("3 errors", clickable=true),
                    ),
                    Main.StatusBarSection(position="right",
                        Main.StatusBarItem("Spaces: 4", clickable=true),
                        Main.StatusBarItem("LF", clickable=true),
                    ),
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4", "Usage"),
            Div(:class => "bg-warm-800 dark:bg-warm-950 rounded-md border border-warm-700 p-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-50",
                    Code(:class => "language-julia", """using Suite

StatusBar(
    StatusBarSection(position="left",
        StatusBarItem("Ready"),
        StatusBarItem("UTF-8"),
    ),
    StatusBarSection(position="right",
        StatusBarItem("Ln 42, Col 8"),
        StatusBarItem("Julia 1.12", clickable=true),
    ),
)""")
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4", "API Reference"),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "StatusBar"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                    )),
                    Tbody(
                        ApiRow("children", "Any", "-", "StatusBarSection elements"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "StatusBarSection"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                    )),
                    Tbody(
                        ApiRow("position", "String", "\"left\"", "Alignment: \"left\", \"center\", or \"right\""),
                        ApiRow("children", "Any", "-", "StatusBarItem elements"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "StatusBarItem"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                    )),
                    Tbody(
                        ApiRow("children", "Any", "-", "Item content"),
                        ApiRow("clickable", "Bool", "false", "Whether item shows hover interactions"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
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

StatusBarPage
