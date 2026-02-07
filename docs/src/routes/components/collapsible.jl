# Collapsible — Suite.jl component docs page
#
# Showcases Collapsible with open/closed states and trigger.


function CollapsiblePage()
    ComponentsLayout(
        # Header
        PageHeader("Collapsible", "An interactive component which expands/collapses a panel."),

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
            SectionH2("Usage"),
            Main.CodeBlock(language="julia", """using Suite

Collapsible(
    CollapsibleTrigger(
        Button(variant="outline", "Toggle"),
    ),
    CollapsibleContent(
        Div("Hidden content revealed on click"),
    ),
)""")
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),
            SectionH3("Collapsible"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("open", "Bool", "false", "Start with content visible"),
                        ApiRow("disabled", "Bool", "false", "Prevent toggling"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("CollapsibleTrigger"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Trigger content (typically a button)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("CollapsibleContent"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Content to show/hide"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
        )
    )
end



CollapsiblePage
