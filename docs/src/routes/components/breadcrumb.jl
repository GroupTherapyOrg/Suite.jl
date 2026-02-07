# Breadcrumb — Suite.jl component docs page
#
# Showcases Breadcrumb navigation trail.


function BreadcrumbDocsPage()
    ComponentsLayout(
        # Header
        PageHeader("Breadcrumb", "Displays the path to the current resource using a hierarchy of links."),

        # Default Preview
        ComponentPreview(title="Default", description="A basic breadcrumb trail.",
            Main.Breadcrumb(
                Main.BreadcrumbList(
                    Main.BreadcrumbItem(Main.BreadcrumbLink("Home", href="#")),
                    Main.BreadcrumbSeparator(),
                    Main.BreadcrumbItem(Main.BreadcrumbLink("Components", href="#")),
                    Main.BreadcrumbSeparator(),
                    Main.BreadcrumbItem(Main.BreadcrumbPage("Breadcrumb"))
                )
            )
        ),

        # With Ellipsis
        ComponentPreview(title="With Ellipsis", description="Breadcrumb with collapsed items.",
            Main.Breadcrumb(
                Main.BreadcrumbList(
                    Main.BreadcrumbItem(Main.BreadcrumbLink("Home", href="#")),
                    Main.BreadcrumbSeparator(),
                    Main.BreadcrumbItem(Main.BreadcrumbEllipsis()),
                    Main.BreadcrumbSeparator(),
                    Main.BreadcrumbItem(Main.BreadcrumbLink("Components", href="#")),
                    Main.BreadcrumbSeparator(),
                    Main.BreadcrumbItem(Main.BreadcrumbPage("Breadcrumb"))
                )
            )
        ),

        # Usage
        UsageBlock("""using Suite

Breadcrumb(
    BreadcrumbList(
        BreadcrumbItem(BreadcrumbLink("Home", href="/")),
        BreadcrumbSeparator(),
        BreadcrumbItem(BreadcrumbLink("Components", href="/components")),
        BreadcrumbSeparator(),
        BreadcrumbItem(BreadcrumbPage("Breadcrumb")),
    ),
)"""),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),

            SectionH3("BreadcrumbLink"),
            Div(:class => "overflow-x-auto",
                Main.Table(
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("href", "String", "\"#\"", "Link URL"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("children...", "Any", "-", "Link text"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute")
                    )
                )
            ),

            SectionH3("Sub-components"),
            P(:class => "text-sm text-warm-600 dark:text-warm-400 mb-4",
                "Breadcrumb, BreadcrumbList, BreadcrumbItem, BreadcrumbPage, BreadcrumbSeparator, and BreadcrumbEllipsis all accept ",
                Main.InlineCode("class"),
                " and ",
                Main.InlineCode("kwargs..."),
                "."
            ),

            # Accessibility
            SectionH3("Accessibility"),
            P(:class => "text-sm text-warm-600 dark:text-warm-400",
                "Uses semantic ",
                Main.InlineCode("nav"),
                " element with ",
                Main.InlineCode("aria-label=\"breadcrumb\""),
                ". Current page marked with ",
                Main.InlineCode("aria-current=\"page\""),
                "."
            )
        )
    )
end


BreadcrumbDocsPage
