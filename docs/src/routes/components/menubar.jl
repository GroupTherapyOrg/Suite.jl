# Menubar — Suite.jl component docs page
#
# Showcases Menubar with File/Edit/View menus, submenus, checkbox items, and keyboard nav.

const Menubar = Main.Menubar
const MenubarMenu = Main.MenubarMenu
const MenubarTrigger = Main.MenubarTrigger
const MenubarContent = Main.MenubarContent
const MenubarItem = Main.MenubarItem
const MenubarCheckboxItem = Main.MenubarCheckboxItem
const MenubarRadioGroup = Main.MenubarRadioGroup
const MenubarRadioItem = Main.MenubarRadioItem
const MenubarItemIndicator = Main.MenubarItemIndicator
const MenubarLabel = Main.MenubarLabel
const MenubarSeparator = Main.MenubarSeparator
const MenubarShortcut = Main.MenubarShortcut
const MenubarSub = Main.MenubarSub
const MenubarSubTrigger = Main.MenubarSubTrigger
const MenubarSubContent = Main.MenubarSubContent

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
                Menubar(
                    # File menu
                    MenubarMenu(
                        MenubarTrigger("File"),
                        MenubarContent(
                            MenubarItem("New Tab", MenubarShortcut("Ctrl+T")),
                            MenubarItem("New Window", MenubarShortcut("Ctrl+N")),
                            MenubarSeparator(),
                            MenubarSub(
                                MenubarSubTrigger("Share"),
                                MenubarSubContent(
                                    MenubarItem("Email"),
                                    MenubarItem("Messages"),
                                ),
                            ),
                            MenubarSeparator(),
                            MenubarItem("Print", MenubarShortcut("Ctrl+P")),
                        ),
                    ),

                    # Edit menu
                    MenubarMenu(
                        MenubarTrigger("Edit"),
                        MenubarContent(
                            MenubarItem("Undo", MenubarShortcut("Ctrl+Z")),
                            MenubarItem("Redo", MenubarShortcut("Ctrl+Shift+Z")),
                            MenubarSeparator(),
                            MenubarItem("Cut", MenubarShortcut("Ctrl+X")),
                            MenubarItem("Copy", MenubarShortcut("Ctrl+C")),
                            MenubarItem("Paste", MenubarShortcut("Ctrl+V")),
                        ),
                    ),

                    # View menu
                    MenubarMenu(
                        MenubarTrigger("View"),
                        MenubarContent(
                            MenubarCheckboxItem("Always Show Bookmarks", checked=true),
                            MenubarCheckboxItem("Always Show Full URLs"),
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

Menubar(
    MenubarMenu(
        MenubarTrigger("File"),
        MenubarContent(
            MenubarItem("New Tab", MenubarShortcut("Ctrl+T")),
            MenubarItem("New Window"),
            MenubarSeparator(),
            MenubarSub(
                MenubarSubTrigger("Share"),
                MenubarSubContent(
                    MenubarItem("Email"),
                    MenubarItem("Messages"),
                ),
            ),
            MenubarSeparator(),
            MenubarItem("Print"),
        ),
    ),
    MenubarMenu(
        MenubarTrigger("View"),
        MenubarContent(
            MenubarCheckboxItem("Show Bookmarks", checked=true),
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
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "Menubar"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "MenubarMenu items"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "MenubarMenu"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Trigger + Content pair"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "MenubarTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Trigger label text"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "MenubarContent"),
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
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "MenubarItem"),
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
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "MenubarCheckboxItem"),
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
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "MenubarRadioGroup"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "MenubarRadioItem children"),
                        ApiRow("value", "String", "\"\"", "Currently selected value"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "MenubarRadioItem"),
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
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "MenubarSeparator"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "MenubarShortcut"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Shortcut text (e.g. \"Ctrl+T\")"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "MenubarSub"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "SubTrigger + SubContent pair"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "MenubarSubTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Sub-menu trigger label"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "MenubarSubContent"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Sub-menu items"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "MenubarLabel"),
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
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "MenubarItemIndicator"),
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
