# Calendar — Suite.jl component docs page
#
# Showcases Calendar with single/multiple/range selection modes,
# keyboard navigation, and customization options.

const Calendar_ = Main.Calendar

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
                Calendar_(month=2, year=2026)
            )
        ),

        # Range Selection
        ComponentPreview(title="Date Range", description="Select a start and end date to create a range.",
            Div(:class => "flex justify-center",
                Calendar_(mode="range", month=2, year=2026)
            )
        ),

        # Multiple Selection
        ComponentPreview(title="Multiple Dates", description="Click multiple dates to select them individually.",
            Div(:class => "flex justify-center",
                Calendar_(mode="multiple", month=2, year=2026)
            )
        ),

        # Two Months
        ComponentPreview(title="Two Months", description="Display two months side by side for range selection.",
            Div(:class => "flex justify-center",
                Calendar_(mode="range", number_of_months=2, month=1, year=2026)
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
Calendar()

# Range selection with two months
Calendar(mode="range", number_of_months=2)

# Multiple date selection
Calendar(mode="multiple")

# Pre-selected date
Calendar(selected="2026-02-14", month=2, year=2026)

# Disabled dates
Calendar(disabled_dates="2026-02-14,2026-02-15")

# Without outside days
Calendar(show_outside_days=false)

# Fixed 6-week grid
Calendar(fixed_weeks=true)"""
                )
            )
        ),

        # Keyboard Interactions
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "Keyboard Interactions"
            ),
            Div(:class => "overflow-x-auto",
                Main.Table(
                    Main.TableHeader(
                        Main.TableRow(
                            Main.TableHead("Key"),
                            Main.TableHead("Action"),
                        )
                    ),
                    Main.TableBody(
                        Main.TableRow(
                            Main.TableCell(Code(:class => "text-sm", "ArrowLeft")),
                            Main.TableCell("Move focus to previous day"),
                        ),
                        Main.TableRow(
                            Main.TableCell(Code(:class => "text-sm", "ArrowRight")),
                            Main.TableCell("Move focus to next day"),
                        ),
                        Main.TableRow(
                            Main.TableCell(Code(:class => "text-sm", "ArrowUp")),
                            Main.TableCell("Move focus to same day in previous week"),
                        ),
                        Main.TableRow(
                            Main.TableCell(Code(:class => "text-sm", "ArrowDown")),
                            Main.TableCell("Move focus to same day in next week"),
                        ),
                        Main.TableRow(
                            Main.TableCell(Code(:class => "text-sm", "PageUp")),
                            Main.TableCell("Move focus to same day in previous month"),
                        ),
                        Main.TableRow(
                            Main.TableCell(Code(:class => "text-sm", "PageDown")),
                            Main.TableCell("Move focus to same day in next month"),
                        ),
                        Main.TableRow(
                            Main.TableCell(Code(:class => "text-sm", "Shift+PageUp")),
                            Main.TableCell("Move focus to same day in previous year"),
                        ),
                        Main.TableRow(
                            Main.TableCell(Code(:class => "text-sm", "Shift+PageDown")),
                            Main.TableCell("Move focus to same day in next year"),
                        ),
                        Main.TableRow(
                            Main.TableCell(Code(:class => "text-sm", "Home")),
                            Main.TableCell("Move focus to start of week (Monday)"),
                        ),
                        Main.TableRow(
                            Main.TableCell(Code(:class => "text-sm", "End")),
                            Main.TableCell("Move focus to end of week (Sunday)"),
                        ),
                        Main.TableRow(
                            Main.TableCell(Code(:class => "text-sm", "Space / Enter")),
                            Main.TableCell("Select focused date"),
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

            # Calendar
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-50", "Calendar"),
            Div(:class => "overflow-x-auto",
                Main.Table(
                    Main.TableHeader(
                        Main.TableRow(
                            Main.TableHead("Prop"),
                            Main.TableHead("Type"),
                            Main.TableHead("Default"),
                            Main.TableHead("Description"),
                        )
                    ),
                    Main.TableBody(
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
    Main.TableRow(
        Main.TableCell(Code(:class => "text-sm text-accent-600 dark:text-accent-400", prop)),
        Main.TableCell(Code(:class => "text-sm", type)),
        Main.TableCell(Code(:class => "text-sm", default)),
        Main.TableCell(description),
    )
end

CalendarPage
