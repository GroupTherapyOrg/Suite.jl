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
        Div(:class => "mt-12 space-y-6",
            SectionH2("Usage"),
            Main.CodeBlock(language="julia", """using Suite

Textarea(placeholder="Type your message here.")
Textarea(:rows => "5", placeholder="Bio")
Textarea(:disabled => true, placeholder="Disabled")""")
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
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute (placeholder, rows, disabled, etc.)")
                    )
                )
            )
        )
    )
end


TextareaPage
