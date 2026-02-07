# Badge — Suite.jl component docs page
#
# Showcases Badge with all variants and usage examples.


function BadgePage()
    ComponentsLayout(
        # Header
        PageHeader("Badge", "Displays a badge or a component that looks like a badge."),

        # Default Preview
        ComponentPreview(title="Default", description="The default badge with accent background.",
            Main.Badge("Badge")
        ),

        # All Variants
        ComponentPreview(title="Variants", description="All available badge variants.",
            Div(:class => "flex flex-wrap gap-4",
                Main.Badge(variant="default", "Default"),
                Main.Badge(variant="secondary", "Secondary"),
                Main.Badge(variant="outline", "Outline"),
                Main.Badge(variant="destructive", "Destructive")
            )
        ),

        # Usage
        UsageBlock("""using Suite

Badge("New")
Badge(variant="secondary", "Secondary")
Badge(variant="destructive", "Error")
Badge(variant="outline", "v2.0")"""),

        # API Reference
        ApiTable(
            ApiRow("variant", "String", "\"default\"", "default | secondary | destructive | outline"),
            ApiRow("class", "String", "\"\"", "Additional CSS classes to merge"),
            ApiRow("children...", "Any", "-", "Badge content (text, icons, etc.)"),
            ApiRow("kwargs...", "Pair", "-", "Any HTML attribute"),
        )
    )
end


BadgePage
