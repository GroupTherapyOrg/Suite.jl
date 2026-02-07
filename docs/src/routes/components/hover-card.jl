# HoverCard — Suite.jl component docs page
#
# Showcases HoverCard with hover-triggered content preview.
# 700ms open delay, 300ms close delay. Touch excluded. No focus trap.


function HoverCardPage()
    ComponentsLayout(
        # Header
        PageHeader("Hover Card", "A popup that displays a content preview when hovering over a trigger element. Opens after 700ms, closes after 300ms. Touch devices excluded."),

        # Basic Preview
        ComponentPreview(title="Basic", description="Hover over the link to see a user profile card preview.",
            Div(:class => "w-full max-w-md",
                Main.HoverCard(
                    Main.HoverCardTrigger(
                        Span(:class => "text-accent-600 dark:text-accent-400 underline decoration-dotted underline-offset-4 cursor-pointer font-medium", "@julialang")
                    ),
                    Main.HoverCardContent(
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
        UsageBlock("""using Suite

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
)"""),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),
            SectionH3("HoverCard"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Trigger and content sub-components (container only, no props)"),
                    )
                )
            ),
            SectionH3("HoverCardTrigger"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Trigger content (typically a link or text)"),
                    )
                )
            ),
            SectionH3("HoverCardContent"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
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



HoverCardPage
