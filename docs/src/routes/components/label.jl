# Label — Suite.jl component docs page
#
# Showcases Label for form field labels.


function LabelPage()
    ComponentsLayout(
        # Header
        PageHeader("Label", "Renders an accessible label associated with controls."),

        # Default Preview
        ComponentPreview(title="Default", description="A label paired with an input.",
            Div(:class => "grid w-full max-w-sm items-center gap-1.5",
                Main.Label("Email"),
                Main.Input(type="email", placeholder="Email")
            )
        ),

        # Usage
        UsageBlock("""using Suite

Label("Email", :for => "email")
Label("Username")"""),

        # API Reference
        ApiTable(
            ApiRow("class", "String", "\"\"", "Additional CSS classes"),
            ApiRow("children...", "Any", "-", "Label text"),
            ApiRow("kwargs...", "Pair", "-", "Any HTML attribute (for, id, etc.)"),
        )
    )
end


LabelPage
