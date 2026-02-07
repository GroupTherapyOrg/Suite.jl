# Card — Suite.jl component docs page
#
# Showcases Card with all sub-components and composition patterns.


function CardPage()
    ComponentsLayout(
        # Header
        PageHeader("Card", "Displays a card with header, content, and footer."),

        # Default Preview
        ComponentPreview(title="Default", description="A simple card with header and content.",
            Main.Card(class="w-[350px]",
                Main.CardHeader(
                    Main.CardTitle("Card Title"),
                    Main.CardDescription("Card description text goes here.")
                ),
                Main.CardContent(
                    P(:class => "text-sm text-warm-600 dark:text-warm-400", "Your card content here.")
                )
            )
        ),

        # With Footer
        ComponentPreview(title="With Footer", description="Card with header, content, and footer actions.",
            Main.Card(class="w-[350px]",
                Main.CardHeader(
                    Main.CardTitle("Create project"),
                    Main.CardDescription("Deploy your new project in one-click.")
                ),
                Main.CardContent(
                    Div(:class => "space-y-4",
                        Div(:class => "space-y-2",
                            Main.Label("Name"),
                            Main.Input(placeholder="Name of your project")
                        ),
                        Div(:class => "space-y-2",
                            Main.Label("Framework"),
                            Main.Input(placeholder="Select a framework")
                        )
                    )
                ),
                Main.CardFooter(class="flex justify-between",
                    Main.Button(variant="outline", "Cancel"),
                    Main.Button("Deploy")
                )
            )
        ),

        # Usage
        UsageBlock("""using Suite

Card(
    CardHeader(
        CardTitle("Card Title"),
        CardDescription("Card description"),
    ),
    CardContent(
        P("Content goes here"),
    ),
    CardFooter(
        Button("Save"),
    ),
)"""),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),

            SectionH3("Card"),
            Div(:class => "overflow-x-auto",
                Main.Table(
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("children...", "Any", "-", "Card sections (Header, Content, Footer)"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute")
                    )
                )
            ),

            SectionH3("Sub-components"),
            P(:class => "text-sm text-warm-600 dark:text-warm-400 mb-4",
                "CardHeader, CardTitle, CardDescription, CardContent, and CardFooter all accept ",
                Main.InlineCode("class"),
                ", ",
                Main.InlineCode("children..."),
                ", and ",
                Main.InlineCode("kwargs..."),
                "."
            )
        )
    )
end


CardPage
