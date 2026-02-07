# TreeView — Suite.jl component docs page

function TreeViewPage()
    ComponentsLayout(
        PageHeader("Tree View", "A hierarchical tree component for displaying nested data like file browsers."),

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
        KeyboardTable(
            KeyRow("↓ / ↑", "Move between visible items"),
            KeyRow("→", "Expand folder / move to first child"),
            KeyRow("←", "Collapse folder / move to parent"),
            KeyRow("Enter / Space", "Select item / toggle folder"),
            KeyRow("Home / End", "Jump to first / last visible item"),
        ),

        # Usage
        UsageBlock("""using Suite

TreeView(
    TreeViewItem(label="src", is_folder=true, expanded=true,
        TreeViewItem(label="main.jl"),
        TreeViewItem(label="utils.jl"),
    ),
    TreeViewItem(label="Project.toml"),
)"""),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),

            SectionH3("TreeView"),
            Div(:class => "overflow-x-auto",
                Main.Table(
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children", "Any", "-", "TreeViewItem elements"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),

            SectionH3("TreeViewItem"),
            Div(:class => "overflow-x-auto",
                Main.Table(
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
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


TreeViewPage
