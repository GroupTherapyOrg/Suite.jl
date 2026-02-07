# Menubar — Suite.jl component docs page
#
# Showcases SuiteMenubar with File/Edit/View menus, submenus, checkbox items, and keyboard nav.

const SuiteMenubar = Main.SuiteMenubar
const SuiteMenubarMenu = Main.SuiteMenubarMenu
const SuiteMenubarTrigger = Main.SuiteMenubarTrigger
const SuiteMenubarContent = Main.SuiteMenubarContent
const SuiteMenubarItem = Main.SuiteMenubarItem
const SuiteMenubarCheckboxItem = Main.SuiteMenubarCheckboxItem
const SuiteMenubarRadioGroup = Main.SuiteMenubarRadioGroup
const SuiteMenubarRadioItem = Main.SuiteMenubarRadioItem
const SuiteMenubarItemIndicator = Main.SuiteMenubarItemIndicator
const SuiteMenubarLabel = Main.SuiteMenubarLabel
const SuiteMenubarSeparator = Main.SuiteMenubarSeparator
const SuiteMenubarShortcut = Main.SuiteMenubarShortcut
const SuiteMenubarSub = Main.SuiteMenubarSub
const SuiteMenubarSubTrigger = Main.SuiteMenubarSubTrigger
const SuiteMenubarSubContent = Main.SuiteMenubarSubContent

function MenubarPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Menubar"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A visually persistent menu common in desktop applications that provides quick access to a consistent set of commands."
            )
        ),

        # Default Preview — File / Edit / View
        ComponentPreview(title="Default", description="Classic desktop-style menubar with File, Edit, and View menus.",
            Div(:class => "w-full max-w-lg",
                SuiteMenubar(
                    # File menu
                    SuiteMenubarMenu(
                        SuiteMenubarTrigger("File"),
                        SuiteMenubarContent(
                            SuiteMenubarItem("New Tab", SuiteMenubarShortcut("Ctrl+T")),
                            SuiteMenubarItem("New Window", SuiteMenubarShortcut("Ctrl+N")),
                            SuiteMenubarSeparator(),
                            SuiteMenubarSub(
                                SuiteMenubarSubTrigger("Share"),
                                SuiteMenubarSubContent(
                                    SuiteMenubarItem("Email"),
                                    SuiteMenubarItem("Messages"),
                                ),
                            ),
                            SuiteMenubarSeparator(),
                            SuiteMenubarItem("Print", SuiteMenubarShortcut("Ctrl+P")),
                        ),
                    ),

                    # Edit menu
                    SuiteMenubarMenu(
                        SuiteMenubarTrigger("Edit"),
                        SuiteMenubarContent(
                            SuiteMenubarItem("Undo", SuiteMenubarShortcut("Ctrl+Z")),
                            SuiteMenubarItem("Redo", SuiteMenubarShortcut("Ctrl+Shift+Z")),
                            SuiteMenubarSeparator(),
                            SuiteMenubarItem("Cut", SuiteMenubarShortcut("Ctrl+X")),
                            SuiteMenubarItem("Copy", SuiteMenubarShortcut("Ctrl+C")),
                            SuiteMenubarItem("Paste", SuiteMenubarShortcut("Ctrl+V")),
                        ),
                    ),

                    # View menu
                    SuiteMenubarMenu(
                        SuiteMenubarTrigger("View"),
                        SuiteMenubarContent(
                            SuiteMenubarCheckboxItem("Always Show Bookmarks", checked=true),
                            SuiteMenubarCheckboxItem("Always Show Full URLs"),
                        ),
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

SuiteMenubar(
    SuiteMenubarMenu(
        SuiteMenubarTrigger("File"),
        SuiteMenubarContent(
            SuiteMenubarItem("New Tab", SuiteMenubarShortcut("Ctrl+T")),
            SuiteMenubarItem("New Window"),
            SuiteMenubarSeparator(),
            SuiteMenubarSub(
                SuiteMenubarSubTrigger("Share"),
                SuiteMenubarSubContent(
                    SuiteMenubarItem("Email"),
                    SuiteMenubarItem("Messages"),
                ),
            ),
            SuiteMenubarSeparator(),
            SuiteMenubarItem("Print"),
        ),
    ),
    SuiteMenubarMenu(
        SuiteMenubarTrigger("View"),
        SuiteMenubarContent(
            SuiteMenubarCheckboxItem("Show Bookmarks", checked=true),
        ),
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
                        KeyRow("Arrow Right", "Move focus to the next menu trigger"),
                        KeyRow("Arrow Left", "Move focus to the previous menu trigger"),
                        KeyRow("Arrow Down", "Open the focused menu / move to next item"),
                        KeyRow("Arrow Up", "Move focus to the previous menu item"),
                        KeyRow("Enter / Space", "Activate the focused menu item"),
                        KeyRow("Escape", "Close the open menu"),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "API Reference"
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteMenubar"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "SuiteMenubarMenu items"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteMenubarMenu"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Trigger + Content pair"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteMenubarTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Trigger label text"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteMenubarContent"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Menu items, separators, labels, submenus"),
                        ApiRow("align", "String", "\"start\"", "Alignment relative to trigger"),
                        ApiRow("side_offset", "Int", "5", "Distance from trigger in pixels"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteMenubarItem"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Item label and optional shortcut"),
                        ApiRow("disabled", "Bool", "false", "Disable this item"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteMenubarCheckboxItem"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Checkbox label text"),
                        ApiRow("checked", "Bool", "false", "Whether the item is checked"),
                        ApiRow("disabled", "Bool", "false", "Disable this item"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteMenubarRadioGroup"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "SuiteMenubarRadioItem children"),
                        ApiRow("value", "String", "\"\"", "Currently selected value"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteMenubarRadioItem"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Radio item label"),
                        ApiRow("value", "String", "\"\"", "Value for this radio option"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteMenubarSeparator"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteMenubarShortcut"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Shortcut text (e.g. \"Ctrl+T\")"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteMenubarSub"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "SubTrigger + SubContent pair"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteMenubarSubTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Sub-menu trigger label"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteMenubarSubContent"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Sub-menu items"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteMenubarLabel"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Label text"),
                        ApiRow("inset", "Bool", "false", "Add left padding to align with items"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteMenubarItemIndicator"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Indicator content (icon or check)"),
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

MenubarPage
