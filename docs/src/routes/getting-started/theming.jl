# Getting Started — Theming
#
# How to customize Suite.jl's visual appearance using themes,
# color tokens, and fine-grained overrides.

function ThemingPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3",
                "Theming"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-400",
                "Customize Suite.jl's visual appearance with built-in themes and fine-grained overrides."
            )
        ),

        Div(:class => "prose max-w-none",

            # Overview
            SectionH2("How Themes Work"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "A theme is a named bundle of design tokens — accent color, border radius, font weight, shadow style, and more. Every Suite.jl component accepts a ", Code(:class => "text-sm bg-warm-200 dark:bg-warm-800 px-1.5 py-0.5 rounded", "theme"), " keyword argument."
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "When ", Code(:class => "text-sm bg-warm-200 dark:bg-warm-800 px-1.5 py-0.5 rounded", "theme=:default"),
                " (the default), there is zero overhead — the component renders its standard classes unchanged."
            ),

            # Pre-built themes
            SectionH2("Pre-built Themes"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Suite.jl ships with 4 pre-built themes:"
            ),
            Main.Table(
                Main.TableHeader(
                    Main.TableRow(
                        Main.TableHead("Theme"),
                        Main.TableHead("Accent"),
                        Main.TableHead("Neutral"),
                        Main.TableHead("Radius"),
                        Main.TableHead("Description")
                    )
                ),
                Main.TableBody(
                    Main.TableRow(
                        Main.TableCell(class="font-medium", Main.Badge(":default")),
                        Main.TableCell("Purple"),
                        Main.TableCell("Warm"),
                        Main.TableCell("rounded-md"),
                        Main.TableCell("Classic scholarly tones")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium", Main.Badge(variant="secondary", ":ocean")),
                        Main.TableCell("Blue"),
                        Main.TableCell("Warm"),
                        Main.TableCell("rounded-lg"),
                        Main.TableCell("Cool professional")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium", Main.Badge(variant="outline", ":minimal")),
                        Main.TableCell("Zinc"),
                        Main.TableCell("Slate"),
                        Main.TableCell("rounded-none"),
                        Main.TableCell("Sharp monospace-friendly")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium", Main.Badge(variant="outline", ":nature")),
                        Main.TableCell("Emerald"),
                        Main.TableCell("Stone"),
                        Main.TableCell("rounded-xl"),
                        Main.TableCell("Organic earthy tones")
                    )
                )
            ),

            # Usage
            SectionH2("Applying Themes"),

            # Runtime
            SectionH3("At render time"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Pass the ", Code(:class => "text-sm bg-warm-200 dark:bg-warm-800 px-1.5 py-0.5 rounded", "theme"), " kwarg to any component:"
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Main.CodeBlock(language="julia", """# Default theme (purple accent, warm neutrals, rounded-md)
Button("Default Theme")

# Ocean theme (blue accent, rounded-lg)
Button(theme=:ocean, "Ocean Theme")

# Minimal theme (zinc accent, no border radius)
Button(theme=:minimal, variant="outline", "Minimal Theme")

# Nature theme (emerald accent, rounded-xl)
Card(theme=:nature,
    CardHeader(CardTitle("Nature Theme")),
    CardContent("Emerald accents with stone neutrals")
)""")
            ),

            Main.Alert(
                Main.AlertTitle("Note"),
                Main.AlertDescription("Themes don't auto-propagate to children. Each component independently resolves its theme kwarg. Pass theme= to each component that should use the non-default theme.")
            ),

            # Extraction
            SectionH3("At extraction time"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "When extracting components, the theme is baked into the generated source code. The output file contains concrete Tailwind classes — no runtime theme lookup needed:"
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Main.CodeBlock(language="julia", """# Extract with ocean theme
Suite.extract(:Button, "src/components/", theme=:ocean)
# → Button.jl uses bg-blue-600 instead of bg-accent-600

# Extract with nature theme
Suite.extract(:Card, "src/components/", theme=:nature)
# → Card.jl uses rounded-xl, stone-* neutrals, emerald-* accents""")
            ),

            # Design tokens
            SectionH2("Design Tokens"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Each theme defines these tokens, which are substituted into component class strings:"
            ),
            Main.Table(
                Main.TableHeader(
                    Main.TableRow(
                        Main.TableHead("Token"),
                        Main.TableHead("Default"),
                        Main.TableHead("Ocean"),
                        Main.TableHead("Description")
                    )
                ),
                Main.TableBody(
                    Main.TableRow(
                        Main.TableCell(class="font-medium font-mono text-xs", "accent"),
                        Main.TableCell("purple (accent-*)"),
                        Main.TableCell("blue"),
                        Main.TableCell("Primary interactive color")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium font-mono text-xs", "accent_secondary"),
                        Main.TableCell("red (accent-secondary-*)"),
                        Main.TableCell("rose"),
                        Main.TableCell("Destructive/danger color")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium font-mono text-xs", "neutral"),
                        Main.TableCell("warm"),
                        Main.TableCell("warm"),
                        Main.TableCell("Background, border, text colors")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium font-mono text-xs", "radius"),
                        Main.TableCell("rounded-md"),
                        Main.TableCell("rounded-lg"),
                        Main.TableCell("Default border radius")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium font-mono text-xs", "ring"),
                        Main.TableCell("ring-accent-600"),
                        Main.TableCell("ring-blue-600"),
                        Main.TableCell("Focus ring color")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium font-mono text-xs", "font_weight"),
                        Main.TableCell("font-medium"),
                        Main.TableCell("font-medium"),
                        Main.TableCell("Default font weight")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-medium font-mono text-xs", "shadow"),
                        Main.TableCell("shadow-sm"),
                        Main.TableCell("shadow-md"),
                        Main.TableCell("Default shadow")
                    )
                )
            ),

            # Color mapping
            SectionH2("Color Token Mapping"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Suite.jl maps shadcn/ui's CSS variables to Tailwind utility classes:"
            ),
            Main.Table(
                Main.TableHeader(
                    Main.TableRow(
                        Main.TableHead("shadcn Variable"),
                        Main.TableHead("Suite.jl Token")
                    )
                ),
                Main.TableBody(
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "--background"),
                        Main.TableCell(class="font-mono text-xs", "bg-warm-50 dark:bg-warm-950")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "--foreground"),
                        Main.TableCell(class="font-mono text-xs", "text-warm-800 dark:text-warm-300")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "--primary"),
                        Main.TableCell(class="font-mono text-xs", "bg-accent-600 / text-accent-600")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "--card"),
                        Main.TableCell(class="font-mono text-xs", "bg-warm-100 dark:bg-warm-900")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "--border"),
                        Main.TableCell(class="font-mono text-xs", "border-warm-200 dark:border-warm-700")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "--destructive"),
                        Main.TableCell(class="font-mono text-xs", "bg-red-600 / text-red-600")
                    ),
                    Main.TableRow(
                        Main.TableCell(class="font-mono text-xs", "--ring"),
                        Main.TableCell(class="font-mono text-xs", "ring-accent-600")
                    )
                )
            ),

            # Dark mode
            SectionH2("Dark Mode"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Every Suite.jl component includes dark mode classes out of the box. Dark mode is toggled by adding the ", Code(:class => "text-sm bg-warm-200 dark:bg-warm-800 px-1.5 py-0.5 rounded", "dark"), " class to the ", Code(:class => "text-sm bg-warm-200 dark:bg-warm-800 px-1.5 py-0.5 rounded", "<html>"), " element."
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Use the ", Code(:class => "text-sm bg-warm-200 dark:bg-warm-800 px-1.5 py-0.5 rounded", "ThemeToggle"),
                " component to add a dark mode toggle to your app:"
            ),
            Div(:class => "bg-warm-900 dark:bg-warm-950 rounded-lg p-5 mb-6 overflow-x-auto",
                Main.CodeBlock(language="julia", """# In your Layout.jl navbar
ThemeToggle()  # Sun/moon toggle button

# Persists preference to localStorage
# Respects system prefers-color-scheme as default""")
            ),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "Therapy.jl's App framework includes a FOUC-prevention script in ", Code(:class => "text-sm bg-warm-200 dark:bg-warm-800 px-1.5 py-0.5 rounded", "<head>"),
                " that applies the saved theme before first paint."
            ),

            # Warm neutral palette
            SectionH2("Warm Neutral Palette"),
            P(:class => "text-warm-600 dark:text-warm-400 leading-relaxed mb-4",
                "The default theme uses a warm neutral palette shared across all GroupTherapyOrg packages:"
            ),
            Div(:class => "grid grid-cols-5 sm:grid-cols-11 gap-1 mb-6",
                _ColorSwatch("50", "bg-warm-50"),
                _ColorSwatch("100", "bg-warm-100"),
                _ColorSwatch("200", "bg-warm-200"),
                _ColorSwatch("300", "bg-warm-300"),
                _ColorSwatch("400", "bg-warm-400"),
                _ColorSwatch("500", "bg-warm-500"),
                _ColorSwatch("600", "bg-warm-600"),
                _ColorSwatch("700", "bg-warm-700"),
                _ColorSwatch("800", "bg-warm-800"),
                _ColorSwatch("900", "bg-warm-900"),
                _ColorSwatch("950", "bg-warm-950")
            ),

            # Accent palette
            SectionH3("Accent (Purple)"),
            Div(:class => "grid grid-cols-5 sm:grid-cols-11 gap-1 mb-6",
                _ColorSwatch("50", "bg-accent-50"),
                _ColorSwatch("100", "bg-accent-100"),
                _ColorSwatch("200", "bg-accent-200"),
                _ColorSwatch("300", "bg-accent-300"),
                _ColorSwatch("400", "bg-accent-400"),
                _ColorSwatch("500", "bg-accent-500"),
                _ColorSwatch("600", "bg-accent-600"),
                _ColorSwatch("700", "bg-accent-700"),
                _ColorSwatch("800", "bg-accent-800"),
                _ColorSwatch("900", "bg-accent-900"),
                _ColorSwatch("950", "bg-accent-950")
            )
        )
    )
end

function _ColorSwatch(shade, bg_class)
    Div(:class => "flex flex-col items-center gap-1",
        Div(:class => "w-full aspect-square rounded $(bg_class) border border-warm-200 dark:border-warm-700"),
        Span(:class => "text-[10px] text-warm-500 dark:text-warm-500", shade)
    )
end

ThemingPage
