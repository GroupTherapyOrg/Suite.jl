# Carousel — Suite.jl component docs page

function CarouselPage()
    ComponentsLayout(
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3", "Carousel"),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A scrollable content slider with snap-point navigation, previous/next buttons, and keyboard support."
            )
        ),

        # Default
        ComponentPreview(title="Default", description="Carousel with three slides and navigation buttons.",
            Div(:class => "w-full max-w-lg mx-auto",
                Main.Carousel(
                    Main.CarouselContent(
                        Main.CarouselItem(
                            Div(:class => "flex items-center justify-center h-48 rounded-lg bg-warm-100 dark:bg-warm-800",
                                Span(:class => "text-2xl font-semibold text-warm-600 dark:text-warm-300", "Slide 1")
                            )
                        ),
                        Main.CarouselItem(
                            Div(:class => "flex items-center justify-center h-48 rounded-lg bg-warm-100 dark:bg-warm-800",
                                Span(:class => "text-2xl font-semibold text-warm-600 dark:text-warm-300", "Slide 2")
                            )
                        ),
                        Main.CarouselItem(
                            Div(:class => "flex items-center justify-center h-48 rounded-lg bg-warm-100 dark:bg-warm-800",
                                Span(:class => "text-2xl font-semibold text-warm-600 dark:text-warm-300", "Slide 3")
                            )
                        ),
                    ),
                    Main.CarouselPrevious(),
                    Main.CarouselNext(),
                )
            )
        ),

        # With Cards
        ComponentPreview(title="With Cards", description="Carousel slides containing Card components.",
            Div(:class => "w-full max-w-lg mx-auto",
                Main.Carousel(
                    Main.CarouselContent(
                        Main.CarouselItem(
                            Div(:class => "p-1",
                                Main.Card(
                                    Main.CardContent(
                                        Div(:class => "flex items-center justify-center p-6",
                                            Span(:class => "text-3xl font-semibold text-warm-700 dark:text-warm-200", "1")
                                        )
                                    )
                                )
                            )
                        ),
                        Main.CarouselItem(
                            Div(:class => "p-1",
                                Main.Card(
                                    Main.CardContent(
                                        Div(:class => "flex items-center justify-center p-6",
                                            Span(:class => "text-3xl font-semibold text-warm-700 dark:text-warm-200", "2")
                                        )
                                    )
                                )
                            )
                        ),
                        Main.CarouselItem(
                            Div(:class => "p-1",
                                Main.Card(
                                    Main.CardContent(
                                        Div(:class => "flex items-center justify-center p-6",
                                            Span(:class => "text-3xl font-semibold text-warm-700 dark:text-warm-200", "3")
                                        )
                                    )
                                )
                            )
                        ),
                    ),
                    Main.CarouselPrevious(),
                    Main.CarouselNext(),
                )
            )
        ),

        # Loop
        ComponentPreview(title="Loop", description="Carousel that loops back to the beginning.",
            Div(:class => "w-full max-w-lg mx-auto",
                Main.Carousel(loop=true,
                    Main.CarouselContent(
                        Main.CarouselItem(
                            Div(:class => "flex items-center justify-center h-48 rounded-lg bg-warm-100 dark:bg-warm-800",
                                Span(:class => "text-2xl font-semibold text-warm-600 dark:text-warm-300", "Slide A")
                            )
                        ),
                        Main.CarouselItem(
                            Div(:class => "flex items-center justify-center h-48 rounded-lg bg-warm-100 dark:bg-warm-800",
                                Span(:class => "text-2xl font-semibold text-warm-600 dark:text-warm-300", "Slide B")
                            )
                        ),
                        Main.CarouselItem(
                            Div(:class => "flex items-center justify-center h-48 rounded-lg bg-warm-100 dark:bg-warm-800",
                                Span(:class => "text-2xl font-semibold text-warm-600 dark:text-warm-300", "Slide C")
                            )
                        ),
                    ),
                    Main.CarouselPrevious(),
                    Main.CarouselNext(),
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4", "Usage"),
            Div(:class => "bg-warm-800 dark:bg-warm-950 rounded-md border border-warm-700 p-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-50",
                    Code(:class => "language-julia", """using Suite

Carousel(
    CarouselContent(
        CarouselItem(Card(CardContent(P("Slide 1")))),
        CarouselItem(Card(CardContent(P("Slide 2")))),
        CarouselItem(Card(CardContent(P("Slide 3")))),
    ),
    CarouselPrevious(),
    CarouselNext(),
)""")
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4", "API Reference"),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-50 mt-6 mb-3", "Carousel"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                    )),
                    Tbody(
                        ApiRow("orientation", "String", "\"horizontal\"", "Scroll direction: \"horizontal\" or \"vertical\""),
                        ApiRow("loop", "Bool", "false", "Whether to loop back to start"),
                        ApiRow("autoplay", "Bool", "false", "Whether to auto-advance slides"),
                        ApiRow("autoplay_interval", "Int", "4000", "Milliseconds between auto-advance"),
                        ApiRow("children", "Any", "-", "CarouselContent, CarouselPrevious, CarouselNext"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-50 mt-6 mb-3", "Sub-components"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Component"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description"),
                    )),
                    Tbody(
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs text-accent-600 dark:text-accent-400", "CarouselContent"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Scrollable container for carousel slides"),
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs text-accent-600 dark:text-accent-400", "CarouselItem"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "A single slide within the carousel"),
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs text-accent-600 dark:text-accent-400", "CarouselPrevious"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Previous slide navigation button"),
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs text-accent-600 dark:text-accent-400", "CarouselNext"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Next slide navigation button"),
                        ),
                    )
                )
            ),
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

CarouselPage
