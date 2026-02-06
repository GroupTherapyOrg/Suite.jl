# Card — Suite.jl component docs page
#
# Showcases SuiteCard with all sub-components and composition patterns.

const SuiteCard = Main.SuiteCard
const SuiteCardHeader = Main.SuiteCardHeader
const SuiteCardTitle = Main.SuiteCardTitle
const SuiteCardDescription = Main.SuiteCardDescription
const SuiteCardContent = Main.SuiteCardContent
const SuiteCardFooter = Main.SuiteCardFooter

function CardPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Card"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "Displays a card with header, content, and footer."
            )
        ),

        # Default Preview
        ComponentPreview(title="Default", description="A simple card with header and content.",
            SuiteCard(class="w-[350px]",
                SuiteCardHeader(
                    SuiteCardTitle("Card Title"),
                    SuiteCardDescription("Card description text goes here.")
                ),
                SuiteCardContent(
                    P(:class => "text-sm text-warm-600 dark:text-warm-400", "Your card content here.")
                )
            )
        ),

        # With Footer
        ComponentPreview(title="With Footer", description="Card with header, content, and footer actions.",
            SuiteCard(class="w-[350px]",
                SuiteCardHeader(
                    SuiteCardTitle("Create project"),
                    SuiteCardDescription("Deploy your new project in one-click.")
                ),
                SuiteCardContent(
                    Div(:class => "space-y-4",
                        Div(:class => "space-y-2",
                            Main.SuiteLabel("Name"),
                            Main.SuiteInput(placeholder="Name of your project")
                        ),
                        Div(:class => "space-y-2",
                            Main.SuiteLabel("Framework"),
                            Main.SuiteInput(placeholder="Select a framework")
                        )
                    )
                ),
                SuiteCardFooter(class="flex justify-between",
                    Main.SuiteButton(variant="outline", "Cancel"),
                    Main.SuiteButton("Deploy")
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

SuiteCard(
    SuiteCardHeader(
        SuiteCardTitle("Card Title"),
        SuiteCardDescription("Card description"),
    ),
    SuiteCardContent(
        P("Content goes here"),
    ),
    SuiteCardFooter(
        SuiteButton("Save"),
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

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "SuiteCard"),
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
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("children...", "Any", "-", "Card sections (Header, Content, Footer)"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute")
                    )
                )
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "Sub-components"),
            P(:class => "text-sm text-warm-600 dark:text-warm-400 mb-4",
                "SuiteCardHeader, SuiteCardTitle, SuiteCardDescription, SuiteCardContent, and SuiteCardFooter all accept ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "class"),
                ", ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "children..."),
                ", and ",
                Code(:class => "text-xs bg-warm-100 dark:bg-warm-900 px-1 py-0.5 rounded", "kwargs..."),
                "."
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

CardPage
