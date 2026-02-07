# Carousel — Suite.jl component docs page

function CarouselPage()
    ComponentsLayout(
        PageHeader("Carousel", "A scrollable content slider with snap-point navigation, previous/next buttons, and keyboard support."),

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
                                            Span(:class => "text-3xl font-semibold text-warm-700 dark:text-warm-300", "1")
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
                                            Span(:class => "text-3xl font-semibold text-warm-700 dark:text-warm-300", "2")
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
                                            Span(:class => "text-3xl font-semibold text-warm-700 dark:text-warm-300", "3")
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
            SectionH2("Usage"),
            Main.CodeBlock(language="julia", """using Suite

Carousel(
    CarouselContent(
        CarouselItem(Card(CardContent(P("Slide 1")))),
        CarouselItem(Card(CardContent(P("Slide 2")))),
        CarouselItem(Card(CardContent(P("Slide 3")))),
    ),
    CarouselPrevious(),
    CarouselNext(),
)""")
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),

            SectionH3("Carousel"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                    )),
                    Main.TableBody(
                        ApiRow("orientation", "String", "\"horizontal\"", "Scroll direction: \"horizontal\" or \"vertical\""),
                        ApiRow("loop", "Bool", "false", "Whether to loop back to start"),
                        ApiRow("autoplay", "Bool", "false", "Whether to auto-advance slides"),
                        ApiRow("autoplay_interval", "Int", "4000", "Milliseconds between auto-advance"),
                        ApiRow("children", "Any", "-", "CarouselContent, CarouselPrevious, CarouselNext"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),

            SectionH3("Sub-components"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Component"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description"),
                    )),
                    Main.TableBody(
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 font-mono text-xs text-accent-600 dark:text-accent-400", "CarouselContent"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Scrollable container for carousel slides"),
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 font-mono text-xs text-accent-600 dark:text-accent-400", "CarouselItem"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "A single slide within the carousel"),
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 font-mono text-xs text-accent-600 dark:text-accent-400", "CarouselPrevious"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Previous slide navigation button"),
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 font-mono text-xs text-accent-600 dark:text-accent-400", "CarouselNext"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Next slide navigation button"),
                        ),
                    )
                )
            ),
        )
    )
end


CarouselPage
