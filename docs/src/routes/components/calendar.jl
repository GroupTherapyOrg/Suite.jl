# Calendar — Suite.jl component docs page
#
# Showcases SuiteCalendar with single/multiple/range selection modes,
# keyboard navigation, and customization options.

const SuiteCalendar_ = Main.SuiteCalendar

function CalendarPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Calendar"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A date calendar grid with selection, navigation, and keyboard interaction."
            )
        ),

        # Basic Preview
        ComponentPreview(title="Single Date", description="Click a date to select it. Click again to deselect.",
            Div(:class => "flex justify-center",
                SuiteCalendar_(month=2, year=2026)
            )
        ),

        # Range Selection
        ComponentPreview(title="Date Range", description="Select a start and end date to create a range.",
            Div(:class => "flex justify-center",
                SuiteCalendar_(mode="range", month=2, year=2026)
            )
        ),

        # Multiple Selection
        ComponentPreview(title="Multiple Dates", description="Click multiple dates to select them individually.",
            Div(:class => "flex justify-center",
                SuiteCalendar_(mode="multiple", month=2, year=2026)
            )
        ),

        # Two Months
        ComponentPreview(title="Two Months", description="Display two months side by side for range selection.",
            Div(:class => "flex justify-center",
                SuiteCalendar_(mode="range", number_of_months=2, month=1, year=2026)
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "Usage"
            ),
            Pre(:class => "bg-warm-100 dark:bg-warm-900 rounded-lg p-4 text-sm overflow-x-auto",
                Code(:class => "text-warm-800 dark:text-warm-300",
                    """using Suite

# Single date selection (default)
SuiteCalendar()

# Range selection with two months
SuiteCalendar(mode="range", number_of_months=2)

# Multiple date selection
SuiteCalendar(mode="multiple")

# Pre-selected date
SuiteCalendar(selected="2026-02-14", month=2, year=2026)

# Disabled dates
SuiteCalendar(disabled_dates="2026-02-14,2026-02-15")

# Without outside days
SuiteCalendar(show_outside_days=false)

# Fixed 6-week grid
SuiteCalendar(fixed_weeks=true)"""
                )
            )
        ),

        # Keyboard Interactions
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "Keyboard Interactions"
            ),
            Div(:class => "overflow-x-auto",
                Main.SuiteTable(
                    Main.SuiteTableHeader(
                        Main.SuiteTableRow(
                            Main.SuiteTableHead("Key"),
                            Main.SuiteTableHead("Action"),
                        )
                    ),
                    Main.SuiteTableBody(
                        Main.SuiteTableRow(
                            Main.SuiteTableCell(Code(:class => "text-sm", "ArrowLeft")),
                            Main.SuiteTableCell("Move focus to previous day"),
                        ),
                        Main.SuiteTableRow(
                            Main.SuiteTableCell(Code(:class => "text-sm", "ArrowRight")),
                            Main.SuiteTableCell("Move focus to next day"),
                        ),
                        Main.SuiteTableRow(
                            Main.SuiteTableCell(Code(:class => "text-sm", "ArrowUp")),
                            Main.SuiteTableCell("Move focus to same day in previous week"),
                        ),
                        Main.SuiteTableRow(
                            Main.SuiteTableCell(Code(:class => "text-sm", "ArrowDown")),
                            Main.SuiteTableCell("Move focus to same day in next week"),
                        ),
                        Main.SuiteTableRow(
                            Main.SuiteTableCell(Code(:class => "text-sm", "PageUp")),
                            Main.SuiteTableCell("Move focus to same day in previous month"),
                        ),
                        Main.SuiteTableRow(
                            Main.SuiteTableCell(Code(:class => "text-sm", "PageDown")),
                            Main.SuiteTableCell("Move focus to same day in next month"),
                        ),
                        Main.SuiteTableRow(
                            Main.SuiteTableCell(Code(:class => "text-sm", "Shift+PageUp")),
                            Main.SuiteTableCell("Move focus to same day in previous year"),
                        ),
                        Main.SuiteTableRow(
                            Main.SuiteTableCell(Code(:class => "text-sm", "Shift+PageDown")),
                            Main.SuiteTableCell("Move focus to same day in next year"),
                        ),
                        Main.SuiteTableRow(
                            Main.SuiteTableCell(Code(:class => "text-sm", "Home")),
                            Main.SuiteTableCell("Move focus to start of week (Monday)"),
                        ),
                        Main.SuiteTableRow(
                            Main.SuiteTableCell(Code(:class => "text-sm", "End")),
                            Main.SuiteTableCell("Move focus to end of week (Sunday)"),
                        ),
                        Main.SuiteTableRow(
                            Main.SuiteTableCell(Code(:class => "text-sm", "Space / Enter")),
                            Main.SuiteTableCell("Select focused date"),
                        ),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-8",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "API Reference"
            ),

            # SuiteCalendar
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-50", "SuiteCalendar"),
            Div(:class => "overflow-x-auto",
                Main.SuiteTable(
                    Main.SuiteTableHeader(
                        Main.SuiteTableRow(
                            Main.SuiteTableHead("Prop"),
                            Main.SuiteTableHead("Type"),
                            Main.SuiteTableHead("Default"),
                            Main.SuiteTableHead("Description"),
                        )
                    ),
                    Main.SuiteTableBody(
                        ApiRow("mode", "String", "\"single\"", "Selection mode: single, multiple, or range"),
                        ApiRow("month", "Int", "current month", "Displayed month (1-12)"),
                        ApiRow("year", "Int", "current year", "Displayed year"),
                        ApiRow("selected", "String", "\"\"", "Pre-selected date(s), comma-separated ISO strings"),
                        ApiRow("disabled_dates", "String", "\"\"", "Disabled dates, comma-separated ISO strings"),
                        ApiRow("show_outside_days", "Bool", "true", "Show days from adjacent months"),
                        ApiRow("fixed_weeks", "Bool", "false", "Always show 6 weeks"),
                        ApiRow("number_of_months", "Int", "1", "Number of months to display side by side"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("theme", "Symbol", ":default", "Theme preset"),
                    )
                )
            ),
        ),
    )
end

function ApiRow(prop, type, default, description)
    Main.SuiteTableRow(
        Main.SuiteTableCell(Code(:class => "text-sm text-accent-600 dark:text-accent-400", prop)),
        Main.SuiteTableCell(Code(:class => "text-sm", type)),
        Main.SuiteTableCell(Code(:class => "text-sm", default)),
        Main.SuiteTableCell(description),
    )
end

CalendarPage
