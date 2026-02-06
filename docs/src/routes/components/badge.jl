# Badge — Suite.jl component docs page
#
# Showcases SuiteBadge with all variants and usage examples.

const SuiteBadge = Main.SuiteBadge

function BadgePage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Badge"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "Displays a badge or a component that looks like a badge."
            )
        ),

        # Default Preview
        ComponentPreview(title="Default", description="The default badge with accent background.",
            SuiteBadge("Badge")
        ),

        # All Variants
        ComponentPreview(title="Variants", description="All available badge variants.",
            Div(:class => "flex flex-wrap gap-4",
                SuiteBadge(variant="default", "Default"),
                SuiteBadge(variant="secondary", "Secondary"),
                SuiteBadge(variant="outline", "Outline"),
                SuiteBadge(variant="destructive", "Destructive")
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

SuiteBadge("New")
SuiteBadge(variant="secondary", "Secondary")
SuiteBadge(variant="destructive", "Error")
SuiteBadge(variant="outline", "v2.0")""")
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
                        ApiRow("variant", "String", "\"default\"", "default | secondary | destructive | outline"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes to merge"),
                        ApiRow("children...", "Any", "-", "Badge content (text, icons, etc.)"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute")
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

BadgePage
