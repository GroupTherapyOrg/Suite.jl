# Getting Started — Installation
#
# How to add Suite.jl to a Therapy.jl project.
# Shows both package mode and extraction mode.

function InstallationPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Installation"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-400",
                "How to add Suite.jl to your Therapy.jl project."
            )
        ),

        Div(:class => "prose max-w-none",

            # Prerequisites
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mt-10 mb-4",
                "Prerequisites"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Suite.jl requires:"
            ),
            Ul(:class => "list-disc list-inside space-y-2 text-warm-600 dark:text-warm-400 mb-6",
                Li("Julia 1.12 or later"),
                Li(
                    A(:href => "https://github.com/TherapeuticJulia/Therapy.jl", :class => "text-accent-600 dark:text-accent-400 hover:underline", "Therapy.jl"),
                    " — the reactive web framework"
                ),
                Li("A Therapy.jl app (created with the App framework)")
            ),

            # Installation
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mt-10 mb-4",
                "Add Suite.jl"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Add Suite.jl as a dependency to your project:"
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-100",
                    Code("""using Pkg
Pkg.add(url="https://github.com/TherapeuticJulia/Suite.jl")""")
                )
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Then add it to your app file:"
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-100",
                    Code("""using Therapy
using Suite

app = App(
    routes_dir = "src/routes",
    components_dir = "src/components",
    title = "My App"
)

Therapy.run(app)""")
                )
            ),

            # Tailwind CSS setup
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mt-10 mb-4",
                "Tailwind CSS Setup"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Suite.jl components use Tailwind CSS classes. Your app's ", Code(:class => "text-sm bg-warm-200 dark:bg-warm-800 px-1.5 py-0.5 rounded", "input.css"),
                " needs to include Suite.jl's source directories for Tailwind to scan:"
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-100",
                    Code("""/* input.css */
@import "tailwindcss";

/* Scan Suite.jl component files for Tailwind classes */
@source "../../Suite.jl/src";

/* Your app's routes and components are already scanned by Therapy.jl */""")
                )
            ),

            Main.Alert(
                Main.AlertTitle("Tip"),
                Main.AlertDescription("Therapy.jl's App framework handles Tailwind compilation automatically. You just need the @source directive to include Suite.jl's classes.")
            ),

            # Using components
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mt-10 mb-4",
                "Using Components"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Once installed, use any Suite.jl component in your routes:"
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-100",
                    Code("""# src/routes/index.jl
function HomePage()
    Div(:class => "max-w-md mx-auto py-12",
        Card(
            CardHeader(
                CardTitle("Welcome"),
                CardDescription("Your new Julia web app")
            ),
            CardContent(
                Div(:class => "grid gap-4",
                    Label("Name"),
                    Input(placeholder="Enter your name"),
                    Button("Submit")
                )
            )
        )
    )
end

HomePage""")
                )
            ),

            # Extraction
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mt-10 mb-4",
                "Extracting Components"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "The extraction model is Suite.jl's core feature — just like shadcn/ui, you can copy any component into your project and customize it freely:"
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-100",
                    Code("""using Suite

# Extract a single component
Suite.extract(:Button, "src/components/")

# Extract with dependencies (automatic)
Suite.extract(:Dialog, "src/components/")
# → Extracts Dialog.jl + Button.jl + utils.jl

# Extract with a theme baked in
Suite.extract(:Card, "src/components/", theme=:ocean)

# List all available components
Suite.list()

# Get info about a specific component
Suite.info(:Dialog)""")
                )
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Extracted components are self-contained Julia files. They use an ", Code(:class => "text-sm bg-warm-200 dark:bg-warm-800 px-1.5 py-0.5 rounded", "@isdefined"),
                " guard pattern so they work both via ", Code(:class => "text-sm bg-warm-200 dark:bg-warm-800 px-1.5 py-0.5 rounded", "using Suite"), " and via ", Code(:class => "text-sm bg-warm-200 dark:bg-warm-800 px-1.5 py-0.5 rounded", "include()"), " in your own project."
            ),

            # JS Runtime
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mt-10 mb-4",
                "JS Runtime"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Interactive components (Dialog, Menu, Tooltip, etc.) require the Suite.jl JavaScript runtime. Add it to your layout:"
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-100",
                    Code("""# src/components/Layout.jl
function Layout(children...)
    Div(:class => "min-h-screen",
        # Your navbar, content, footer...
        children...,

        # Suite.jl JS runtime (loads once, auto-discovers components)
        suite_script()
    )
end""")
                )
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "The ", Code(:class => "text-sm bg-warm-200 dark:bg-warm-800 px-1.5 py-0.5 rounded", "suite_script()"),
                " function injects the bundled JavaScript that powers focus traps, dismiss layers, floating positioning, keyboard navigation, and all other interactive behaviors. It loads once and auto-discovers components via ", Code(:class => "text-sm bg-warm-200 dark:bg-warm-800 px-1.5 py-0.5 rounded", "data-suite-*"), " attributes."
            ),

            # Next steps
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mt-10 mb-4",
                "Next Steps"
            ),
            Ul(:class => "list-disc list-inside space-y-2 text-warm-600 dark:text-warm-400 mb-6",
                Li(
                    A(:href => "./getting-started/theming/", :class => "text-accent-600 dark:text-accent-400 hover:underline", "Theming"),
                    " — Customize colors, radius, and fonts"
                ),
                Li(
                    A(:href => "./components/", :class => "text-accent-600 dark:text-accent-400 hover:underline", "Components"),
                    " — Browse all 50+ components"
                ),
                Li(
                    A(:href => "./components/button/", :class => "text-accent-600 dark:text-accent-400 hover:underline", "Button"),
                    " — Start with the most basic component"
                )
            )
        )
    )
end

InstallationPage
