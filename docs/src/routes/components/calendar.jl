# Calendar — Suite.jl component docs page
#
# Showcases Calendar with single/multiple/range selection modes,
# keyboard navigation, and customization options.


function CalendarPage()
    ComponentsLayout(
        # Header
        PageHeader("Calendar", "A date calendar grid with selection, navigation, and keyboard interaction."),

        # Basic Preview
        ComponentPreview(title="Single Date", description="Click a date to select it. Click again to deselect.",
            Div(:class => "flex justify-center",
                Main.Calendar(month=2, year=2026)
            )
        ),

        # Range Selection
        ComponentPreview(title="Date Range", description="Select a start and end date to create a range.",
            Div(:class => "flex justify-center",
                Main.Calendar(mode="range", month=2, year=2026)
            )
        ),

        # Multiple Selection
        ComponentPreview(title="Multiple Dates", description="Click multiple dates to select them individually.",
            Div(:class => "flex justify-center",
                Main.Calendar(mode="multiple", month=2, year=2026)
            )
        ),

        # Two Months
        ComponentPreview(title="Two Months", description="Display two months side by side for range selection.",
            Div(:class => "flex justify-center",
                Main.Calendar(mode="range", number_of_months=2, month=1, year=2026)
            )
        ),

        # Usage
        UsageBlock("""using Suite

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
Calendar(fixed_weeks=true)"""),

        # Keyboard Interactions
        KeyboardTable(
            KeyRow("ArrowLeft", "Move focus to previous day"),
            KeyRow("ArrowRight", "Move focus to next day"),
            KeyRow("ArrowUp", "Move focus to same day in previous week"),
            KeyRow("ArrowDown", "Move focus to same day in next week"),
            KeyRow("PageUp", "Move focus to same day in previous month"),
            KeyRow("PageDown", "Move focus to same day in next month"),
            KeyRow("Shift+PageUp", "Move focus to same day in previous year"),
            KeyRow("Shift+PageDown", "Move focus to same day in next year"),
            KeyRow("Home", "Move focus to start of week (Monday)"),
            KeyRow("End", "Move focus to end of week (Sunday)"),
            KeyRow("Space / Enter", "Select focused date"),
        ),

        # API Reference
        ApiTable(
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
        ),
    )
end


CalendarPage
