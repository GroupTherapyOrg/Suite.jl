# Pagination — Suite.jl component docs page
#
# Showcases SuitePagination navigation bar.

const SuitePagination = Main.SuitePagination
const SuitePaginationContent = Main.SuitePaginationContent
const SuitePaginationItem = Main.SuitePaginationItem
const SuitePaginationLink = Main.SuitePaginationLink
const SuitePaginationPrevious = Main.SuitePaginationPrevious
const SuitePaginationNext = Main.SuitePaginationNext
const SuitePaginationEllipsis = Main.SuitePaginationEllipsis

function PaginationPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Pagination"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "Pagination with page navigation, next and previous links."
            )
        ),

        # Default Preview
        ComponentPreview(title="Default", description="A pagination bar with previous, next, and page links.",
            SuitePagination(
                SuitePaginationContent(
                    SuitePaginationItem(SuitePaginationPrevious(href="#")),
                    SuitePaginationItem(SuitePaginationLink("1", href="#", is_active=true)),
                    SuitePaginationItem(SuitePaginationLink("2", href="#")),
                    SuitePaginationItem(SuitePaginationLink("3", href="#")),
                    SuitePaginationItem(SuitePaginationEllipsis()),
                    SuitePaginationItem(SuitePaginationNext(href="#"))
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

SuitePagination(
    SuitePaginationContent(
        SuitePaginationItem(SuitePaginationPrevious(href="/page/1")),
        SuitePaginationItem(SuitePaginationLink("1", href="/page/1", is_active=true)),
        SuitePaginationItem(SuitePaginationLink("2", href="/page/2")),
        SuitePaginationItem(SuitePaginationLink("3", href="/page/3")),
        SuitePaginationItem(SuitePaginationEllipsis()),
        SuitePaginationItem(SuitePaginationNext(href="/page/2")),
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

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "SuitePaginationLink"),
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
                        ApiRow("is_active", "Bool", "false", "Whether this is the current page"),
                        ApiRow("size", "String", "\"icon\"", "icon | default"),
                        ApiRow("href", "String", "\"#\"", "Link URL"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("children...", "Any", "-", "Page number text"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute")
                    )
                )
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "SuitePaginationPrevious / SuitePaginationNext"),
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
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute")
                    )
                )
            ),

            # Accessibility
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "Accessibility"),
            P(:class => "text-sm text-warm-600 dark:text-warm-400",
                "Uses ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "nav"),
                " with ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "role=\"navigation\""),
                " and ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "aria-label=\"pagination\""),
                ". Active page gets ",
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

PaginationPage
