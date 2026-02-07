# CodeBlock — Suite.jl component docs page

function CodeBlockPage()
    ComponentsLayout(
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3", "Code Block"),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A styled code display container with copy-to-clipboard, language badge, and line numbers."
            )
        ),

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
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4", "Usage"),
            Div(:class => "bg-warm-800 dark:bg-warm-950 rounded-md border border-warm-700 p-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-50",
                    Code(:class => "language-julia", """using Suite

# With language badge
CodeBlock("println(\\"Hello\\")", language="julia")

# With line numbers
CodeBlock(code, language="julia", show_line_numbers=true)

# Without copy button
CodeBlock("simple", show_copy=false)""")
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4", "API Reference"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                    )),
                    Tbody(
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

function ApiRow(prop, type, default, description)
    Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
        Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", prop),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", type),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", default),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", description)
    )
end

CodeBlockPage
