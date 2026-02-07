# Collapsible — Suite.jl component docs page
#
# Showcases Collapsible with open/closed states and trigger.


function CollapsiblePage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3",
                "Collapsible"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "An interactive component which expands/collapses a panel."
            )
        ),

        # Default Preview
        ComponentPreview(title="Default", description="Click the trigger to toggle content visibility.",
            Div(:class => "w-full max-w-sm",
                Main.Collapsible(
                    Main.CollapsibleTrigger(
                        Main.Button(variant="outline", size="sm", "Toggle content")
                    ),
                    Main.CollapsibleContent(
                        Div(:class => "mt-2 rounded-md border border-warm-200 dark:border-warm-700 p-4",
                            P(:class => "text-sm text-warm-600 dark:text-warm-400",
                                "This content can be shown or hidden by clicking the trigger above."
                            )
                        )
                    ),
                )
            )
        ),

        # Open by default
        ComponentPreview(title="Open by default", description="Start with the content visible.",
            Div(:class => "w-full max-w-sm",
                Main.Collapsible(open=true,
                    Main.CollapsibleTrigger(
                        Main.Button(variant="outline", size="sm", "Toggle")
                    ),
                    Main.CollapsibleContent(
                        Div(:class => "mt-2 rounded-md border border-warm-200 dark:border-warm-700 p-4",
                            P(:class => "text-sm text-warm-600 dark:text-warm-400",
                                "This content starts visible and can be collapsed."
                            )
                        )
                    ),
                )
            )
        ),

        # Disabled
        ComponentPreview(title="Disabled", description="A disabled collapsible that cannot be toggled.",
            Div(:class => "w-full max-w-sm",
                Main.Collapsible(disabled=true,
                    Main.CollapsibleTrigger(
                        Main.Button(variant="outline", size="sm", :disabled => true, "Cannot toggle")
                    ),
                    Main.CollapsibleContent(
                        Div(:class => "mt-2 rounded-md border border-warm-200 dark:border-warm-700 p-4",
                            P(:class => "text-sm text-warm-600 dark:text-warm-400",
                                "This content is hidden and cannot be revealed."
                            )
                        )
                    ),
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "Usage"
            ),
            Div(:class => "bg-warm-800 dark:bg-warm-950 rounded-md border border-warm-700 p-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-50",
                    Code(:class => "language-julia", """using Suite

Collapsible(
    CollapsibleTrigger(
        Button(variant="outline", "Toggle"),
    ),
    CollapsibleContent(
        Div("Hidden content revealed on click"),
    ),
)""")
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "API Reference"
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "Collapsible"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("open", "Bool", "false", "Start with content visible"),
                        ApiRow("disabled", "Bool", "false", "Prevent toggling"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "CollapsibleTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Trigger content (typically a button)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "CollapsibleContent"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Content to show/hide"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
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

CollapsiblePage
