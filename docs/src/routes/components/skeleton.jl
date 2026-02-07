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
        UsageBlock("""using Suite

# Text line skeleton
Skeleton(class="h-4 w-[250px]")

# Circle avatar skeleton
Skeleton(class="h-12 w-12 rounded-full")

# Full-width block skeleton
Skeleton(class="h-[125px] w-full rounded-xl")"""),

        # API Reference
        ApiTable(
            ApiRow("class", "String", "\"\"", "Size and shape classes (h-4, w-[250px], rounded-full, etc.)"),
            ApiRow("kwargs...", "Pair", "-", "Any HTML attribute"),
        )
    )
end


SkeletonPage
