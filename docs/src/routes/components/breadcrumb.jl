# Breadcrumb — Suite.jl component docs page
#
# Showcases SuiteBreadcrumb navigation trail.

const SuiteBreadcrumb = Main.SuiteBreadcrumb
const SuiteBreadcrumbList = Main.SuiteBreadcrumbList
const SuiteBreadcrumbItem = Main.SuiteBreadcrumbItem
const SuiteBreadcrumbLink = Main.SuiteBreadcrumbLink
const SuiteBreadcrumbPage = Main.SuiteBreadcrumbPage
const SuiteBreadcrumbSeparator = Main.SuiteBreadcrumbSeparator
const SuiteBreadcrumbEllipsis = Main.SuiteBreadcrumbEllipsis

function BreadcrumbPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Breadcrumb"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "Displays the path to the current resource using a hierarchy of links."
            )
        ),

        # Default Preview
        ComponentPreview(title="Default", description="A basic breadcrumb trail.",
            SuiteBreadcrumb(
                SuiteBreadcrumbList(
                    SuiteBreadcrumbItem(SuiteBreadcrumbLink("Home", href="#")),
                    SuiteBreadcrumbSeparator(),
                    SuiteBreadcrumbItem(SuiteBreadcrumbLink("Components", href="#")),
                    SuiteBreadcrumbSeparator(),
                    SuiteBreadcrumbItem(SuiteBreadcrumbPage("Breadcrumb"))
                )
            )
        ),

        # With Ellipsis
        ComponentPreview(title="With Ellipsis", description="Breadcrumb with collapsed items.",
            SuiteBreadcrumb(
                SuiteBreadcrumbList(
                    SuiteBreadcrumbItem(SuiteBreadcrumbLink("Home", href="#")),
                    SuiteBreadcrumbSeparator(),
                    SuiteBreadcrumbItem(SuiteBreadcrumbEllipsis()),
                    SuiteBreadcrumbSeparator(),
                    SuiteBreadcrumbItem(SuiteBreadcrumbLink("Components", href="#")),
                    SuiteBreadcrumbSeparator(),
                    SuiteBreadcrumbItem(SuiteBreadcrumbPage("Breadcrumb"))
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "Usage"
            ),
            Div(:class => "bg-warm-800 dark:bg-warm-950 rounded-md border border-warm-700 p-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-50",
                    Code(:class => "language-julia", """using Suite

SuiteBreadcrumb(
    SuiteBreadcrumbList(
        SuiteBreadcrumbItem(SuiteBreadcrumbLink("Home", href="/")),
        SuiteBreadcrumbSeparator(),
        SuiteBreadcrumbItem(SuiteBreadcrumbLink("Components", href="/components")),
        SuiteBreadcrumbSeparator(),
        SuiteBreadcrumbItem(SuiteBreadcrumbPage("Breadcrumb")),
    ),
)""")
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "API Reference"
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "SuiteBreadcrumbLink"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(
                        Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                        )
                    ),
                    Tbody(
                        ApiRow("href", "String", "\"#\"", "Link URL"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("children...", "Any", "-", "Link text"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute")
                    )
                )
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "Sub-components"),
            P(:class => "text-sm text-warm-600 dark:text-warm-400 mb-4",
                "SuiteBreadcrumb, SuiteBreadcrumbList, SuiteBreadcrumbItem, SuiteBreadcrumbPage, SuiteBreadcrumbSeparator, and SuiteBreadcrumbEllipsis all accept ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "class"),
                " and ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "kwargs..."),
                "."
            ),

            # Accessibility
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "Accessibility"),
            P(:class => "text-sm text-warm-600 dark:text-warm-400",
                "Uses semantic ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "nav"),
                " element with ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "aria-label=\"breadcrumb\""),
                ". Current page marked with ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "aria-current=\"page\""),
                "."
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

BreadcrumbPage
