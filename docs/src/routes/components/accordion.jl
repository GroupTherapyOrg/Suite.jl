# Accordion — Suite.jl component docs page
#
# Showcases Accordion with single/multiple modes, collapsible, and keyboard nav.


function AccordionPage()
    ComponentsLayout(
        # Header
        PageHeader("Accordion", "A vertically stacked set of interactive headings that each reveal a section of content."),

        # Default Preview
        ComponentPreview(title="Default", description="Single mode — one item open at a time.",
            Div(:class => "w-full max-w-md",
                Main.Accordion(default_value="item-1",
                    Main.AccordionItem(value="item-1",
                        Main.AccordionTrigger("Is it accessible?"),
                        Main.AccordionContent(P(:class => "text-sm text-warm-600 dark:text-warm-400 pb-4", "Yes. It adheres to the WAI-ARIA design pattern.")),
                    ),
                    Main.AccordionItem(value="item-2",
                        Main.AccordionTrigger("Is it styled?"),
                        Main.AccordionContent(P(:class => "text-sm text-warm-600 dark:text-warm-400 pb-4", "Yes. It comes with default styles that match the Suite.jl design system.")),
                    ),
                    Main.AccordionItem(value="item-3",
                        Main.AccordionTrigger("Is it animated?"),
                        Main.AccordionContent(P(:class => "text-sm text-warm-600 dark:text-warm-400 pb-4", "Yes. It uses CSS transitions for smooth expand/collapse.")),
                    ),
                )
            )
        ),

        # Multiple mode
        ComponentPreview(title="Multiple", description="Multiple items can be open simultaneously.",
            Div(:class => "w-full max-w-md",
                Main.Accordion(type="multiple",
                    Main.AccordionItem(value="item-1",
                        Main.AccordionTrigger("First section"),
                        Main.AccordionContent(P(:class => "text-sm text-warm-600 dark:text-warm-400 pb-4", "Content for the first section.")),
                    ),
                    Main.AccordionItem(value="item-2",
                        Main.AccordionTrigger("Second section"),
                        Main.AccordionContent(P(:class => "text-sm text-warm-600 dark:text-warm-400 pb-4", "Content for the second section.")),
                    ),
                )
            )
        ),

        # Collapsible
        ComponentPreview(title="Collapsible", description="Single mode with collapsible — all items can be closed.",
            Div(:class => "w-full max-w-md",
                Main.Accordion(collapsible=true,
                    Main.AccordionItem(value="item-1",
                        Main.AccordionTrigger("Click to expand"),
                        Main.AccordionContent(P(:class => "text-sm text-warm-600 dark:text-warm-400 pb-4", "Click the trigger again to collapse.")),
                    ),
                    Main.AccordionItem(value="item-2",
                        Main.AccordionTrigger("Another item"),
                        Main.AccordionContent(P(:class => "text-sm text-warm-600 dark:text-warm-400 pb-4", "Both items can be closed simultaneously.")),
                    ),
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            SectionH2("Usage"),
            Main.CodeBlock(language="julia", """using Suite

Accordion(default_value="item-1",
    AccordionItem(value="item-1",
        AccordionTrigger("Section 1"),
        AccordionContent(P("Content 1")),
    ),
    AccordionItem(value="item-2",
        AccordionTrigger("Section 2"),
        AccordionContent(P("Content 2")),
    ),
)""")
        ),

        # Keyboard shortcuts
        Div(:class => "mt-12 space-y-6",
            SectionH2("Keyboard Interactions"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(
                        Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Key"),
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Action")
                        )
                    ),
                    Main.TableBody(
                        KeyRow("Enter / Space", "Toggle the focused accordion item"),
                        KeyRow("Arrow Down", "Move focus to the next trigger"),
                        KeyRow("Arrow Up", "Move focus to the previous trigger"),
                        KeyRow("Home", "Move focus to the first trigger"),
                        KeyRow("End", "Move focus to the last trigger"),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),
            SectionH3("Accordion"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("type", "String", "\"single\"", "\"single\" or \"multiple\" — selection mode"),
                        ApiRow("collapsible", "Bool", "false", "Allow all items to be closed (single mode)"),
                        ApiRow("default_value", "String/Vector", "nothing", "Initially open item(s)"),
                        ApiRow("orientation", "String", "\"vertical\"", "\"vertical\" or \"horizontal\""),
                        ApiRow("disabled", "Bool", "false", "Disable all items"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("AccordionItem"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("value", "String", "\"\"", "Unique identifier for this item (required)"),
                        ApiRow("disabled", "Bool", "false", "Disable this specific item"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("AccordionTrigger"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Trigger content (text)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("AccordionContent"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Panel content"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
        )
    )
end




AccordionPage
