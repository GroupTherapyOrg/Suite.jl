# DropdownMenu — Suite.jl component docs page
#
# Showcases DropdownMenu with basic items, checkboxes, radio groups,
# submenus, keyboard shortcuts, and full keyboard navigation.


function DropdownMenuPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3",
                "Dropdown Menu"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "Displays a menu of actions or options triggered by a button, supporting items, checkboxes, radio groups, and submenus."
            )
        ),

        # Basic dropdown preview
        ComponentPreview(title="Basic", description="A simple \"My Account\" dropdown with items and keyboard shortcuts.",
            Div(:class => "w-full max-w-md flex justify-center",
                Main.DropdownMenu(
                    Main.DropdownMenuTrigger(
                        Main.Button(variant="outline", "My Account")
                    ),
                    Main.DropdownMenuContent(
                        Main.DropdownMenuLabel("My Account"),
                        Main.DropdownMenuSeparator(),
                        Main.DropdownMenuGroup(
                            Main.DropdownMenuItem(
                                "Profile",
                                Main.DropdownMenuShortcut("Shift+Cmd+P")
                            ),
                            Main.DropdownMenuItem(
                                "Billing",
                                Main.DropdownMenuShortcut("Cmd+B")
                            ),
                            Main.DropdownMenuItem(
                                "Settings",
                                Main.DropdownMenuShortcut("Cmd+,")
                            ),
                        ),
                        Main.DropdownMenuSeparator(),
                        Main.DropdownMenuItem("Log out", Main.DropdownMenuShortcut("Shift+Cmd+Q")),
                    )
                )
            )
        ),

        # Checkboxes and Radio groups
        ComponentPreview(title="With Checkboxes & Radio", description="Checkbox items for toggles and radio groups for single-select options.",
            Div(:class => "w-full max-w-md flex justify-center",
                Main.DropdownMenu(
                    Main.DropdownMenuTrigger(
                        Main.Button(variant="outline", "Options")
                    ),
                    Main.DropdownMenuContent(
                        Main.DropdownMenuLabel("Appearance"),
                        Main.DropdownMenuSeparator(),
                        Main.DropdownMenuCheckboxItem(checked=true,
                            Main.DropdownMenuItemIndicator(),
                            "Status Bar"
                        ),
                        Main.DropdownMenuCheckboxItem(checked=false,
                            Main.DropdownMenuItemIndicator(),
                            "Activity Bar"
                        ),
                        Main.DropdownMenuSeparator(),
                        Main.DropdownMenuLabel("Theme"),
                        Main.DropdownMenuRadioGroup(value="system",
                            Main.DropdownMenuRadioItem(value="system",
                                Main.DropdownMenuItemIndicator(),
                                "System"
                            ),
                            Main.DropdownMenuRadioItem(value="light",
                                Main.DropdownMenuItemIndicator(),
                                "Light"
                            ),
                            Main.DropdownMenuRadioItem(value="dark",
                                Main.DropdownMenuItemIndicator(),
                                "Dark"
                            ),
                        ),
                    )
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "Usage"
            ),
            Main.CodeBlock(language="julia", """using Suite

DropdownMenu(
    DropdownMenuTrigger(
        Button(variant="outline", "Open Menu")
    ),
    DropdownMenuContent(
        DropdownMenuLabel("Actions"),
        DropdownMenuSeparator(),
        DropdownMenuGroup(
            DropdownMenuItem("Profile", DropdownMenuShortcut("Cmd+P")),
            DropdownMenuItem("Settings", DropdownMenuShortcut("Cmd+,")),
        ),
        DropdownMenuSeparator(),
        DropdownMenuItem("Log out"),
    )
)""")
        ),

        # Keyboard shortcuts
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
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
                        KeyRow("Arrow Down", "Move focus to the next menu item"),
                        KeyRow("Arrow Up", "Move focus to the previous menu item"),
                        KeyRow("Enter / Space", "Activate the focused menu item"),
                        KeyRow("Escape", "Close the dropdown menu"),
                        KeyRow("Arrow Right", "Open the focused submenu"),
                        KeyRow("Arrow Left", "Close the current submenu"),
                        KeyRow("Home", "Move focus to the first menu item"),
                        KeyRow("End", "Move focus to the last menu item"),
                        KeyRow("Type-ahead", "Focus item by typing its label"),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "API Reference"
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "DropdownMenu"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("open", "Bool", "false", "Controlled open state"),
                        ApiRow("default_open", "Bool", "false", "Initial open state (uncontrolled)"),
                        ApiRow("on_open_change", "Function", "nothing", "Callback when open state changes"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "DropdownMenuTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Trigger content (usually a button)"),
                        ApiRow("as_child", "Bool", "false", "Merge props into child element"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "DropdownMenuContent"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("side", "String", "\"bottom\"", "Preferred side: \"top\", \"right\", \"bottom\", \"left\""),
                        ApiRow("align", "String", "\"start\"", "Alignment: \"start\", \"center\", \"end\""),
                        ApiRow("side_offset", "Number", "4", "Offset from the trigger (px)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "DropdownMenuGroup"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Grouped menu items"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "DropdownMenuLabel"),
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
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "DropdownMenuItem"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Item content"),
                        ApiRow("disabled", "Bool", "false", "Disable interaction"),
                        ApiRow("inset", "Bool", "false", "Add left padding to align with labeled groups"),
                        ApiRow("on_select", "Function", "nothing", "Callback when item is selected"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "DropdownMenuCheckboxItem"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("checked", "Bool", "false", "Whether the checkbox is checked"),
                        ApiRow("on_checked_change", "Function", "nothing", "Callback when checked state changes"),
                        ApiRow("disabled", "Bool", "false", "Disable interaction"),
                        ApiRow("children...", "Any", "-", "Item content"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "DropdownMenuRadioGroup"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("value", "String", "\"\"", "Currently selected radio value"),
                        ApiRow("on_value_change", "Function", "nothing", "Callback when selection changes"),
                        ApiRow("children...", "Any", "-", "Radio items"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "DropdownMenuRadioItem"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("value", "String", "\"\"", "Value for this radio option (required)"),
                        ApiRow("disabled", "Bool", "false", "Disable interaction"),
                        ApiRow("children...", "Any", "-", "Item content"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "DropdownMenuItemIndicator"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Custom indicator content (default: check icon)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "DropdownMenuSeparator"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "DropdownMenuShortcut"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Shortcut text (e.g. \"Cmd+K\")"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "DropdownMenuSub"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("open", "Bool", "false", "Controlled open state of submenu"),
                        ApiRow("default_open", "Bool", "false", "Initial open state (uncontrolled)"),
                        ApiRow("on_open_change", "Function", "nothing", "Callback when submenu open state changes"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "DropdownMenuSubTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Trigger content for the submenu"),
                        ApiRow("disabled", "Bool", "false", "Disable interaction"),
                        ApiRow("inset", "Bool", "false", "Add left padding to align with labeled groups"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "DropdownMenuSubContent"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("side_offset", "Number", "2", "Offset from the sub-trigger (px)"),
                        ApiRow("align_offset", "Number", "-5", "Vertical alignment offset (px)"),
                        ApiRow("children...", "Any", "-", "Submenu content"),
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
        Td(:class => "py-3 px-4 font-mono text-xs text-warm-800 dark:text-warm-300", key),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", action)
    )
end

DropdownMenuPage
