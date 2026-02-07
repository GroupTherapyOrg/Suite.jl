# CodeBlock — Suite.jl component docs page

function CodeBlockPage()
    ComponentsLayout(
        PageHeader("Code Block", "A styled code display container with copy-to-clipboard, language badge, and line numbers."),

        # Default
        ComponentPreview(title="Default", description="Code block with language badge and copy button.",
            Main.CodeBlock("using Suite\n\nButton(variant=\"outline\", \"Click me\")", language="julia")
        ),

        # With Line Numbers
        ComponentPreview(title="Line Numbers", description="Display line numbers alongside code.",
            Main.CodeBlock("function hello(name)\n    println(\"Hello, \$name!\")\nend\n\nhello(\"World\")", language="julia", show_line_numbers=true)
        ),

        # No Copy Button
        ComponentPreview(title="No Copy Button", description="Code display without copy functionality.",
            Main.CodeBlock("npm install therapy", language="bash", show_copy=false)
        ),

        # Minimal
        ComponentPreview(title="Minimal", description="Plain code block without header.",
            Main.CodeBlock("x = 42", show_copy=false)
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            SectionH2("Usage"),
            Main.CodeBlock(language="julia", """using Suite

# With language badge
CodeBlock("println(\\"Hello\\")", language="julia")

# With line numbers
CodeBlock(code, language="julia", show_line_numbers=true)

# Without copy button
CodeBlock("simple", show_copy=false)""")
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                    )),
                    Main.TableBody(
                        ApiRow("code", "String", "\"\"", "The code text to display"),
                        ApiRow("language", "String", "\"\"", "Language name shown as badge (e.g., \"julia\", \"bash\")"),
                        ApiRow("show_line_numbers", "Bool", "false", "Whether to display line numbers"),
                        ApiRow("show_copy", "Bool", "true", "Whether to show copy-to-clipboard button"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("theme", "Symbol", ":default", "Theme preset"),
                    )
                )
            )
        )
    )
end


CodeBlockPage
