# Skeleton — Suite.jl component docs page
#
# Showcases Skeleton loading placeholder patterns.


function SkeletonPage()
    ComponentsLayout(
        # Header
        PageHeader("Skeleton", "Use to show a placeholder while content is loading."),

        # Default Preview
        ComponentPreview(title="Default", description="Basic skeleton shapes.",
            Div(:class => "space-y-4 w-full max-w-sm",
                Main.Skeleton(class="h-4 w-[250px]"),
                Main.Skeleton(class="h-4 w-[200px]"),
                Main.Skeleton(class="h-4 w-[150px]")
            )
        ),

        # Card Skeleton
        ComponentPreview(title="Card", description="Skeleton mimicking a card layout.",
            Div(:class => "flex items-center space-x-4",
                Main.Skeleton(class="h-12 w-12 rounded-full"),
                Div(:class => "space-y-2",
                    Main.Skeleton(class="h-4 w-[250px]"),
                    Main.Skeleton(class="h-4 w-[200px]")
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            SectionH2("Usage"),
            Main.CodeBlock(language="julia", """using Suite

# Text line skeleton
Skeleton(class="h-4 w-[250px]")

# Circle avatar skeleton
Skeleton(class="h-12 w-12 rounded-full")

# Full-width block skeleton
Skeleton(class="h-[125px] w-full rounded-xl")""")
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(
                        Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                        )
                    ),
                    Main.TableBody(
                        ApiRow("class", "String", "\"\"", "Size and shape classes (h-4, w-[250px], rounded-full, etc.)"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute")
                    )
                )
            )
        )
    )
end


SkeletonPage
