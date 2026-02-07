# Toggle — Suite.jl component docs page
#
# Showcases Toggle with variants, sizes, and pressed state.


function TogglePage()
    ComponentsLayout(
        # Header
        PageHeader("Toggle", "A two-state button that can be either on or off."),

        # Default Preview
        ComponentPreview(title="Default", description="Click to toggle between pressed and unpressed states.",
            Div(:class => "flex items-center gap-4",
                Main.Toggle("B"),
                Main.Toggle("I"),
                Main.Toggle("U"),
            )
        ),

        # Pressed
        ComponentPreview(title="Pressed", description="A toggle that starts in the pressed state.",
            Main.Toggle(pressed=true, "Bold")
        ),

        # Variants
        ComponentPreview(title="Variants", description="Default and outline variants.",
            Div(:class => "flex items-center gap-4",
                Main.Toggle("Default"),
                Main.Toggle(variant="outline", "Outline"),
            )
        ),

        # Sizes
        ComponentPreview(title="Sizes", description="Small, default, and large sizes.",
            Div(:class => "flex items-center gap-4",
                Main.Toggle(size="sm", "Sm"),
                Main.Toggle("Default"),
                Main.Toggle(size="lg", "Lg"),
            )
        ),

        # Disabled
        ComponentPreview(title="Disabled", description="A disabled toggle that cannot be interacted with.",
            Main.Toggle(disabled=true, "Disabled")
        ),

        # Usage
        UsageBlock("""using Suite

Toggle("B")
Toggle(variant="outline", "I")
Toggle(pressed=true, "Bold")
Toggle(size="sm", disabled=true, "X")"""),

        # API Reference
        ApiTable(
            ApiRow("variant", "String", "\"default\"", "\"default\" or \"outline\""),
            ApiRow("size", "String", "\"default\"", "\"default\", \"sm\", or \"lg\""),
            ApiRow("pressed", "Bool", "false", "Initial pressed state"),
            ApiRow("disabled", "Bool", "false", "Disable the toggle"),
            ApiRow("class", "String", "\"\"", "Additional CSS classes"),
            ApiRow("children...", "Any", "-", "Toggle content (text, icons)"),
        )
    )
end



TogglePage
