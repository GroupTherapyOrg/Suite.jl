# Table — Suite.jl component docs page
#
# Showcases Table with all sub-components.

const Table = Main.Table
const TableHeader = Main.TableHeader
const TableBody = Main.TableBody
const TableFooter = Main.TableFooter
const TableRow = Main.TableRow
const TableHead = Main.TableHead
const TableCell = Main.TableCell
const TableCaption = Main.TableCaption

function TablePage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Table"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A responsive table component."
            )
        ),

        # Default Preview
        ComponentPreview(title="Default", description="A table with header, body, footer, and caption.",
            Table(
                TableCaption("A list of your recent invoices."),
                TableHeader(
                    TableRow(
                        TableHead("Invoice"),
                        TableHead("Status"),
                        TableHead("Method"),
                        TableHead(class="text-right", "Amount")
                    )
                ),
                TableBody(
                    TableRow(
                        TableCell(class="font-medium", "INV001"),
                        TableCell("Paid"),
                        TableCell("Credit Card"),
                        TableCell(class="text-right", "\$250.00")
                    ),
                    TableRow(
                        TableCell(class="font-medium", "INV002"),
                        TableCell("Pending"),
                        TableCell("PayPal"),
                        TableCell(class="text-right", "\$150.00")
                    ),
                    TableRow(
                        TableCell(class="font-medium", "INV003"),
                        TableCell("Unpaid"),
                        TableCell("Bank Transfer"),
                        TableCell(class="text-right", "\$350.00")
                    ),
                    TableRow(
                        TableCell(class="font-medium", "INV004"),
                        TableCell("Paid"),
                        TableCell("Credit Card"),
                        TableCell(class="text-right", "\$450.00")
                    )
                ),
                TableFooter(
                    TableRow(
                        TableCell(:colspan => "3", "Total"),
                        TableCell(class="text-right", "\$1,200.00")
                    )
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

Table(
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
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "API Reference"
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "Components"),
            P(:class => "text-sm text-warm-600 dark:text-warm-400 mb-4",
                "All table sub-components (",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "TableHeader"),
                ", ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "TableBody"),
                ", ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "TableFooter"),
                ", ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "TableRow"),
                ", ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "TableHead"),
                ", ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "TableCell"),
                ", ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "TableCaption"),
                ") accept ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "class"),
                ", ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "children..."),
                ", and ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "kwargs..."),
                "."
            ),

            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(
                        Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Component"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "HTML Element"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                        )
                    ),
                    Tbody(
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Table"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "div > table"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Scrollable table container")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "TableHeader"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "thead"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Table header section")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "TableBody"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "tbody"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Table body section")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "TableFooter"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "tfoot"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Table footer section")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "TableRow"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "tr"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Table row with hover state")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "TableHead"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "th"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Header cell")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "TableCell"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "td"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Data cell")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "TableCaption"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "caption"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Table caption text")
                        )
                    )
                )
            )
        )
    )
end

TablePage
