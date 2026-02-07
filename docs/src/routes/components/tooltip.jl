# Tooltip — Suite.jl component docs page
#
# Showcases Tooltip with basic hover, multiple tooltips, and shared delay via provider.


function TooltipPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Tooltip"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A popup that displays information related to an element when the element receives keyboard focus or the mouse hovers over it."
            )
        ),

        # Basic Preview
        ComponentPreview(title="Basic", description="Hover over the button to see tooltip text.",
            Div(:class => "w-full max-w-md flex items-center justify-center",
                Main.TooltipProvider(
                    Main.Tooltip(
                        Main.TooltipTrigger(
                            Button(:class => "inline-flex items-center justify-center rounded-md bg-accent-600 px-4 py-2 text-sm font-medium text-white hover:bg-accent-700", "Hover me")
                        ),
                        Main.TooltipContent(side="top",
                            P(:class => "text-sm", "Add to library")
                        ),
                    )
                )
            )
        ),

        # Multiple Tooltips
        ComponentPreview(title="Multiple Tooltips", description="Wrap all in a TooltipProvider for shared delay state. Consecutive tooltips open instantly within the skip window.",
            Div(:class => "w-full max-w-md flex items-center justify-center gap-4",
                Main.TooltipProvider(
                    Main.Tooltip(
                        Main.TooltipTrigger(
                            Button(:class => "inline-flex items-center justify-center rounded-md border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-800 px-4 py-2 text-sm font-medium text-warm-800 dark:text-warm-200 hover:bg-warm-100 dark:hover:bg-warm-700", "Bold")
                        ),
                        Main.TooltipContent(side="bottom",
                            P(:class => "text-sm", "Toggle bold")
                        ),
                    ),
                    Main.Tooltip(
                        Main.TooltipTrigger(
                            Button(:class => "inline-flex items-center justify-center rounded-md border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-800 px-4 py-2 text-sm font-medium text-warm-800 dark:text-warm-200 hover:bg-warm-100 dark:hover:bg-warm-700", "Italic")
                        ),
                        Main.TooltipContent(side="bottom",
                            P(:class => "text-sm", "Toggle italic")
                        ),
                    ),
                    Main.Tooltip(
                        Main.TooltipTrigger(
                            Button(:class => "inline-flex items-center justify-center rounded-md border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-800 px-4 py-2 text-sm font-medium text-warm-800 dark:text-warm-200 hover:bg-warm-100 dark:hover:bg-warm-700", "Underline")
                        ),
                        Main.TooltipContent(side="bottom",
                            P(:class => "text-sm", "Toggle underline")
                        ),
                    ),
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

TooltipProvider(
    Tooltip(
        TooltipTrigger(
            Button("Hover me"),
        ),
        TooltipContent(
            P("Add to library"),
        ),
    ),
)""")
                )
            )
        ),

        # Keyboard shortcuts
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "Keyboard Interactions"
            ),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(
                        Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Key"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Action")
                        )
                    ),
                    Tbody(
                        KeyRow("Tab", "Focus the trigger element to open the tooltip"),
                        KeyRow("Escape", "Dismisses the tooltip immediately"),
                    )
                )
            )
        ),

        # Accessibility Notes
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "Accessibility"
            ),
            Div(:class => "space-y-2 text-sm text-warm-600 dark:text-warm-400",
                P("Uses ", Code(:class => "font-mono text-xs text-accent-600 dark:text-accent-400", "role=\"tooltip\""), " and ", Code(:class => "font-mono text-xs text-accent-600 dark:text-accent-400", "aria-describedby"), " to associate the tooltip content with its trigger."),
                P("Opens on hover or focus after a 700ms delay. Consecutive tooltips within a shared provider open instantly during the 300ms skip window."),
                P("Touch devices are excluded — tooltips are not shown on tap."),
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "API Reference"
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "TooltipProvider"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("delay_duration", "Int", "700", "Delay in ms before the tooltip opens on hover"),
                        ApiRow("skip_delay_duration", "Int", "300", "Duration in ms of the skip window for consecutive tooltips"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "Tooltip"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Trigger and content sub-components"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "TooltipTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "The element that triggers the tooltip on hover/focus"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "TooltipContent"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("side", "String", "\"top\"", "Preferred side of the trigger to render (\"top\", \"right\", \"bottom\", \"left\")"),
                        ApiRow("side_offset", "Int", "4", "Distance in px from the trigger"),
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

function KeyRow(key, action)
    Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
        Td(:class => "py-3 px-4 font-mono text-xs text-warm-800 dark:text-warm-200", key),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", action)
    )
end

TooltipPage
