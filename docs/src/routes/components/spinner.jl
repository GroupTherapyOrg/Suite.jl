# Spinner — Suite.jl component docs page

function SpinnerPage()
    ComponentsLayout(
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3", "Spinner"),
            P(:class => "text-lg text-warm-600 dark:text-warm-300", "An animated loading spinner indicator.")
        ),

        # Sizes
        ComponentPreview(title="Sizes", description="Three sizes: sm, default, and lg.",
            Div(:class => "flex items-center gap-6",
                Div(:class => "flex flex-col items-center gap-2",
                    Main.Spinner(size="sm"),
                    Span(:class => "text-xs text-warm-500 dark:text-warm-400", "sm"),
                ),
                Div(:class => "flex flex-col items-center gap-2",
                    Main.Spinner(),
                    Span(:class => "text-xs text-warm-500 dark:text-warm-400", "default"),
                ),
                Div(:class => "flex flex-col items-center gap-2",
                    Main.Spinner(size="lg"),
                    Span(:class => "text-xs text-warm-500 dark:text-warm-400", "lg"),
                ),
            )
        ),

        # Custom color
        ComponentPreview(title="Custom Color", description="Override color with custom classes.",
            Div(:class => "flex items-center gap-6",
                Main.Spinner(class="text-accent-secondary-600"),
                Main.Spinner(class="text-blue-500"),
                Main.Spinner(class="text-green-500"),
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            SectionH2("Usage"),
            Main.CodeBlock(language="julia", """using Suite

Spinner()
Spinner(size="sm")
Spinner(size="lg")
Spinner(class="text-red-500")""")
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                    )),
                    Main.TableBody(
                        ApiRow("size", "String", "\"default\"", "Spinner size: \"sm\", \"default\", or \"lg\""),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("theme", "Symbol", ":default", "Theme preset"),
                    )
                )
            )
        )
    )
end


SpinnerPage
