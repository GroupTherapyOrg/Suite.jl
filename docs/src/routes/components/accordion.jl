# Accordion — Suite.jl component docs page
#
# Showcases SuiteAccordion with single/multiple modes, collapsible, and keyboard nav.

const SuiteAccordion = Main.SuiteAccordion
const SuiteAccordionItem = Main.SuiteAccordionItem
const SuiteAccordionTrigger = Main.SuiteAccordionTrigger
const SuiteAccordionContent = Main.SuiteAccordionContent

function AccordionPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Accordion"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A vertically stacked set of interactive headings that each reveal a section of content."
            )
        ),

        # Default Preview
        ComponentPreview(title="Default", description="Single mode — one item open at a time.",
            Div(:class => "w-full max-w-md",
                SuiteAccordion(default_value="item-1",
                    SuiteAccordionItem(value="item-1",
                        SuiteAccordionTrigger("Is it accessible?"),
                        SuiteAccordionContent(P(:class => "text-sm text-warm-600 dark:text-warm-400 pb-4", "Yes. It adheres to the WAI-ARIA design pattern.")),
                    ),
                    SuiteAccordionItem(value="item-2",
                        SuiteAccordionTrigger("Is it styled?"),
                        SuiteAccordionContent(P(:class => "text-sm text-warm-600 dark:text-warm-400 pb-4", "Yes. It comes with default styles that match the Suite.jl design system.")),
                    ),
                    SuiteAccordionItem(value="item-3",
                        SuiteAccordionTrigger("Is it animated?"),
                        SuiteAccordionContent(P(:class => "text-sm text-warm-600 dark:text-warm-400 pb-4", "Yes. It uses CSS transitions for smooth expand/collapse.")),
                    ),
                )
            )
        ),

        # Multiple mode
        ComponentPreview(title="Multiple", description="Multiple items can be open simultaneously.",
            Div(:class => "w-full max-w-md",
                SuiteAccordion(type="multiple",
                    SuiteAccordionItem(value="item-1",
                        SuiteAccordionTrigger("First section"),
                        SuiteAccordionContent(P(:class => "text-sm text-warm-600 dark:text-warm-400 pb-4", "Content for the first section.")),
                    ),
                    SuiteAccordionItem(value="item-2",
                        SuiteAccordionTrigger("Second section"),
                        SuiteAccordionContent(P(:class => "text-sm text-warm-600 dark:text-warm-400 pb-4", "Content for the second section.")),
                    ),
                )
            )
        ),

        # Collapsible
        ComponentPreview(title="Collapsible", description="Single mode with collapsible — all items can be closed.",
            Div(:class => "w-full max-w-md",
                SuiteAccordion(collapsible=true,
                    SuiteAccordionItem(value="item-1",
                        SuiteAccordionTrigger("Click to expand"),
                        SuiteAccordionContent(P(:class => "text-sm text-warm-600 dark:text-warm-400 pb-4", "Click the trigger again to collapse.")),
                    ),
                    SuiteAccordionItem(value="item-2",
                        SuiteAccordionTrigger("Another item"),
                        SuiteAccordionContent(P(:class => "text-sm text-warm-600 dark:text-warm-400 pb-4", "Both items can be closed simultaneously.")),
                    ),
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "Usage"
            ),
            Div(:class => "bg-warm-800 dark:bg-warm-950 rounded-md border border-warm-700 p-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-50",
                    Code(:class => "language-julia", """using Suite

SuiteAccordion(default_value="item-1",
    SuiteAccordionItem(value="item-1",
        SuiteAccordionTrigger("Section 1"),
        SuiteAccordionContent(P("Content 1")),
    ),
    SuiteAccordionItem(value="item-2",
        SuiteAccordionTrigger("Section 2"),
        SuiteAccordionContent(P("Content 2")),
    ),
)""")
                )
            )
        ),

        # Keyboard shortcuts
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "Keyboard Interactions"
            ),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(
                        Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Key"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Action")
                        )
                    ),
                    Tbody(
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
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "API Reference"
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteAccordion"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("type", "String", "\"single\"", "\"single\" or \"multiple\" — selection mode"),
                        ApiRow("collapsible", "Bool", "false", "Allow all items to be closed (single mode)"),
                        ApiRow("default_value", "String/Vector", "nothing", "Initially open item(s)"),
                        ApiRow("orientation", "String", "\"vertical\"", "\"vertical\" or \"horizontal\""),
                        ApiRow("disabled", "Bool", "false", "Disable all items"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteAccordionItem"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("value", "String", "\"\"", "Unique identifier for this item (required)"),
                        ApiRow("disabled", "Bool", "false", "Disable this specific item"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteAccordionTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Trigger content (text)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteAccordionContent"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Panel content"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
        )
    )
end

function ApiHead()
    Tr(:class => "border-b border-warm-200 dark:border-warm-700",
        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
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

function KeyRow(key, action)
    Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
        Td(:class => "py-3 px-4 font-mono text-xs text-warm-800 dark:text-warm-200", key),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", action)
    )
end

AccordionPage
