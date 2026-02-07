# Textarea — Suite.jl component docs page
#
# Showcases Textarea for multi-line text input.


function TextareaPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Textarea"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "Displays a form textarea or a component that looks like a textarea."
            )
        ),

        # Default Preview
        ComponentPreview(title="Default", description="A default textarea.",
            Main.Textarea(placeholder="Type your message here.", class="max-w-sm")
        ),

        # With Label
        ComponentPreview(title="With Label", description="Textarea paired with a label.",
            Div(:class => "grid w-full max-w-sm gap-1.5",
                Main.Label("Your message"),
                Main.Textarea(placeholder="Type your message here.")
            )
        ),

        # Disabled
        ComponentPreview(title="Disabled", description="Textarea in disabled state.",
            Main.Textarea(disabled=true, placeholder="Disabled", class="max-w-sm")
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "Usage"
            ),
            Div(:class => "bg-warm-800 dark:bg-warm-950 rounded-md border border-warm-700 p-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-50",
                    Code(:class => "language-julia", """using Suite

Textarea(placeholder="Type your message here.")
Textarea(:rows => "5", placeholder="Bio")
Textarea(:disabled => true, placeholder="Disabled")""")
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
                    Thead(
                        Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                        )
                    ),
                    Tbody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute (placeholder, rows, disabled, etc.)")
                    )
                )
            )
        )
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

TextareaPage
