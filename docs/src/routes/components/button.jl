# Button — Suite.jl component docs page
#
# Showcases SuiteButton with all variants, sizes, and usage examples.
# Mirrors shadcn/ui docs layout: preview, usage, API reference.

const SuiteButton = Main.SuiteButton

function ButtonPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Button"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "Displays a button or a component that looks like a button."
            )
        ),

        # Default Preview
        ComponentPreview(title="Default", description="The default button with accent background.",
            SuiteButton("Button")
        ),

        # All Variants
        ComponentPreview(title="Variants", description="All available button variants.",
            Div(:class => "flex flex-wrap gap-4",
                SuiteButton(variant="default", "Default"),
                SuiteButton(variant="secondary", "Secondary"),
                SuiteButton(variant="outline", "Outline"),
                SuiteButton(variant="ghost", "Ghost"),
                SuiteButton(variant="link", "Link"),
                SuiteButton(variant="destructive", "Destructive")
            )
        ),

        # All Sizes
        ComponentPreview(title="Sizes", description="Available button sizes.",
            Div(:class => "flex flex-wrap items-center gap-4",
                SuiteButton(size="sm", "Small"),
                SuiteButton(size="default", "Default"),
                SuiteButton(size="lg", "Large"),
                SuiteButton(size="icon", "X")
            )
        ),

        # Disabled
        ComponentPreview(title="Disabled", description="Buttons with disabled state.",
            Div(:class => "flex flex-wrap gap-4",
                SuiteButton(:disabled => true, "Disabled"),
                SuiteButton(variant="outline", :disabled => true, "Disabled")
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

SuiteButton("Click me")
SuiteButton(variant="outline", "Settings")
SuiteButton(variant="destructive", size="sm", "Delete")
SuiteButton(variant="icon", size="icon", "X")""")
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
                        ApiRow("variant", "String", "\"default\"", "default | destructive | outline | secondary | ghost | link"),
                        ApiRow("size", "String", "\"default\"", "default | sm | lg | icon"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes to merge"),
                        ApiRow("children...", "Any", "-", "Button content (text, icons, etc.)"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute (disabled, id, etc.)")
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

ButtonPage
