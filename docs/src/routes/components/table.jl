# Table — Suite.jl component docs page
#
# Showcases Table with all sub-components.


function TablePage()
    ComponentsLayout(
        # Header
        PageHeader("Table", "A responsive table component."),

        # Default Preview
        ComponentPreview(title="Default", description="A table with header, body, footer, and caption.",
            Main.Table(
                Main.TableCaption("A list of your recent invoices."),
                Main.TableHeader(
                    Main.TableRow(
                        Main.TableHead("Invoice"),
                        Main.TableHead("Status"),
                        Main.TableHead("Method"),
                        Main.TableHead(class="text-right", "Amount")
                    )
                ),
                Main.TableBody(
                    Main.TableRow(
                        Main.TableCell(class="font-medium", "INV001"),
                        Main.TableCell("Paid"),
                        Main.TableCell("Credit Card"),
                        Main.TableCell(class="text-right", "\$250.00")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium", "INV002"),
                        Main.TableCell("Pending"),
                        Main.TableCell("PayPal"),
                        Main.TableCell(class="text-right", "\$150.00")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium", "INV003"),
                        Main.TableCell("Unpaid"),
                        Main.TableCell("Bank Transfer"),
                        Main.TableCell(class="text-right", "\$350.00")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium", "INV004"),
                        Main.TableCell("Paid"),
                        Main.TableCell("Credit Card"),
                        Main.TableCell(class="text-right", "\$450.00")
                    )
                ),
                Main.TableFooter(
                    Main.TableRow(
                        Main.TableCell(:colspan => "3", "Total"),
                        Main.TableCell(class="text-right", "\$1,200.00")
                    )
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            SectionH2("Usage"),
            Main.CodeBlock(language="julia", """using Suite

Main.Table(
    TableHeader(
        TableRow(
            TableHead("Name"),
            TableHead("Email"),
        ),
    ),
    TableBody(
        TableRow(
            TableCell("Alice"),
            TableCell("alice@example.com"),
        ),
    ),
)""")
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "Components"),
            P(:class => "text-sm text-warm-600 dark:text-warm-400 mb-4",
                "All table sub-components (",
                Main.InlineCode("TableHeader"),
                ", ",
                Main.InlineCode("TableBody"),
                ", ",
                Main.InlineCode("TableFooter"),
                ", ",
                Main.InlineCode("TableRow"),
                ", ",
                Main.InlineCode("TableHead"),
                ", ",
                Main.InlineCode("TableCell"),
                ", ",
                Main.InlineCode("TableCaption"),
                ") accept ",
                Main.InlineCode("class"),
                ", ",
                Main.InlineCode("children..."),
                ", and ",
                Main.InlineCode("kwargs..."),
                "."
            ),

            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(
                        Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Component"),
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "HTML Element"),
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                        )
                    ),
                    Main.TableBody(
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Table"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "div > table"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Scrollable table container")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "TableHeader"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "thead"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Table header section")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "TableBody"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "tbody"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Table body section")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "TableFooter"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "tfoot"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Table footer section")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "TableRow"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "tr"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Table row with hover state")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "TableHead"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "th"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Header cell")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "TableCell"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "td"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Data cell")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "TableCaption"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "caption"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Table caption text")
                        )
                    )
                )
            )
        )
    )
end

TablePage
