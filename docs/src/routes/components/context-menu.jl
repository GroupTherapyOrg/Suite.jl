# Context Menu — Suite.jl component docs page
#
# Showcases SuiteContextMenu with basic items, checkboxes, radio groups, and keyboard nav.

const SuiteContextMenu = Main.SuiteContextMenu
const SuiteContextMenuTrigger = Main.SuiteContextMenuTrigger
const SuiteContextMenuContent = Main.SuiteContextMenuContent
const SuiteContextMenuGroup = Main.SuiteContextMenuGroup
const SuiteContextMenuLabel = Main.SuiteContextMenuLabel
const SuiteContextMenuItem = Main.SuiteContextMenuItem
const SuiteContextMenuCheckboxItem = Main.SuiteContextMenuCheckboxItem
const SuiteContextMenuRadioGroup = Main.SuiteContextMenuRadioGroup
const SuiteContextMenuRadioItem = Main.SuiteContextMenuRadioItem
const SuiteContextMenuItemIndicator = Main.SuiteContextMenuItemIndicator
const SuiteContextMenuSeparator = Main.SuiteContextMenuSeparator
const SuiteContextMenuShortcut = Main.SuiteContextMenuShortcut
const SuiteContextMenuSub = Main.SuiteContextMenuSub
const SuiteContextMenuSubTrigger = Main.SuiteContextMenuSubTrigger
const SuiteContextMenuSubContent = Main.SuiteContextMenuSubContent

function ContextMenuPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Context Menu"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "Displays a menu triggered by right-click (contextmenu event) or a 700ms touch long-press."
            )
        ),

        # Basic Preview
        ComponentPreview(title="Basic", description="Right-click the area to open a context menu with navigation items.",
            Div(:class => "w-full max-w-md",
                SuiteContextMenu(
                    SuiteContextMenuTrigger(
                        Div(:class => "flex h-36 w-full items-center justify-center rounded-md border border-dashed border-warm-300 dark:border-warm-600 text-sm text-warm-600 dark:text-warm-400",
                            "Right click here"
                        )
                    ),
                    SuiteContextMenuContent(
                        SuiteContextMenuItem("Back",
                            SuiteContextMenuShortcut("Ctrl+[")
                        ),
                        SuiteContextMenuItem("Forward",
                            SuiteContextMenuShortcut("Ctrl+]")
                        ),
                        SuiteContextMenuItem("Reload",
                            SuiteContextMenuShortcut("Ctrl+R")
                        ),
                        SuiteContextMenuSeparator(),
                        SuiteContextMenuItem("Bookmark",
                            SuiteContextMenuShortcut("Ctrl+D")
                        ),
                    )
                )
            )
        ),

        # With Checkboxes & Radio Group
        ComponentPreview(title="With Checkboxes", description="Context menu with checkbox items and a radio group.",
            Div(:class => "w-full max-w-md",
                SuiteContextMenu(
                    SuiteContextMenuTrigger(
                        Div(:class => "flex h-36 w-full items-center justify-center rounded-md border border-dashed border-warm-300 dark:border-warm-600 text-sm text-warm-600 dark:text-warm-400",
                            "Right click here"
                        )
                    ),
                    SuiteContextMenuContent(
                        SuiteContextMenuCheckboxItem(checked=true,
                            SuiteContextMenuItemIndicator(),
                            "Show Toolbar"
                        ),
                        SuiteContextMenuSeparator(),
                        SuiteContextMenuLabel("People"),
                        SuiteContextMenuRadioGroup(value="alice",
                            SuiteContextMenuRadioItem(value="alice",
                                SuiteContextMenuItemIndicator(),
                                "Alice"
                            ),
                            SuiteContextMenuRadioItem(value="bob",
                                SuiteContextMenuItemIndicator(),
                                "Bob"
                            ),
                            SuiteContextMenuRadioItem(value="charlie",
                                SuiteContextMenuItemIndicator(),
                                "Charlie"
                            ),
                        )
                    )
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

SuiteContextMenu(
    SuiteContextMenuTrigger(
        Div(:class => "flex h-36 w-full items-center justify-center rounded-md border border-dashed",
            "Right click here"
        )
    ),
    SuiteContextMenuContent(
        SuiteContextMenuItem("Back"),
        SuiteContextMenuItem("Forward"),
        SuiteContextMenuItem("Reload"),
        SuiteContextMenuSeparator(),
        SuiteContextMenuItem("Bookmark"),
    )
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
                        KeyRow("Enter / Space", "Activate the focused item"),
                        KeyRow("Escape", "Close the context menu"),
                        KeyRow("Arrow Right", "Open a submenu (when focused on a sub-trigger)"),
                        KeyRow("Arrow Left", "Close a submenu (when inside a submenu)"),
                        KeyRow("Type-ahead", "Focus an item by typing its label text"),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "API Reference"
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteContextMenu"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Trigger and content elements"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteContextMenuTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "The right-clickable area"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteContextMenuContent"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Menu items, separators, groups"),
                        ApiRow("align_offset", "Int", "0", "Offset from the alignment edge in pixels"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteContextMenuItem"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Item content (text, shortcuts)"),
                        ApiRow("disabled", "Bool", "false", "Disable this item"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteContextMenuCheckboxItem"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Item content"),
                        ApiRow("checked", "Bool", "false", "Whether the item is checked"),
                        ApiRow("disabled", "Bool", "false", "Disable this item"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteContextMenuRadioGroup"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Radio items"),
                        ApiRow("value", "String", "\"\"", "Currently selected value"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteContextMenuRadioItem"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Item content"),
                        ApiRow("value", "String", "\"\"", "Value for this radio option (required)"),
                        ApiRow("disabled", "Bool", "false", "Disable this item"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteContextMenuSub"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Sub-trigger and sub-content"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteContextMenuSubTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Trigger content"),
                        ApiRow("disabled", "Bool", "false", "Disable this trigger"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteContextMenuSubContent"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Submenu items"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteContextMenuGroup"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Grouped items"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteContextMenuLabel"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Label text"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteContextMenuSeparator"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteContextMenuShortcut"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Shortcut text (e.g. \"Ctrl+R\")"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteContextMenuItemIndicator"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Custom indicator content (optional)"),
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

ContextMenuPage
