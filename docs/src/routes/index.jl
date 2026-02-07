# Suite.jl docs landing page
#
# Mirrors shadcn/ui aesthetic: hero, component showcase, code example, stats.
# Uses Suite.jl purple accent and warm neutrals.

function Index()
    Fragment(
        # Hero Section
        Div(:class => "py-20 sm:py-32",
            Div(:class => "text-center max-w-4xl mx-auto",
                Div(:class => "inline-flex items-center gap-2 border border-warm-200 dark:border-warm-700 bg-warm-100 dark:bg-warm-900 rounded-full px-4 py-1.5 mb-8",
                    Span(:class => "text-xs font-medium text-warm-600 dark:text-warm-400", "Open Source"),
                    Span(:class => "text-warm-300 dark:text-warm-600", "/"),
                    Span(:class => "text-xs font-medium text-accent-600 dark:text-accent-400", "50+ Components")
                ),
                H1(:class => "text-4xl sm:text-6xl lg:text-7xl font-serif font-semibold text-warm-800 dark:text-warm-300 tracking-tight leading-[1.1]",
                    "Build your Julia",
                    Br(),
                    "web app with ",
                    Span(:class => "text-accent-600 dark:text-accent-400", "Suite"),
                    Span(:class => "text-warm-400 dark:text-warm-600 text-4xl sm:text-5xl lg:text-6xl font-light",
                        Span(:class => "text-[#4063d8]/30 dark:text-[#4063d8]/45", "."),
                        Span(:class => "text-[#389826]/30 dark:text-[#389826]/45", "j"),
                        Span(:class => "text-[#cb3c33]/30 dark:text-[#cb3c33]/45", "l")
                    )
                ),
                P(:class => "mt-8 text-lg sm:text-xl text-warm-600 dark:text-warm-400 max-w-2xl mx-auto leading-relaxed",
                    "Accessible, composable UI components for Therapy.jl. Extract, customize, and own the code ", Em("just like shadcn/ui"), "."
                ),
                Div(:class => "mt-10 flex flex-col sm:flex-row justify-center gap-4",
                    Main.Button(variant="default", class="h-12 px-8 text-base",
                        A(:href => "./getting-started/", :class => "text-white no-underline", "Get Started")
                    ),
                    Main.Button(variant="outline", class="h-12 px-8 text-base",
                        A(:href => "./components/", :class => "no-underline text-warm-800 dark:text-warm-300", "Browse Components")
                    )
                )
            )
        ),

        # Component Showcase — live rendered Suite.jl components
        Div(:class => "py-16",
            H2(:class => "text-3xl font-serif font-semibold text-center text-warm-800 dark:text-warm-300 mb-4",
                "Components that just work"
            ),
            P(:class => "text-center text-warm-600 dark:text-warm-400 mb-12 max-w-lg mx-auto",
                "Every component is accessible, dark-mode ready, and designed with warm neutrals."
            ),
            # Two-column showcase grid
            Div(:class => "grid lg:grid-cols-2 gap-6 max-w-5xl mx-auto",

                # Card 1: Buttons
                _ShowcaseCard("Buttons",
                    Div(:class => "flex flex-wrap gap-3 items-center",
                        Main.Button(variant="default", "Default"),
                        Main.Button(variant="secondary", "Secondary"),
                        Main.Button(variant="outline", "Outline"),
                        Main.Button(variant="ghost", "Ghost"),
                        Main.Button(variant="link", "Link"),
                        Main.Button(variant="destructive", size="sm", "Delete")
                    )
                ),

                # Card 2: Badges + Alert
                _ShowcaseCard("Badges & Alerts",
                    Div(:class => "space-y-4",
                        Div(:class => "flex flex-wrap gap-2",
                            Main.Badge("Default"),
                            Main.Badge(variant="secondary", "Secondary"),
                            Main.Badge(variant="outline", "Outline"),
                            Main.Badge(variant="destructive", "Destructive")
                        ),
                        Main.Alert(
                            Main.AlertTitle("Heads up!"),
                            Main.AlertDescription("Suite.jl components are accessible and dark-mode ready by default.")
                        )
                    )
                ),

                # Card 3: Card composition
                _ShowcaseCard("Cards",
                    Main.Card(class="bg-warm-50 dark:bg-warm-950",
                        Main.CardHeader(
                            Main.CardTitle("Create project"),
                            Main.CardDescription("Deploy a new Julia application.")
                        ),
                        Main.CardContent(
                            Div(:class => "grid gap-4",
                                Div(:class => "grid gap-2",
                                    Main.Label("Name"),
                                    Main.Input(placeholder="My Julia App")
                                ),
                                Div(:class => "grid gap-2",
                                    Main.Label("Framework"),
                                    Main.Input(placeholder="Therapy.jl")
                                )
                            )
                        ),
                        Main.CardFooter(class="flex justify-between",
                            Main.Button(variant="outline", "Cancel"),
                            Main.Button("Create")
                        )
                    )
                ),

                # Card 4: Form inputs
                _ShowcaseCard("Inputs & Forms",
                    Div(:class => "space-y-4",
                        Div(:class => "grid gap-2",
                            Main.Label("Email"),
                            Main.Input(type="email", placeholder="you@example.com")
                        ),
                        Div(:class => "grid gap-2",
                            Main.Label("Message"),
                            Main.Textarea(placeholder="Type your message here...")
                        ),
                        Div(:class => "flex items-center gap-4",
                            Main.Button("Submit"),
                            Main.Button(variant="ghost", "Cancel")
                        )
                    )
                ),

                # Card 5: Table
                _ShowcaseCard("Tables",
                    Main.Table(
                        Main.TableHeader(
                            Main.TableRow(
                                Main.TableHead("Component"),
                                Main.TableHead("Tier"),
                                Main.TableHead(class="text-right", "Tests")
                            )
                        ),
                        Main.TableBody(
                            Main.TableRow(
                                Main.TableCell(class="font-medium", "Button"),
                                Main.TableCell("Pure Styling"),
                                Main.TableCell(class="text-right", "62")
                            ),
                            Main.TableRow(
                                Main.TableCell(class="font-medium", "Dialog"),
                                Main.TableCell("JS Runtime"),
                                Main.TableCell(class="text-right", "103")
                            ),
                            Main.TableRow(
                                Main.TableCell(class="font-medium", "Calendar"),
                                Main.TableCell("JS Runtime"),
                                Main.TableCell(class="text-right", "119")
                            )
                        )
                    )
                ),

                # Card 6: Progress + Skeleton + Typography
                _ShowcaseCard("Progress & Loading",
                    Div(:class => "space-y-6",
                        Div(:class => "space-y-2",
                            Div(:class => "flex justify-between text-sm text-warm-600 dark:text-warm-400",
                                Span("Loading..."),
                                Span("75%")
                            ),
                            Main.Progress(value=75)
                        ),
                        Div(:class => "space-y-3",
                            Main.Skeleton(class="h-4 w-full"),
                            Main.Skeleton(class="h-4 w-3/4"),
                            Main.Skeleton(class="h-4 w-1/2")
                        ),
                        Div(:class => "flex items-center gap-4",
                            Main.Avatar(
                                Main.AvatarFallback("JL")
                            ),
                            Div(
                                P(:class => "text-sm font-medium text-warm-800 dark:text-warm-300", "Julia Developer"),
                                P(:class => "text-xs text-warm-500 dark:text-warm-500", "using Suite")
                            )
                        )
                    )
                )
            )
        ),

        # Extraction-First Code Example
        Div(:class => "py-20",
            H2(:class => "text-3xl font-serif font-semibold text-center text-warm-800 dark:text-warm-300 mb-4",
                "Own your components"
            ),
            P(:class => "text-center text-warm-600 dark:text-warm-400 mb-10 max-w-lg mx-auto",
                "Extract any component into your project. Customize it freely. No lock-in."
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-xl border border-warm-800 dark:border-warm-800 p-8 max-w-3xl mx-auto overflow-x-auto shadow-xl",
                Div(:class => "flex items-center gap-2 mb-5",
                    Span(:class => "w-3 h-3 rounded-full bg-red-500/60"),
                    Span(:class => "w-3 h-3 rounded-full bg-yellow-500/60"),
                    Span(:class => "w-3 h-3 rounded-full bg-green-500/60")
                ),
                Main.CodeBlock(language="julia", """using Suite

# Extract and customize — just like shadcn/ui
Suite.extract(:Card, "src/components/")

# Then use your own copy:
Card(
    CardHeader(
        CardTitle("Welcome"),
        CardDescription("Your new Julia web app")
    ),
    CardContent(
        Button(variant="default", "Get Started"),
        Button(variant="outline", "Learn More")
    )
)""")
            )
        ),

        # Feature Grid
        Div(:class => "py-16",
            H2(:class => "text-3xl font-serif font-semibold text-center text-warm-800 dark:text-warm-300 mb-12",
                "Why Suite.jl?"
            ),
            Div(:class => "grid md:grid-cols-3 gap-10 max-w-5xl mx-auto px-4",
                _FeatureCard(
                    "shadcn/ui Parity",
                    "Every component matches shadcn/ui behavior, styling, and accessibility. If you know shadcn, you know Suite.jl.",
                    "M4 5a1 1 0 011-1h14a1 1 0 011 1v2a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 13a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H5a1 1 0 01-1-1v-6zM16 13a1 1 0 011-1h2a1 1 0 011 1v6a1 1 0 01-1 1h-2a1 1 0 01-1-1v-6z"
                ),
                _FeatureCard(
                    "Copy-Paste Friendly",
                    "Own the code, not a dependency. Extract any component into your project and customize it freely.",
                    "M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2m0 0h2a2 2 0 012 2v3m2 4H10m0 0l3-3m-3 3l3 3"
                ),
                _FeatureCard(
                    "Accessible by Default",
                    "WAI-ARIA compliant. Keyboard navigation. Focus management. Screen reader friendly. No extra work needed.",
                    "M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"
                ),
                _FeatureCard(
                    "Dark Mode Built-in",
                    "Every component ships with light and dark mode. Toggle with one click. No configuration required.",
                    "M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"
                ),
                _FeatureCard(
                    "4 Built-in Themes",
                    "Default, Ocean, Minimal, Nature. Apply a theme in one kwarg. Extract with a theme baked in.",
                    "M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01"
                ),
                _FeatureCard(
                    "Pure Julia + Wasm",
                    "Write UI logic in Julia. Compile to WebAssembly for interactivity. No JavaScript framework required.",
                    "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"
                )
            )
        ),

        # Stats bar
        Div(:class => "py-12 border-y border-warm-200 dark:border-warm-700",
            Div(:class => "grid grid-cols-2 md:grid-cols-4 gap-8 max-w-4xl mx-auto text-center",
                _StatItem("50+", "Components"),
                _StatItem("2000+", "Tests"),
                _StatItem("3", "Tiers"),
                _StatItem("4", "Themes")
            )
        ),

        # Component Categories — kept but updated counts
        Div(:class => "py-16",
            H2(:class => "text-3xl font-serif font-semibold text-center text-warm-800 dark:text-warm-300 mb-12",
                "Three Implementation Tiers"
            ),
            Div(:class => "grid md:grid-cols-3 gap-6 max-w-4xl mx-auto",
                _CategoryCard("Pure Styling", "~20 components", "Button, Badge, Card, Alert, Input, Table, Typography, Breadcrumb, Pagination..."),
                _CategoryCard("Interactive", "~10 components", "Accordion, Tabs, Toggle, Switch, Collapsible, Toggle Group..."),
                _CategoryCard("JS Runtime", "~20 components", "Dialog, Menu, Popover, Tooltip, Select, Command, Toast, Calendar, DataTable...")
            )
        )
    )
