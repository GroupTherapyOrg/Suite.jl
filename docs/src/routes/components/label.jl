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
        Div(:class => "mt-12 space-y-6",
            SectionH2("Usage"),
            Main.CodeBlock(language="julia", """using Suite

Label("Email", :for => "email")
Label("Username")""")
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
                        ApiRow("children...", "Any", "-", "Label text"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute (for, id, etc.)")
                    )
                )
            )
        )
    )
end


LabelPage
