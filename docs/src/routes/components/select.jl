# Select — Suite.jl component docs page
#
# Showcases SuiteSelect with basic usage, grouped items, and keyboard nav.

const SuiteSelect = Main.SuiteSelect
const SuiteSelectTrigger = Main.SuiteSelectTrigger
const SuiteSelectValue = Main.SuiteSelectValue
const SuiteSelectContent = Main.SuiteSelectContent
const SuiteSelectItem = Main.SuiteSelectItem
const SuiteSelectGroup = Main.SuiteSelectGroup
const SuiteSelectLabel = Main.SuiteSelectLabel
const SuiteSelectSeparator = Main.SuiteSelectSeparator
const SuiteSelectScrollUpButton = Main.SuiteSelectScrollUpButton
const SuiteSelectScrollDownButton = Main.SuiteSelectScrollDownButton

function SelectPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Select"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "Displays a list of options for the user to pick from, triggered by a button."
            )
        ),

        # Basic Preview
        ComponentPreview(title="Basic", description="A simple fruit selector with five options.",
            Div(:class => "w-full max-w-xs",
                SuiteSelect(
                    SuiteSelectTrigger(
                        SuiteSelectValue(placeholder="Select a fruit"),
                    ),
                    SuiteSelectContent(
                        SuiteSelectScrollUpButton(),
                        SuiteSelectItem(value="apple", "Apple"),
                        SuiteSelectItem(value="banana", "Banana"),
                        SuiteSelectItem(value="orange", "Orange"),
                        SuiteSelectItem(value="grape", "Grape"),
                        SuiteSelectItem(value="mango", "Mango"),
                        SuiteSelectScrollDownButton(),
                    ),
                )
            )
        ),

        # With Groups
        ComponentPreview(title="With Groups", description="Items organized into labeled groups with a separator.",
            Div(:class => "w-full max-w-xs",
                SuiteSelect(
                    SuiteSelectTrigger(
                        SuiteSelectValue(placeholder="Select an option"),
                    ),
                    SuiteSelectContent(
                        SuiteSelectScrollUpButton(),
                        SuiteSelectGroup(
                            SuiteSelectLabel("Fruits"),
                            SuiteSelectItem(value="apple", "Apple"),
                            SuiteSelectItem(value="banana", "Banana"),
                            SuiteSelectItem(value="orange", "Orange"),
                        ),
                        SuiteSelectSeparator(),
                        SuiteSelectGroup(
                            SuiteSelectLabel("Vegetables"),
                            SuiteSelectItem(value="carrot", "Carrot"),
                            SuiteSelectItem(value="broccoli", "Broccoli"),
                            SuiteSelectItem(value="spinach", "Spinach"),
                        ),
                        SuiteSelectScrollDownButton(),
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

SuiteSelect(
    SuiteSelectTrigger(
        SuiteSelectValue(placeholder="Select a fruit"),
    ),
    SuiteSelectContent(
        SuiteSelectItem(value="apple", "Apple"),
        SuiteSelectItem(value="banana", "Banana"),
        SuiteSelectItem(value="orange", "Orange"),
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
                        KeyRow("Arrow Down", "Move focus to the next item"),
                        KeyRow("Arrow Up", "Move focus to the previous item"),
                        KeyRow("Enter / Space", "Select the focused item"),
                        KeyRow("Escape", "Close the select dropdown"),
                        KeyRow("Home", "Move focus to the first item"),
                        KeyRow("End", "Move focus to the last item"),
                        KeyRow("Type-ahead", "Search by typing (1s timeout)"),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "API Reference"
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteSelect"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Select sub-components"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteSelectTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Trigger content (shows selected value)"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteSelectValue"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("placeholder", "String", "\"Select an option\"", "Text shown when no value is selected"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteSelectContent"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Content items and groups"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteSelectItem"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("value", "String", "-", "Unique value for this item (required)"),
                        ApiRow("disabled", "Bool", "false", "Disable this item"),
                        ApiRow("children...", "Any", "-", "Item display text"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteSelectGroup"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Group label and items (container)"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteSelectLabel"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Group label text"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteSelectSeparator"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteSelectScrollUpButton"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteSelectScrollDownButton"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
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

SelectPage
