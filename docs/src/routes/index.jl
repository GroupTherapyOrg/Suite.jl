# Suite.jl docs landing page
#
# Mirrors shadcn/ui aesthetic: hero, feature grid, code example.
# Uses Suite.jl purple accent.

function Index()
    Fragment(
        # Hero Section
        Div(:class => "py-20 sm:py-28",
            Div(:class => "text-center",
                H1(:class => "text-4xl sm:text-6xl font-serif font-semibold text-warm-800 dark:text-warm-50 tracking-tight leading-tight",
                    "Beautifully Designed",
                    Br(),
                    Span(:class => "text-accent-600 dark:text-accent-400", "Components for Julia")
                ),
                P(:class => "mt-8 text-xl text-warm-600 dark:text-warm-300 max-w-2xl mx-auto leading-relaxed",
                    "Accessible. Composable. Pure Julia + WebAssembly. Build modern web interfaces with shadcn/ui-quality components, powered by Therapy.jl."
                ),
                Div(:class => "mt-12 flex justify-center gap-4",
                    A(:href => "./docs/",
                      :class => "bg-accent-600 hover:bg-accent-700 dark:bg-accent-500 dark:hover:bg-accent-400 text-white px-8 py-3 rounded-md font-medium transition-colors shadow-sm",
                      "Get Started"
                    ),
                    A(:href => "./components/",
                      :class => "bg-warm-200 dark:bg-warm-900 text-warm-800 dark:text-warm-300 px-8 py-3 rounded-md font-medium hover:bg-warm-300 dark:hover:bg-warm-800 transition-colors",
                      "Components"
                    )
                )
            )
        ),

        # Feature Grid
        Div(:class => "py-16 bg-warm-100 dark:bg-warm-900 rounded-lg border border-warm-200 dark:border-warm-700",
            H2(:class => "text-3xl font-serif font-semibold text-center text-warm-800 dark:text-warm-50 mb-12",
                "Why Suite.jl?"
            ),
            Div(:class => "grid md:grid-cols-3 gap-10 px-10",
                FeatureCard(
                    "shadcn/ui Parity",
                    "Every component matches shadcn/ui's behavior and accessibility. Button, Dialog, Select, DataTable — all the components you know.",
                    "M4 5a1 1 0 011-1h14a1 1 0 011 1v2a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 13a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H5a1 1 0 01-1-1v-6zM16 13a1 1 0 011-1h2a1 1 0 011 1v6a1 1 0 01-1 1h-2a1 1 0 01-1-1v-6z"
                ),
                FeatureCard(
                    "Copy-Paste Friendly",
                    "Own the code, not a dependency. Extract any component into your project and customize it freely. Just like shadcn/ui.",
                    "M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2m0 0h2a2 2 0 012 2v3m2 4H10m0 0l3-3m-3 3l3 3"
                ),
                FeatureCard(
                    "Pure Julia + Wasm",
                    "Write UI logic in Julia. Compile to WebAssembly for native-speed interactivity. No JavaScript framework required.",
                    "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"
                )
            )
        ),

        # Code Example
        Div(:class => "py-20",
            H2(:class => "text-3xl font-serif font-semibold text-center text-warm-800 dark:text-warm-50 mb-10",
                "Simple, Familiar API"
            ),
            Div(:class => "bg-warm-800 dark:bg-warm-950 rounded-md border border-warm-900 p-6 max-w-3xl mx-auto overflow-x-auto shadow-lg",
                Pre(:class => "text-sm text-warm-50",
                    Code(:class => "language-julia", """using Suite

# Use components directly — just like shadcn/ui
SuiteCard(
    SuiteCardHeader(
        SuiteCardTitle("Welcome"),
        SuiteCardDescription("Your new Julia web app")
    ),
    SuiteCardContent(
        SuiteButton(variant="default", "Get Started"),
        SuiteButton(variant="outline", "Learn More")
    )
)

# Or extract and customize:
# Suite.extract(:Card, "src/components/")""")
                )
            )
        ),

        # Component Categories
        Div(:class => "py-16",
            H2(:class => "text-3xl font-serif font-semibold text-center text-warm-800 dark:text-warm-50 mb-12",
                "50+ Components"
            ),
            Div(:class => "grid md:grid-cols-3 gap-6 max-w-4xl mx-auto",
                CategoryCard("Pure Styling", "~20 components", "Button, Badge, Card, Alert, Input, Table, Typography..."),
                CategoryCard("Interactive Islands", "~10 components", "Accordion, Tabs, Toggle, Switch, Slider, Checkbox..."),
                CategoryCard("JS Runtime", "~15 components", "Dialog, Menu, Popover, Tooltip, Select, Command, Toast...")
            )
        )
    )
end

function FeatureCard(title, description, icon_path)
    Div(:class => "text-center p-6",
        Div(:class => "w-12 h-12 bg-warm-200 dark:bg-warm-800 rounded-md border border-warm-200 dark:border-warm-700 flex items-center justify-center mx-auto mb-5",
            Svg(:class => "w-6 h-6 text-accent-600 dark:text-accent-400", :fill => "none", :viewBox => "0 0 24 24", :stroke => "currentColor", :stroke_width => "2",
                Path(:stroke_linecap => "round", :stroke_linejoin => "round", :d => icon_path)
            )
        ),
        H3(:class => "text-lg font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3", title),
        P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed", description)
    )
end

function CategoryCard(title, count, components)
    Div(:class => "border border-warm-200 dark:border-warm-700 rounded-lg p-6 bg-warm-100/50 dark:bg-warm-900/50",
        H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-50 mb-1", title),
        P(:class => "text-sm text-accent-600 dark:text-accent-400 mb-3", count),
        P(:class => "text-sm text-warm-600 dark:text-warm-400", components)
    )
end

# Export the page component
Index
