# Data Table — Suite.jl component docs page
#
# Showcases DataTable with sorting, filtering, pagination, row selection.


# Sample data for demos
const _DT_DEMO_DATA = [
    (invoice="INV001", status="Paid", method="Credit Card", amount=250.00),
    (invoice="INV002", status="Pending", method="PayPal", amount=150.00),
    (invoice="INV003", status="Unpaid", method="Bank Transfer", amount=350.00),
    (invoice="INV004", status="Paid", method="Credit Card", amount=450.00),
    (invoice="INV005", status="Paid", method="PayPal", amount=550.00),
    (invoice="INV006", status="Pending", method="Bank Transfer", amount=200.00),
    (invoice="INV007", status="Unpaid", method="Credit Card", amount=125.00),
    (invoice="INV008", status="Paid", method="PayPal", amount=675.00),
    (invoice="INV009", status="Pending", method="Bank Transfer", amount=310.00),
    (invoice="INV010", status="Paid", method="Credit Card", amount=890.00),
    (invoice="INV011", status="Unpaid", method="PayPal", amount=175.00),
    (invoice="INV012", status="Paid", method="Bank Transfer", amount=425.00),
]

const _DT_DEMO_COLUMNS = [
    Main.DataTableColumn("invoice", "Invoice"),
    Main.DataTableColumn("status", "Status"),
    Main.DataTableColumn("method", "Method"),
    Main.DataTableColumn("amount", "Amount", align="right"),
]

function ApiRow(name, type, default, description)
    Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
        Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", name),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", type),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", default),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", description)
    )
end

function DataTablePage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Data Table"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A full-featured data table with sorting, filtering, pagination, and row selection."
            )
        ),

        # Default Preview
        ComponentPreview(title="Default", description="A data table with sortable columns, filtering, and pagination.",
            Main.DataTable(_DT_DEMO_DATA, _DT_DEMO_COLUMNS, page_size=5)
        ),

        # With Row Selection
        ComponentPreview(title="With Row Selection", description="Enable row selection with checkboxes.",
            Main.DataTable(_DT_DEMO_DATA, _DT_DEMO_COLUMNS,
                page_size=5, selectable=true)
        ),

        # With Column Visibility
        ComponentPreview(title="Column Visibility", description="Toggle column visibility with the Columns dropdown.",
            Main.DataTable(_DT_DEMO_DATA, _DT_DEMO_COLUMNS,
                page_size=5, column_visibility=true)
        ),

        # All Features
        ComponentPreview(title="All Features", description="Sorting, filtering, pagination, row selection, and column visibility.",
            Main.DataTable(_DT_DEMO_DATA, _DT_DEMO_COLUMNS,
                page_size=5, selectable=true, column_visibility=true,
                filter_placeholder="Search invoices...")
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "Usage"
            ),
            Div(:class => "bg-warm-800 dark:bg-warm-950 rounded-md border border-warm-700 p-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-50",
                    Code(:class => "language-julia", """using Suite

# Define your data
data = [
    (name="Alice", email="alice@example.com", role="Admin"),
    (name="Bob", email="bob@example.com", role="User"),
    (name="Charlie", email="charlie@example.com", role="Editor"),
]

# Define columns
columns = [
    DataTableColumn("name", "Name"),
    DataTableColumn("email", "Email"),
    DataTableColumn("role", "Role"),
]

# Render the table
DataTable(data, columns,
    paginated=true,
    page_size=10,
    selectable=true,
    column_visibility=true,
    filter_placeholder="Search users...",
)""")
                )
            )
        ),

        # Column Definition
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "Column Definition"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 mb-4",
                "Columns are defined using ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "DataTableColumn"),
                ". Each column specifies a data key, header text, and optional configuration."
            ),
            Div(:class => "bg-warm-800 dark:bg-warm-950 rounded-md border border-warm-700 p-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-50",
                    Code(:class => "language-julia", """# Basic column
DataTableColumn("name", "Name")

# Right-aligned column
DataTableColumn("amount", "Amount", align="right")

# Non-sortable column
DataTableColumn("actions", "Actions", sortable=false, hideable=false)

# Custom cell renderer
DataTableColumn("status", "Status",
    cell=(val, row) -> Badge(val, variant=val == "Active" ? "default" : "secondary"))""")
                )
            )
        ),

        # Keyboard Interactions
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "Features"
            ),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(
                        Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Feature"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                        )
                    ),
                    Tbody(
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs text-warm-800 dark:text-warm-300", "Sorting"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Click column headers to sort ascending/descending/none")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs text-warm-800 dark:text-warm-300", "Filtering"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Type in the filter input to search across all columns")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs text-warm-800 dark:text-warm-300", "Pagination"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Navigate pages with Previous/Next buttons")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs text-warm-800 dark:text-warm-300", "Row Selection"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Select individual rows or all rows on current page")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs text-warm-800 dark:text-warm-300", "Column Visibility"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Toggle column display via the Columns dropdown")
                        ),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "API Reference"
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "DataTable"),
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
                        ApiRow("data", "Vector", "required", "Data rows (Vector of NamedTuples or Dicts)"),
                        ApiRow("columns", "Vector{DataTableColumn}", "required", "Column definitions"),
                        ApiRow("filterable", "Bool", "true", "Show filter input"),
                        ApiRow("filter_placeholder", "String", "\"Filter...\"", "Filter input placeholder text"),
                        ApiRow("filter_columns", "Vector{String}", "[] (all)", "Columns to filter on"),
                        ApiRow("sortable", "Bool", "true", "Enable column sorting"),
                        ApiRow("paginated", "Bool", "true", "Enable pagination"),
                        ApiRow("page_size", "Int", "10", "Rows per page"),
                        ApiRow("selectable", "Bool", "false", "Show row selection checkboxes"),
                        ApiRow("column_visibility", "Bool", "false", "Show column visibility toggle"),
                        ApiRow("caption", "String", "\"\"", "Table caption"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("theme", "Symbol", ":default", "Theme name"),
                    )
                )
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "DataTableColumn"),
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
                        ApiRow("key", "String", "required", "Data field key (accessor)"),
                        ApiRow("header", "String", "required", "Display header text"),
                        ApiRow("sortable", "Bool", "true", "Whether this column is sortable"),
                        ApiRow("hideable", "Bool", "true", "Whether this column can be hidden"),
                        ApiRow("cell", "Function|Nothing", "nothing", "Custom cell renderer (val, row) -> VNode"),
                        ApiRow("header_class", "String", "\"\"", "Additional CSS classes for header cell"),
                        ApiRow("cell_class", "String", "\"\"", "Additional CSS classes for data cells"),
                        ApiRow("align", "String", "\"left\"", "Text alignment: left, center, right"),
                    )
                )
            ),
        )
    )
end

DataTablePage
