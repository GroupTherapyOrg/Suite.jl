# StatusBar — Suite.jl component docs page

function StatusBarPage()
    ComponentsLayout(
        PageHeader("Status Bar", "An IDE-style horizontal status bar for displaying contextual information."),

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
        UsageBlock("""using Suite

StatusBar(
    StatusBarSection(position="left",
        StatusBarItem("Ready"),
        StatusBarItem("UTF-8"),
    ),
    StatusBarSection(position="right",
        StatusBarItem("Ln 42, Col 8"),
        StatusBarItem("Julia 1.12", clickable=true),
    ),
)"""),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),

            SectionH3("StatusBar"),
            Div(:class => "overflow-x-auto",
                Main.Table(
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children", "Any", "-", "StatusBarSection elements"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),

            SectionH3("StatusBarSection"),
            Div(:class => "overflow-x-auto",
                Main.Table(
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("position", "String", "\"left\"", "Alignment: \"left\", \"center\", or \"right\""),
                        ApiRow("children", "Any", "-", "StatusBarItem elements"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),

            SectionH3("StatusBarItem"),
            Div(:class => "overflow-x-auto",
                Main.Table(
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children", "Any", "-", "Item content"),
                        ApiRow("clickable", "Bool", "false", "Whether item shows hover interactions"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
        )
    )
end


StatusBarPage
