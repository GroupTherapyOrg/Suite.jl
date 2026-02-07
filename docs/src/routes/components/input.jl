# Input — Suite.jl component docs page
#
# Showcases Input with types, states, and form patterns.


function InputPage()
    ComponentsLayout(
        # Header
        PageHeader("Input", "Displays a form input field or a component that looks like an input field."),

        # Default Preview
        ComponentPreview(title="Default", description="A default text input.",
            Main.Input(placeholder="Email", class="max-w-sm")
        ),

        # With Label
        ComponentPreview(title="With Label", description="Input paired with a label.",
            Div(:class => "grid w-full max-w-sm items-center gap-1.5",
                Main.Label("Email"),
                Main.Input(type="email", placeholder="Email")
            )
        ),

        # File Input
        ComponentPreview(title="File", description="Input for file uploads.",
            Div(:class => "grid w-full max-w-sm items-center gap-1.5",
                Main.Label("Picture"),
                Main.Input(type="file")
            )
        ),

        # Disabled
        ComponentPreview(title="Disabled", description="Input in disabled state.",
            Main.Input(disabled=true, placeholder="Disabled", class="max-w-sm")
        ),

        # Usage
        UsageBlock("""using Suite

Input(placeholder="Email")
Input(type="password", placeholder="Password")
Input(type="file")
Input(:disabled => true, placeholder="Disabled")"""),

        # API Reference
        ApiTable(
            ApiRow("type", "String", "\"text\"", "text | email | password | file | number | etc."),
            ApiRow("class", "String", "\"\"", "Additional CSS classes"),
            ApiRow("kwargs...", "Pair", "-", "Any HTML attribute (placeholder, disabled, id, etc.)"),
        )
    )
end


InputPage
