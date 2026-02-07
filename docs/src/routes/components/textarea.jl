# Textarea — Suite.jl component docs page
#
# Showcases Textarea for multi-line text input.


function TextareaPage()
    ComponentsLayout(
        # Header
        PageHeader("Textarea", "Displays a form textarea or a component that looks like a textarea."),

        # Default Preview
        ComponentPreview(title="Default", description="A default textarea.",
            Main.Textarea(placeholder="Type your message here.", class="max-w-sm")
        ),

        # With Label
        ComponentPreview(title="With Label", description="Textarea paired with a label.",
            Div(:class => "grid w-full max-w-sm gap-1.5",
                Main.Label("Your message"),
                Main.Textarea(placeholder="Type your message here.")
            )
        ),

        # Disabled
        ComponentPreview(title="Disabled", description="Textarea in disabled state.",
            Main.Textarea(disabled=true, placeholder="Disabled", class="max-w-sm")
        ),

        # Usage
        UsageBlock("""using Suite

Textarea(placeholder="Type your message here.")
Textarea(:rows => "5", placeholder="Bio")
Textarea(:disabled => true, placeholder="Disabled")"""),

        # API Reference
        ApiTable(
            ApiRow("class", "String", "\"\"", "Additional CSS classes"),
            ApiRow("kwargs...", "Pair", "-", "Any HTML attribute (placeholder, rows, disabled, etc.)"),
        )
    )
end


TextareaPage
