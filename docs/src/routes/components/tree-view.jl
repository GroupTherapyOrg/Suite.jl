# TreeView — Suite.jl component docs page

function TreeViewPage()
    ComponentsLayout(
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3", "Tree View"),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A hierarchical tree component for displaying nested data like file browsers."
            )
        ),

        # Default
        ComponentPreview(title="File Browser", description="Tree view with folders and files.",
            Div(:class => "w-64",
                Main.TreeView(
                    Main.TreeViewItem(label="src", is_folder=true, expanded=true,
                        Main.TreeViewItem(label="components", is_folder=true,
                            Main.TreeViewItem(label="Button.jl"),
                            Main.TreeViewItem(label="Card.jl"),
                        ),
                        Main.TreeViewItem(label="Suite.jl"),
                        Main.TreeViewItem(label="utils.jl"),
                    ),
                    Main.TreeViewItem(label="test", is_folder=true,
                        Main.TreeViewItem(label="runtests.jl"),
                    ),
                    Main.TreeViewItem(label="Project.toml"),
                    Main.TreeViewItem(label="README.md"),
                )
            )
        ),

        # Selected
        ComponentPreview(title="With Selection", description="Tree view with a selected item.",
            Div(:class => "w-64",
                Main.TreeView(
                    Main.TreeViewItem(label="docs", is_folder=true, expanded=true,
                        Main.TreeViewItem(label="app.jl", selected=true),
                        Main.TreeViewItem(label="input.css"),
                    ),
                    Main.TreeViewItem(label="src", is_folder=true,
                        Main.TreeViewItem(label="main.jl"),
                    ),
                )
            )
        ),

        # Keyboard
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4", "Keyboard Interactions"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Key"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Action")
                    )),
                    Tbody(
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs", "↓ / ↑"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Move between visible items"),
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs", "→"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Expand folder / move to first child"),
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs", "←"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Collapse folder / move to parent"),
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs", "Enter / Space"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Select item / toggle folder"),
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs", "Home / End"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Jump to first / last visible item"),
                        ),
                    )
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4", "Usage"),
            Div(:class => "bg-warm-800 dark:bg-warm-950 rounded-md border border-warm-700 p-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-50",
                    Code(:class => "language-julia", """using Suite

TreeView(
    TreeViewItem(label="src", is_folder=true, expanded=true,
        TreeViewItem(label="main.jl"),
        TreeViewItem(label="utils.jl"),
    ),
    TreeViewItem(label="Project.toml"),
)""")
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4", "API Reference"),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-50 mt-6 mb-3", "TreeView"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                    )),
                    Tbody(
                        ApiRow("children", "Any", "-", "TreeViewItem elements"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-50 mt-6 mb-3", "TreeViewItem"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                    )),
                    Tbody(
                        ApiRow("label", "String", "\"\"", "Display text"),
                        ApiRow("is_folder", "Bool", "auto", "Whether this is a folder (auto-detected from children)"),
                        ApiRow("expanded", "Bool", "false", "Whether folder is initially expanded"),
                        ApiRow("selected", "Bool", "false", "Whether item is selected"),
                        ApiRow("disabled", "Bool", "false", "Whether item is disabled"),
                        ApiRow("icon", "Any", "nothing", "Custom icon (overrides default file/folder icon)"),
                        ApiRow("depth", "Int", "0", "Nesting depth for indentation"),
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

TreeViewPage
