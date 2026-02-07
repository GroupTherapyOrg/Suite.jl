# Slider — Suite.jl component docs page
#
# Showcases Slider with orientations, ranges, and states.


function SliderPage()
    ComponentsLayout(
        # Header
        PageHeader("Slider", "An input where the user selects a value from within a given range."),

        # Default Preview
        ComponentPreview(title="Default", description="A basic slider from 0 to 100.",
            Div(:class => "w-full max-w-sm",
                Main.Slider(default_value=50)
            )
        ),

        # Custom Range
        ComponentPreview(title="Custom Range", description="Slider with custom min, max, and step.",
            Div(:class => "space-y-6 w-full max-w-sm",
                Div(:class => "space-y-2",
                    Main.Label("Temperature (10-40, step 5)"),
                    Main.Slider(min=10, max=40, step=5, default_value=25),
                ),
                Div(:class => "space-y-2",
                    Main.Label("Volume (0-100, step 10)"),
                    Main.Slider(min=0, max=100, step=10, default_value=70),
                ),
            )
        ),

        # Multiple values on page
        ComponentPreview(title="Various Positions", description="Sliders at different fill percentages.",
            Div(:class => "space-y-6 w-full max-w-sm",
                Div(:class => "space-y-1",
                    Span(:class => "text-sm text-warm-600 dark:text-warm-400", "0%"),
                    Main.Slider(default_value=0),
                ),
                Div(:class => "space-y-1",
                    Span(:class => "text-sm text-warm-600 dark:text-warm-400", "25%"),
                    Main.Slider(default_value=25),
                ),
                Div(:class => "space-y-1",
                    Span(:class => "text-sm text-warm-600 dark:text-warm-400", "50%"),
                    Main.Slider(default_value=50),
                ),
                Div(:class => "space-y-1",
                    Span(:class => "text-sm text-warm-600 dark:text-warm-400", "75%"),
                    Main.Slider(default_value=75),
                ),
                Div(:class => "space-y-1",
                    Span(:class => "text-sm text-warm-600 dark:text-warm-400", "100%"),
                    Main.Slider(default_value=100),
                ),
            )
        ),

        # Disabled
        ComponentPreview(title="Disabled", description="A disabled slider that cannot be interacted with.",
            Div(:class => "w-full max-w-sm",
                Main.Slider(default_value=40, disabled=true)
            )
        ),

        # With Label
        ComponentPreview(title="With Label", description="Slider paired with a label.",
            Div(:class => "space-y-3 w-full max-w-sm",
                Main.Label("Brightness"),
                Main.Slider(default_value=60),
            )
        ),

        # Usage
        UsageBlock("""using Suite

# Basic slider
Slider()

# Custom range and step
Slider(min=0, max=100, step=5, default_value=50)

# Vertical orientation
Slider(orientation="vertical")

# Disabled
Slider(default_value=40, disabled=true)

# With a label
Div(
    Label("Volume"),
    Slider(min=0, max=100, step=1, default_value=75),
)"""),

        # Keyboard Interactions
        KeyboardTable(
            KeyRow("ArrowRight / ArrowUp", "Increase value by one step"),
            KeyRow("ArrowLeft / ArrowDown", "Decrease value by one step"),
            KeyRow("Shift + Arrow", "Increase/decrease by 10x step"),
            KeyRow("PageUp", "Increase value by 10x step"),
            KeyRow("PageDown", "Decrease value by 10x step"),
            KeyRow("Home", "Set to minimum value"),
            KeyRow("End", "Set to maximum value"),
        ),

        # API Reference
        ApiTable(
                        ApiRow("min", "Real", "0", "Minimum value"),
                        ApiRow("max", "Real", "100", "Maximum value"),
                        ApiRow("step", "Real", "1", "Step increment"),
                        ApiRow("default_value", "Real", "0", "Initial value"),
                        ApiRow("orientation", "String", "\"horizontal\"", "\"horizontal\" or \"vertical\""),
                        ApiRow("disabled", "Bool", "false", "Disable the slider"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
        ),

        # Accessibility
        Div(:class => "mt-12 space-y-4",
            SectionH2("Accessibility"),
            P(:class => "text-warm-600 dark:text-warm-400",
                "The Slider follows the ", A(:href => "https://www.w3.org/WAI/ARIA/apg/patterns/slider/", :target => "_blank", :class => "text-accent-600 dark:text-accent-400 hover:underline", "WAI-ARIA Slider pattern"), "."
            ),
            Ul(:class => "list-disc list-inside text-warm-600 dark:text-warm-400 space-y-1",
                Li("The thumb has ", Main.InlineCode("role=\"slider\""), " with proper aria-valuenow/min/max"),
                Li("Keyboard navigation for arrow keys, Home, End, PageUp, PageDown"),
                Li("Pointer capture API for smooth drag interaction"),
                Li("Disabled state sets tabindex=\"-1\" and aria-disabled=\"true\""),
            )
        )
    )
end




SliderPage
