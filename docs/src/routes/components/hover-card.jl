# HoverCard — Suite.jl component docs page
#
# Showcases HoverCard with hover-triggered content preview.
# 700ms open delay, 300ms close delay. Touch excluded. No focus trap.

const HoverCard = Main.HoverCard
const HoverCardTrigger = Main.HoverCardTrigger
const HoverCardContent = Main.HoverCardContent

function HoverCardPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Hover Card"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A popup that displays a content preview when hovering over a trigger element. Opens after 700ms, closes after 300ms. Touch devices excluded."
            )
        ),

        # Basic Preview
        ComponentPreview(title="Basic", description="Hover over the link to see a user profile card preview.",
            Div(:class => "w-full max-w-md",
                HoverCard(
                    HoverCardTrigger(
                        Span(:class => "text-accent-600 dark:text-accent-400 underline decoration-dotted underline-offset-4 cursor-pointer font-medium", "@julialang")
                    ),
                    HoverCardContent(
                        Div(:class => "flex gap-4",
                            Div(:class => "shrink-0",
                                Img(:src => "https://avatars.githubusercontent.com/u/743164?s=64", :alt => "Julia", :class => "h-12 w-12 rounded-full")
                            ),
                            Div(:class => "space-y-1",
                                H4(:class => "text-sm font-semibold text-warm-800 dark:text-warm-100", "@julialang"),
                                P(:class => "text-sm text-warm-600 dark:text-warm-400",
                                    "The Julia Programming Language. A fresh approach to technical computing."
                                ),
                                Div(:class => "flex items-center pt-2",
                                    Span(:class => "text-xs text-warm-500 dark:text-warm-400", "Joined December 2011")
                                )
                            )
                        )
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

HoverCard(
    HoverCardTrigger(
        Span("@julialang")
    ),
    HoverCardContent(
        Div(
            H4("@julialang"),
            P("The Julia Programming Language."),
        )
    ),
)""")
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "API Reference"
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "HoverCard"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Trigger and content sub-components (container only, no props)"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "HoverCardTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Trigger content (typically a link or text)"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "HoverCardContent"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("side", "String", "\"bottom\"", "Preferred side of the trigger to render against"),
                        ApiRow("align", "String", "\"center\"", "Preferred alignment against the trigger"),
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

HoverCardPage
