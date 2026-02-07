# Input — Suite.jl component docs page
#
# Showcases Input with types, states, and form patterns.


function InputPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3",
                "Input"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "Displays a form input field or a component that looks like an input field."
            )
        ),

        # Default Preview
        ComponentPreview(title="Default", description="A default text input.",
            Main.Input(placeholder="Email", class="max-w-sm")
        ),

        # With Label
        ComponentPreview(title="With Label", description="Input paired with a label.",
            Div(:class => "grid w-full max-w-sm items-center gap-1.5",
                Main.Label("Email"),
                Main.Input(type="email", placeholder="Email")
            )
        ),

        # File Input
        ComponentPreview(title="File", description="Input for file uploads.",
            Div(:class => "grid w-full max-w-sm items-center gap-1.5",
                Main.Label("Picture"),
                Main.Input(type="file")
            )
        ),

        # Disabled
        ComponentPreview(title="Disabled", description="Input in disabled state.",
            Main.Input(disabled=true, placeholder="Disabled", class="max-w-sm")
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "Usage"
            ),
            Main.CodeBlock(language="julia", """using Suite

Input(placeholder="Email")
Input(type="password", placeholder="Password")
Input(type="file")
Input(:disabled => true, placeholder="Disabled")""")
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
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
                        ApiRow("type", "String", "\"text\"", "text | email | password | file | number | etc."),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute (placeholder, disabled, id, etc.)")
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

InputPage
