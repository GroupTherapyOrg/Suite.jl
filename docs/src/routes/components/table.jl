# Table — Suite.jl component docs page
#
# Showcases SuiteTable with all sub-components.

const SuiteTable = Main.SuiteTable
const SuiteTableHeader = Main.SuiteTableHeader
const SuiteTableBody = Main.SuiteTableBody
const SuiteTableFooter = Main.SuiteTableFooter
const SuiteTableRow = Main.SuiteTableRow
const SuiteTableHead = Main.SuiteTableHead
const SuiteTableCell = Main.SuiteTableCell
const SuiteTableCaption = Main.SuiteTableCaption

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
            SuiteTable(
                SuiteTableCaption("A list of your recent invoices."),
                SuiteTableHeader(
                    SuiteTableRow(
                        SuiteTableHead("Invoice"),
                        SuiteTableHead("Status"),
                        SuiteTableHead("Method"),
                        SuiteTableHead(class="text-right", "Amount")
                    )
                ),
                SuiteTableBody(
                    SuiteTableRow(
                        SuiteTableCell(class="font-medium", "INV001"),
                        SuiteTableCell("Paid"),
                        SuiteTableCell("Credit Card"),
                        SuiteTableCell(class="text-right", "\$250.00")
                    ),
                    SuiteTableRow(
                        SuiteTableCell(class="font-medium", "INV002"),
                        SuiteTableCell("Pending"),
                        SuiteTableCell("PayPal"),
                        SuiteTableCell(class="text-right", "\$150.00")
                    ),
                    SuiteTableRow(
                        SuiteTableCell(class="font-medium", "INV003"),
                        SuiteTableCell("Unpaid"),
                        SuiteTableCell("Bank Transfer"),
                        SuiteTableCell(class="text-right", "\$350.00")
                    ),
                    SuiteTableRow(
                        SuiteTableCell(class="font-medium", "INV004"),
                        SuiteTableCell("Paid"),
                        SuiteTableCell("Credit Card"),
                        SuiteTableCell(class="text-right", "\$450.00")
                    )
                ),
                SuiteTableFooter(
                    SuiteTableRow(
                        SuiteTableCell(:colspan => "3", "Total"),
                        SuiteTableCell(class="text-right", "\$1,200.00")
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

SuiteTable(
    SuiteTableHeader(
        SuiteTableRow(
            SuiteTableHead("Name"),
            SuiteTableHead("Email"),
        ),
    ),
    SuiteTableBody(
        SuiteTableRow(
            SuiteTableCell("Alice"),
            SuiteTableCell("alice@example.com"),
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
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "SuiteTableHeader"),
                ", ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "SuiteTableBody"),
                ", ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "SuiteTableFooter"),
                ", ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "SuiteTableRow"),
                ", ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "SuiteTableHead"),
                ", ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "SuiteTableCell"),
                ", ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "SuiteTableCaption"),
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
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "SuiteTable"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "div > table"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Scrollable table container")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "SuiteTableHeader"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "thead"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Table header section")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "SuiteTableBody"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "tbody"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Table body section")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "SuiteTableFooter"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "tfoot"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Table footer section")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "SuiteTableRow"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "tr"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Table row with hover state")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "SuiteTableHead"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "th"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Header cell")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "SuiteTableCell"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "td"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Data cell")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "SuiteTableCaption"),
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
