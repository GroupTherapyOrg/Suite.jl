# Toolbar — Suite.jl component docs page

function ToolbarPage()
    ComponentsLayout(
        PageHeader("Toolbar", "A horizontal toolbar container with grouped actions and separators."),

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
        UsageBlock("""using Suite

Toolbar(
    ToolbarGroup(
        Button(size="icon", variant="ghost", "B"),
        Button(size="icon", variant="ghost", "I"),
    ),
    ToolbarSeparator(),
    ToolbarGroup(
        Button(size="icon", variant="ghost", "⌗"),
    ),
)"""),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),

            SectionH3("Toolbar"),
            Div(:class => "overflow-x-auto",
                Main.Table(
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children", "Any", "-", "ToolbarGroup and ToolbarSeparator elements"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("theme", "Symbol", ":default", "Theme preset"),
                    )
                )
            ),

            SectionH3("Sub-components"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Component"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description"),
                    )),
                    Main.TableBody(
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 font-mono text-xs text-accent-600 dark:text-accent-400", "ToolbarGroup"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Groups related toolbar items with role=\"group\""),
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 font-mono text-xs text-accent-600 dark:text-accent-400", "ToolbarSeparator"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Vertical divider between groups"),
                        ),
                    )
                )
            ),
        )
    )
end


ToolbarPage