end

# --- Helper components ---

function _ShowcaseCard(title, children...)
    Div(:class => "border border-warm-200 dark:border-warm-700 rounded-xl bg-warm-100 dark:bg-warm-900 overflow-hidden",
        Div(:class => "px-5 py-3 border-b border-warm-200 dark:border-warm-700",
            Span(:class => "text-sm font-medium text-warm-600 dark:text-warm-400", title)
        ),
        Div(:class => "p-5",
            children...
        )
    )
end

function _FeatureCard(title, description, icon_path)
    Div(:class => "text-center p-6",
        Div(:class => "w-12 h-12 bg-warm-100 dark:bg-warm-800 rounded-lg border border-warm-200 dark:border-warm-700 flex items-center justify-center mx-auto mb-5",
            Svg(:class => "w-6 h-6 text-accent-600 dark:text-accent-400", :fill => "none", :viewBox => "0 0 24 24", :stroke => "currentColor", :stroke_width => "1.5",
                Path(:stroke_linecap => "round", :stroke_linejoin => "round", :d => icon_path)
            )
        ),
        H3(:class => "text-lg font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3", title),
        P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed text-sm", description)
    )
end

function _CategoryCard(title, count, components)
    Main.Card(class="bg-warm-100/50 dark:bg-warm-900/50",
        Main.CardHeader(
            Main.CardTitle(title),
            Main.CardDescription(
                Span(:class => "text-sm font-medium text-accent-600 dark:text-accent-400", count)
            )
        ),
        Main.CardContent(
            P(:class => "text-sm text-warm-600 dark:text-warm-400", components)
        )
    )
end

function _StatItem(number, label)
    Div(
        P(:class => "text-3xl sm:text-4xl font-serif font-bold text-accent-600 dark:text-accent-400", number),
        P(:class => "text-sm text-warm-600 dark:text-warm-400 mt-1", label)
    )
end

# Export the page component
Index
