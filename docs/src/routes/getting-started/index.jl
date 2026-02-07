# Getting Started — Introduction to Suite.jl
#
# Overview of what Suite.jl is, how it works, and why you'd use it.

function GettingStartedIndex()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Introduction"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-400",
                "Suite.jl is a component library for Therapy.jl — beautifully designed, accessible, and copy-paste friendly."
            )
        ),

        # What is Suite.jl?
        Div(:class => "prose max-w-none",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mt-10 mb-4",
                "What is Suite.jl?"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Suite.jl is a collection of 50+ UI components built on ",
                A(:href => "https://github.com/TherapeuticJulia/Therapy.jl", :class => "text-accent-600 dark:text-accent-400 hover:underline", "Therapy.jl"),
                ", Julia's reactive web framework. It follows the ",
                A(:href => "https://ui.shadcn.com", :class => "text-accent-600 dark:text-accent-400 hover:underline", :target => "_blank", "shadcn/ui"),
                " philosophy: you own the code, not a dependency."
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-6",
                "Every component is accessible (WAI-ARIA compliant), supports light and dark mode, and uses the warm neutral design system shared across the GroupTherapyOrg ecosystem."
            ),

            # Key concepts
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mt-10 mb-4",
                "Key Concepts"
            ),

            # Extraction model
            H3(:class => "text-xl font-serif font-semibold text-warm-800 dark:text-warm-50 mt-8 mb-3",
                "Own the code"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Suite.jl works in two modes. You can use it as a package dependency, or you can extract components into your own project and customize them freely:"
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-100",
                    Code("""# Mode 1: Use as a package
using Suite
Button(variant="outline", "Click me")

# Mode 2: Extract and customize
Suite.extract(:Button, "src/components/")
# Now edit src/components/Button.jl however you want""")
                )
            ),

            # Three tiers
            H3(:class => "text-xl font-serif font-semibold text-warm-800 dark:text-warm-50 mt-8 mb-3",
                "Three implementation tiers"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Components are implemented in three tiers based on their interactivity needs:"
            ),
            Main.Table(
                Main.TableHeader(
                    Main.TableRow(
                        Main.TableHead("Tier"),
                        Main.TableHead("How it works"),
                        Main.TableHead("Examples")
                    )
                ),
                Main.TableBody(
                    Main.TableRow(
                        Main.TableCell(class="font-medium", "Pure Styling"),
                        Main.TableCell("Julia functions generating HTML + Tailwind CSS"),
                        Main.TableCell("Button, Card, Badge, Alert, Input")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium", "Interactive"),
                        Main.TableCell("JS runtime for keyboard nav and state toggling"),
                        Main.TableCell("Accordion, Tabs, Toggle, Switch")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium", "JS Runtime"),
                        Main.TableCell("Full behavioral JS for complex DOM interactions"),
                        Main.TableCell("Dialog, Menu, Popover, Select, Command")
                    )
                )
            ),

            # Themes
            H3(:class => "text-xl font-serif font-semibold text-warm-800 dark:text-warm-50 mt-8 mb-3",
                "Built-in themes"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Suite.jl ships with 4 pre-built themes. Apply a theme with a single keyword argument, or extract components with a theme baked in:"
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-100",
                    Code("""# Apply at render time
Button(theme=:ocean, variant="outline", "Ocean Style")

# Or extract with a theme baked in
Suite.extract(:Button, "components/", theme=:nature)""")
                )
            ),

            # Quick start
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mt-10 mb-4",
                "Quick Start"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Add Suite.jl to your Therapy.jl project:"
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-100",
                    Code("""using Pkg
Pkg.add(url="https://github.com/TherapeuticJulia/Suite.jl")""")
                )
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Then use components in your app:"
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-100",
                    Code("""using Therapy
using Suite

function MyPage()
    Card(
        CardHeader(
            CardTitle("Hello Suite.jl"),
            CardDescription("Your first component")
        ),
        CardContent(
            Button("Get Started")
        )
    )
end""")
                )
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "See the ",
                A(:href => "./getting-started/installation/", :class => "text-accent-600 dark:text-accent-400 hover:underline", "Installation guide"),
                " for detailed setup instructions, or browse the ",
                A(:href => "./components/", :class => "text-accent-600 dark:text-accent-400 hover:underline", "Components"),
                " to see what's available."
            )
        )
    )
end

GettingStartedIndex
