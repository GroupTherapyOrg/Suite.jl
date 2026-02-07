# Toggle — Suite.jl component docs page
#
# Showcases Toggle with variants, sizes, and pressed state.

const Toggle = Main.Toggle

function TogglePage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Toggle"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A two-state button that can be either on or off."
            )
        ),

        # Default Preview
        ComponentPreview(title="Default", description="Click to toggle between pressed and unpressed states.",
            Div(:class => "flex items-center gap-4",
                Toggle("B"),
                Toggle("I"),
                Toggle("U"),
            )
        ),

        # Pressed
        ComponentPreview(title="Pressed", description="A toggle that starts in the pressed state.",
            Toggle(pressed=true, "Bold")
        ),

        # Variants
        ComponentPreview(title="Variants", description="Default and outline variants.",
            Div(:class => "flex items-center gap-4",
                Toggle("Default"),
                Toggle(variant="outline", "Outline"),
            )
        ),

        # Sizes
        ComponentPreview(title="Sizes", description="Small, default, and large sizes.",
            Div(:class => "flex items-center gap-4",
                Toggle(size="sm", "Sm"),
                Toggle("Default"),
                Toggle(size="lg", "Lg"),
            )
        ),

        # Disabled
        ComponentPreview(title="Disabled", description="A disabled toggle that cannot be interacted with.",
            Toggle(disabled=true, "Disabled")
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "Usage"
            ),
            Div(:class => "bg-warm-800 dark:bg-warm-950 rounded-md border border-warm-700 p-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-50",
                    Code(:class => "language-julia", """using Suite

Toggle("B")
Toggle(variant="outline", "I")
Toggle(pressed=true, "Bold")
Toggle(size="sm", disabled=true, "X")""")
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
                        ApiRow("variant", "String", "\"default\"", "\"default\" or \"outline\""),
                        ApiRow("size", "String", "\"default\"", "\"default\", \"sm\", or \"lg\""),
                        ApiRow("pressed", "Bool", "false", "Initial pressed state"),
                        ApiRow("disabled", "Bool", "false", "Disable the toggle"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("children...", "Any", "-", "Toggle content (text, icons)"),
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

TogglePage
