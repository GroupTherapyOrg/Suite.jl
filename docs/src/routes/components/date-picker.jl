# Date Picker — Suite.jl component docs page
#
# Showcases DatePicker — a Calendar inside a Popover dropdown,
# with single, range, and multiple selection modes.


function DatePickerPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3",
                "Date Picker"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A date picker that combines a trigger button with a Calendar in a floating dropdown."
            )
        ),

        # Basic Preview
        ComponentPreview(title="Single Date", description="Click the button to open a calendar. Select a date to populate the field.",
            Div(:class => "flex justify-center",
                Main.DatePicker(month=2, year=2026)
            )
        ),

        # Range Date Picker
        ComponentPreview(title="Date Range", description="Select a start and end date. Shows two months side by side.",
            Div(:class => "flex justify-center",
                Main.DatePicker(mode="range", number_of_months=2, month=1, year=2026, placeholder="Select date range")
            )
        ),

        # Pre-selected
        ComponentPreview(title="Pre-selected Date", description="A date picker with a date already selected.",
            Div(:class => "flex justify-center",
                Main.DatePicker(selected="2026-02-14", month=2, year=2026)
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "Usage"
            ),
            Pre(:class => "bg-warm-100 dark:bg-warm-900 rounded-lg p-4 text-sm overflow-x-auto",
                Code(:class => "text-warm-800 dark:text-warm-300",
                    """using Suite

# Simple date picker
DatePicker()

# Range picker with two months
DatePicker(mode="range", number_of_months=2, placeholder="Select dates")

# Pre-selected date
DatePicker(selected="2026-02-14")

# Custom placeholder
DatePicker(placeholder="Choose a birthday")

# Disabled dates
DatePicker(disabled_dates="2026-02-14,2026-02-15")"""
                )
            )
        ),

        # Composition Notes
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "Composition"
            ),
            P(:class => "text-warm-600 dark:text-warm-300 mb-4",
                "DatePicker is a composition of a trigger button with a Calendar inside a floating dropdown. For more control, you can compose these yourself using Popover + Calendar."
            ),
            Pre(:class => "bg-warm-100 dark:bg-warm-900 rounded-lg p-4 text-sm overflow-x-auto",
                Code(:class => "text-warm-800 dark:text-warm-300",
                    """# Manual composition with Popover + Calendar
Popover(
    PopoverTrigger(Button(variant="outline", "Pick a date")),
    PopoverContent(class="w-auto p-0",
        Calendar(mode="single")
    )
)"""
                )
            )
        ),

        # Keyboard Interactions
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
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
                        KeyRow("Space / Enter", "Open calendar (on trigger button)"),
                        KeyRow("Escape", "Close calendar and return focus to trigger"),
                        KeyRow("Arrow keys", "Navigate days in the calendar grid"),
                        KeyRow("PageUp / PageDown", "Navigate months"),
                        KeyRow("Space / Enter", "Select focused date (in calendar)"),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-8",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "API Reference"
            ),

            # DatePicker
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300", "DatePicker"),
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
                        ApiRow("month", "Int", "current month", "Initial displayed month (1-12)"),
                        ApiRow("year", "Int", "current year", "Initial displayed year"),
                        ApiRow("selected", "String", "\"\"", "Pre-selected date(s), comma-separated ISO strings"),
                        ApiRow("placeholder", "String", "\"Pick a date\"", "Trigger button text when no date selected"),
                        ApiRow("disabled_dates", "String", "\"\"", "Disabled dates, comma-separated ISO strings"),
                        ApiRow("show_outside_days", "Bool", "true", "Show days from adjacent months"),
                        ApiRow("number_of_months", "Int", "1", "Number of months to display"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes for the trigger button"),
                        ApiRow("theme", "Symbol", ":default", "Theme preset"),
                    )
                )
            ),
        ),
    )
end

function KeyRow(key, action)
    Main.TableRow(
        Main.TableCell(Code(:class => "text-sm", key)),
        Main.TableCell(action),
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

DatePickerPage
