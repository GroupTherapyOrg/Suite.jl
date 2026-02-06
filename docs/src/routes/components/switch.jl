# Switch — Suite.jl component docs page
#
# Showcases SuiteSwitch with sizes and states.

const SuiteSwitch = Main.SuiteSwitch

function SwitchPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Switch"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A control that allows the user to toggle between checked and unchecked."
            )
        ),

        # Default Preview
        ComponentPreview(title="Default", description="Click to toggle the switch on and off.",
            Div(:class => "flex items-center gap-3",
                SuiteSwitch(),
                Span(:class => "text-sm text-warm-600 dark:text-warm-400", "Airplane Mode"),
            )
        ),

        # Checked
        ComponentPreview(title="Checked", description="A switch that starts in the checked state.",
            Div(:class => "flex items-center gap-3",
                SuiteSwitch(checked=true),
                Span(:class => "text-sm text-warm-600 dark:text-warm-400", "Notifications enabled"),
            )
        ),

        # Sizes
        ComponentPreview(title="Sizes", description="Default and small sizes.",
            Div(:class => "flex items-center gap-6",
                Div(:class => "flex items-center gap-2",
                    SuiteSwitch(),
                    Span(:class => "text-sm text-warm-600 dark:text-warm-400", "Default"),
                ),
                Div(:class => "flex items-center gap-2",
                    SuiteSwitch(size="sm"),
                    Span(:class => "text-sm text-warm-600 dark:text-warm-400", "Small"),
                ),
            )
        ),

        # Disabled
        ComponentPreview(title="Disabled", description="Disabled switches cannot be toggled.",
            Div(:class => "flex items-center gap-6",
                Div(:class => "flex items-center gap-2",
                    SuiteSwitch(disabled=true),
                    Span(:class => "text-sm text-warm-600 dark:text-warm-400", "Disabled off"),
                ),
                Div(:class => "flex items-center gap-2",
                    SuiteSwitch(checked=true, disabled=true),
                    Span(:class => "text-sm text-warm-600 dark:text-warm-400", "Disabled on"),
                ),
            )
        ),

        # With label using SuiteLabel
        ComponentPreview(title="With Label", description="Switch paired with a label.",
            Div(:class => "flex items-center gap-3",
                SuiteSwitch(),
                Main.SuiteLabel("Email notifications"),
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

SuiteSwitch()
SuiteSwitch(checked=true)
SuiteSwitch(size="sm", disabled=true)

# With a label
Div(
    SuiteSwitch(:id => "notifications"),
    SuiteLabel(:htmlFor => "notifications", "Enable notifications"),
)""")
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "API Reference"
            ),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("checked", "Bool", "false", "Initial checked state"),
                        ApiRow("disabled", "Bool", "false", "Disable the switch"),
                        ApiRow("size", "String", "\"default\"", "\"default\" or \"sm\""),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            )
        )
    )
end

function ApiHead()
    Tr(:class => "border-b border-warm-200 dark:border-warm-700",
        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
    )
end

function ApiRow(prop, type, default, description)
    Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
        Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", prop),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", type),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", default),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", description)
    )
end

SwitchPage
