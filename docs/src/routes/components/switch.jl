# Switch — Suite.jl component docs page
#
# Showcases Switch with sizes and states.


function SwitchPage()
    ComponentsLayout(
        # Header
        PageHeader("Switch", "A control that allows the user to toggle between checked and unchecked."),

        # Default Preview
        ComponentPreview(title="Default", description="Click to toggle the switch on and off.",
            Div(:class => "flex items-center gap-3",
                Main.Switch(),
                Span(:class => "text-sm text-warm-600 dark:text-warm-400", "Airplane Mode"),
            )
        ),

        # Checked
        ComponentPreview(title="Checked", description="A switch that starts in the checked state.",
            Div(:class => "flex items-center gap-3",
                Main.Switch(checked=true),
                Span(:class => "text-sm text-warm-600 dark:text-warm-400", "Notifications enabled"),
            )
        ),

        # Sizes
        ComponentPreview(title="Sizes", description="Default and small sizes.",
            Div(:class => "flex items-center gap-6",
                Div(:class => "flex items-center gap-2",
                    Main.Switch(),
                    Span(:class => "text-sm text-warm-600 dark:text-warm-400", "Default"),
                ),
                Div(:class => "flex items-center gap-2",
                    Main.Switch(size="sm"),
                    Span(:class => "text-sm text-warm-600 dark:text-warm-400", "Small"),
                ),
            )
        ),

        # Disabled
        ComponentPreview(title="Disabled", description="Disabled switches cannot be toggled.",
            Div(:class => "flex items-center gap-6",
                Div(:class => "flex items-center gap-2",
                    Main.Switch(disabled=true),
                    Span(:class => "text-sm text-warm-600 dark:text-warm-400", "Disabled off"),
                ),
                Div(:class => "flex items-center gap-2",
                    Main.Switch(checked=true, disabled=true),
                    Span(:class => "text-sm text-warm-600 dark:text-warm-400", "Disabled on"),
                ),
            )
        ),

        # With label using Label
        ComponentPreview(title="With Label", description="Switch paired with a label.",
            Div(:class => "flex items-center gap-3",
                Main.Switch(),
                Main.Label("Email notifications"),
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            SectionH2("Usage"),
            Main.CodeBlock(language="julia", """using Suite

Switch()
Switch(checked=true)
Switch(size="sm", disabled=true)

# With a label
Div(
    Switch(:id => "notifications"),
    Label(:htmlFor => "notifications", "Enable notifications"),
)""")
        ),

        # API Reference
        ApiTable(
                        ApiRow("checked", "Bool", "false", "Initial checked state"),
                        ApiRow("disabled", "Bool", "false", "Disable the switch"),
                        ApiRow("size", "String", "\"default\"", "\"default\" or \"sm\""),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
        )
    )
end



SwitchPage
