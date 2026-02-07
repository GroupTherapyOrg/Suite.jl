# Empty — Suite.jl component docs page

function EmptyPage()
    ComponentsLayout(
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3", "Empty"),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "An empty state placeholder for when there is no content to display."
            )
        ),

        # Default
        ComponentPreview(title="Default", description="Empty state with title and description.",
            Main.Empty(
                Main.EmptyTitle("No results found"),
                Main.EmptyDescription("Try adjusting your search or filter to find what you're looking for."),
            )
        ),

        # With Icon and Action
        ComponentPreview(title="With Icon and Action", description="Full empty state with icon, text, and action button.",
            Main.Empty(
                Main.EmptyIcon(
                    Svg(:xmlns => "http://www.w3.org/2000/svg", :width => "24", :height => "24", :viewBox => "0 0 24 24", :fill => "none", :stroke => "currentColor", :stroke_width => "2",
                        Path(:d => "M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"),
                        Path(:d => "M14 2v6h6"),
                    )
                ),
                Main.EmptyTitle("No notebooks open"),
                Main.EmptyDescription("Create a new notebook or open an existing one to get started."),
                Main.EmptyAction(
                    Main.Button(variant="default", "New Notebook")
                ),
            )
        ),

        # Minimal
        ComponentPreview(title="Minimal", description="Simple text-only empty state.",
            Main.Empty(
                Main.EmptyDescription("Nothing here yet."),
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            SectionH2("Usage"),
            Main.CodeBlock(language="julia", """using Suite

Empty(
    EmptyIcon(my_icon),
    EmptyTitle("No results found"),
    EmptyDescription("Try a different search query."),
    EmptyAction(Button("Try Again"))
)""")
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "Empty"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                    )),
                    Main.TableBody(
                        ApiRow("children", "Any", "-", "Sub-components (EmptyIcon, EmptyTitle, EmptyDescription, EmptyAction)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("theme", "Symbol", ":default", "Theme preset"),
                    )
                )
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "Sub-components"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Component"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description"),
                    )),
                    Main.TableBody(
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 font-mono text-xs text-accent-600 dark:text-accent-400", "EmptyIcon"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Icon or illustration wrapper (rounded circle bg)"),
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 font-mono text-xs text-accent-600 dark:text-accent-400", "EmptyTitle"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Title text (h3)"),
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 font-mono text-xs text-accent-600 dark:text-accent-400", "EmptyDescription"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Descriptive text (p)"),
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 font-mono text-xs text-accent-600 dark:text-accent-400", "EmptyAction"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Action slot (typically wraps a Button)"),
                        ),
                    )
                )
            ),
        )
    )
end


EmptyPage
