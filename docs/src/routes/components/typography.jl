# Typography — Suite.jl component docs page
#
# Showcases all typography components: headings, paragraphs, blockquote, code, etc.


function TypographyPage()
    ComponentsLayout(
        # Header
        PageHeader("Typography", "Styles for headings, paragraphs, lists, and more."),

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
            SectionH2("Usage"),
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
            SectionH2("API Reference"),
            P(:class => "text-sm text-warm-600 dark:text-warm-400 mb-4",
                "All typography components accept the same props:"
            ),
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
                        ApiRow("children...", "Any", "-", "Text content"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute")
                    )
                )
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "Available Components"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(
                        Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Component"),
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "HTML Element"),
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                        )
                    ),
                    Main.TableBody(
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "H1"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "h1"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Page title (4xl, extrabold)")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "H2"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "h2"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Section heading (3xl, border-bottom)")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "H3"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "h3"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Sub-section heading (2xl)")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "H4"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "h4"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Minor heading (xl)")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "P"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "p"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Body paragraph")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Blockquote"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "blockquote"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Styled blockquote with left border")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "InlineCode"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "code"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Inline code snippet")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Lead"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "p"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Lead intro paragraph (xl, muted)")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Large"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "div"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Large emphasized text")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Small"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "span"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Small text with medium weight")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Muted"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", "p"),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Muted secondary text")
                        )
                    )
                )
            )
        )
    )
end


TypographyPage
