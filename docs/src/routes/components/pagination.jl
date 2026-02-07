# Pagination — Suite.jl component docs page
#
# Showcases Pagination navigation bar.


function PaginationPage()
    ComponentsLayout(
        # Header
        PageHeader("Pagination", "Pagination with page navigation, next and previous links."),

        # Default Preview
        ComponentPreview(title="Default", description="A pagination bar with previous, next, and page links.",
            Main.Pagination(
                Main.PaginationContent(
                    Main.PaginationItem(Main.PaginationPrevious(href="#")),
                    Main.PaginationItem(Main.PaginationLink("1", href="#", is_active=true)),
                    Main.PaginationItem(Main.PaginationLink("2", href="#")),
                    Main.PaginationItem(Main.PaginationLink("3", href="#")),
                    Main.PaginationItem(Main.PaginationEllipsis()),
                    Main.PaginationItem(Main.PaginationNext(href="#"))
                )
            )
        ),

        # Usage
        UsageBlock("""using Suite

Pagination(
    PaginationContent(
        PaginationItem(PaginationPrevious(href="/page/1")),
        PaginationItem(PaginationLink("1", href="/page/1", is_active=true)),
        PaginationItem(PaginationLink("2", href="/page/2")),
        PaginationItem(PaginationLink("3", href="/page/3")),
        PaginationItem(PaginationEllipsis()),
        PaginationItem(PaginationNext(href="/page/2")),
    ),
)"""),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),

            SectionH3("PaginationLink"),
            Div(:class => "overflow-x-auto",
                Main.Table(
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("is_active", "Bool", "false", "Whether this is the current page"),
                        ApiRow("size", "String", "\"icon\"", "icon | default"),
                        ApiRow("href", "String", "\"#\"", "Link URL"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("children...", "Any", "-", "Page number text"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute")
                    )
                )
            ),

            SectionH3("PaginationPrevious / PaginationNext"),
            Div(:class => "overflow-x-auto",
                Main.Table(
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("href", "String", "\"#\"", "Link URL"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute")
                    )
                )
            ),

            # Accessibility
            SectionH3("Accessibility"),
            P(:class => "text-sm text-warm-600 dark:text-warm-400",
                "Uses ",
                Main.InlineCode("nav"),
                " with ",
                Main.InlineCode("role=\"navigation\""),
                " and ",
                Main.InlineCode("aria-label=\"pagination\""),
                ". Active page gets ",
                Main.InlineCode("aria-current=\"page\""),
                "."
            )
        )
    )
end


PaginationPage
