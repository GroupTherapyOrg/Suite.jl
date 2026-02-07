# Skeleton — Suite.jl component docs page
#
# Showcases Skeleton loading placeholder patterns.

const Skeleton = Main.Skeleton

function SkeletonPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Skeleton"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "Use to show a placeholder while content is loading."
            )
        ),

        # Default Preview
        ComponentPreview(title="Default", description="Basic skeleton shapes.",
            Div(:class => "space-y-4 w-full max-w-sm",
                Skeleton(class="h-4 w-[250px]"),
                Skeleton(class="h-4 w-[200px]"),
                Skeleton(class="h-4 w-[150px]")
            )
        ),

        # Card Skeleton
        ComponentPreview(title="Card", description="Skeleton mimicking a card layout.",
            Div(:class => "flex items-center space-x-4",
                Skeleton(class="h-12 w-12 rounded-full"),
                Div(:class => "space-y-2",
                    Skeleton(class="h-4 w-[250px]"),
                    Skeleton(class="h-4 w-[200px]")
                )
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

# Text line skeleton
Skeleton(class="h-4 w-[250px]")

# Circle avatar skeleton
Skeleton(class="h-12 w-12 rounded-full")

# Full-width block skeleton
Skeleton(class="h-[125px] w-full rounded-xl")""")
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
                        ApiRow("class", "String", "\"\"", "Size and shape classes (h-4, w-[250px], rounded-full, etc.)"),
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

SkeletonPage
