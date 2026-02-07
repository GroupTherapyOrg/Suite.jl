# Typography — Suite.jl component docs page
#
# Showcases all typography components: headings, paragraphs, blockquote, code, etc.


function TypographyPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3",
                "Typography"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "Styles for headings, paragraphs, lists, and more."
            )
        ),

        # Headings
        ComponentPreview(title="Headings", description="Heading levels H1 through H4.",
            Div(:class => "space-y-4 w-full",
                Main.H1("This is H1"),
                Main.H2("This is H2"),
                Main.H3("This is H3"),
                Main.H4("This is H4")
            )
        ),

        # Paragraph
        ComponentPreview(title="Paragraph", description="Body text with proper leading.",
            Div(:class => "max-w-lg",
                Main.P("The king, seeing how much happier his subjects were, realized the error of his ways and declared a holiday."),
                Main.P("The people celebrated with feasts and festivities, and the kingdom prospered like never before.")
            )
        ),

        # Lead
        ComponentPreview(title="Lead", description="Larger introductory paragraph text.",
            Main.Lead("A component library for Julia. Beautifully designed. Copy and paste into your apps. Open Source.")
        ),

        # Blockquote
        ComponentPreview(title="Blockquote", description="Styled blockquote with left border.",
            Main.Blockquote("After all, everyone enjoys a good component library.")
        ),

        # Inline Code
        ComponentPreview(title="Inline Code", description="Inline code snippet.",
            P("Use the ", Main.InlineCode("Button"), " component for interactive actions.")
        ),

        # Large
        ComponentPreview(title="Large", description="Emphasized large text.",
            Main.Large("Are you absolutely sure?")
        ),

        # Small
        ComponentPreview(title="Small", description="Small text with medium weight.",
            Main.Small("Email address")
        ),

        # Muted
        ComponentPreview(title="Muted", description="Muted secondary text.",
            Main.Muted("Enter your email address.")
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "Usage"
            ),
            Main.CodeBlock(language="julia", """using Suite

H1("Page Title")
H2("Section Heading")
P("Body text paragraph.")
Lead("Introduction text.")
Blockquote("A notable quote.")
InlineCode("code_snippet()")
Large("Large text")
Small("Small label")
Muted("Muted hint text")""")
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "API Reference"
            ),
            P(:class => "text-sm text-warm-600 dark:text-warm-400 mb-4",
                "All typography components accept the same props:"
            ),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(
                        Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                        )
                    ),
                    Tbody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("children...", "Any", "-", "Text content"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute")
                    )
                )
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "Available Components"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(
                        Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Component"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "HTML Element"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                        )
                    ),
                    Tbody(
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "H1"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "h1"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Page title (4xl, extrabold)")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "H2"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "h2"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Section heading (3xl, border-bottom)")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "H3"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "h3"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Sub-section heading (2xl)")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "H4"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "h4"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Minor heading (xl)")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "P"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "p"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Body paragraph")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Blockquote"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "blockquote"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Styled blockquote with left border")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "InlineCode"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "code"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Inline code snippet")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Lead"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "p"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Lead intro paragraph (xl, muted)")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Large"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "div"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Large emphasized text")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Small"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "span"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Small text with medium weight")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Muted"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "p"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Muted secondary text")
                        )
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

TypographyPage
