# Examples Index — overview page linking to all example compositions

function ExamplesIndex()
    Div(:class => "max-w-4xl mx-auto py-12",
        # Header
        Div(:class => "mb-12",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Examples"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-400",
                "Full-page compositions showing Suite.jl components working together."
            )
        ),

        # Example cards
        Div(:class => "grid md:grid-cols-2 gap-6",
            _ExampleCard(
                "Dashboard",
                "A dashboard layout with stats cards, a data table, and recent activity feed.",
                "./examples/dashboard/"
            ),
            _ExampleCard(
                "Cards",
                "Various card compositions — profile, notification, payment, and settings.",
                "./examples/cards/"
            ),
            _ExampleCard(
                "Forms",
                "Login, signup, and settings forms with validation and styled inputs.",
                "./examples/forms/"
            ),
            _ExampleCard(
                "Widgets",
                "Interactive components as Pluto @bind widgets — switches, toggles, inputs.",
                "./examples/widgets/"
            )
        )
    )
end

function _ExampleCard(title, description, href)
    A(:href => href, :class => "group block",
        Main.Card(class="transition-colors group-hover:border-accent-300 dark:group-hover:border-accent-700",
            Main.CardHeader(
                Main.CardTitle(title),
                Main.CardDescription(description)
            ),
            Main.CardFooter(
                Span(:class => "text-sm text-accent-600 dark:text-accent-400 group-hover:underline", "View example →")
            )
        )
    )
end

ExamplesIndex
