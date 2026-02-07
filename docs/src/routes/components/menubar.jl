# Menubar — Suite.jl component docs page
#
# Showcases Menubar with File/Edit/View menus, submenus, checkbox items, and keyboard nav.


function MenubarPage()
    ComponentsLayout(
        # Header
        PageHeader("Menubar", "A visually persistent menu common in desktop applications that provides quick access to a consistent set of commands."),

        # Default Preview — File / Edit / View
        ComponentPreview(title="Default", description="Classic desktop-style menubar with File, Edit, and View menus.",
            Div(:class => "w-full max-w-lg",
                Main.Menubar(
                    # File menu
                    Main.MenubarMenu(
                        Main.MenubarTrigger("File"),
                        Main.MenubarContent(
                            Main.MenubarItem("New Tab", Main.MenubarShortcut("Ctrl+T")),
                            Main.MenubarItem("New Window", Main.MenubarShortcut("Ctrl+N")),
                            Main.MenubarSeparator(),
                            Main.MenubarSub(
                                Main.MenubarSubTrigger("Share"),
                                Main.MenubarSubContent(
                                    Main.MenubarItem("Email"),
                                    Main.MenubarItem("Messages"),
                                ),
                            ),
                            Main.MenubarSeparator(),
                            Main.MenubarItem("Print", Main.MenubarShortcut("Ctrl+P")),
                        ),
                    ),

                    # Edit menu
                    Main.MenubarMenu(
                        Main.MenubarTrigger("Edit"),
                        Main.MenubarContent(
                            Main.MenubarItem("Undo", Main.MenubarShortcut("Ctrl+Z")),
                            Main.MenubarItem("Redo", Main.MenubarShortcut("Ctrl+Shift+Z")),
                            Main.MenubarSeparator(),
                            Main.MenubarItem("Cut", Main.MenubarShortcut("Ctrl+X")),
                            Main.MenubarItem("Copy", Main.MenubarShortcut("Ctrl+C")),
                            Main.MenubarItem("Paste", Main.MenubarShortcut("Ctrl+V")),
                        ),
                    ),

                    # View menu
                    Main.MenubarMenu(
                        Main.MenubarTrigger("View"),
                        Main.MenubarContent(
                            Main.MenubarCheckboxItem("Always Show Bookmarks", checked=true),
                            Main.MenubarCheckboxItem("Always Show Full URLs"),
                        ),
                    ),
                )
            )
        ),

        # Usage
        UsageBlock("""using Suite

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
)"""),

        # Keyboard shortcuts
        KeyboardTable(
            KeyRow("Arrow Right", "Move focus to the next menu trigger"),
            KeyRow("Arrow Left", "Move focus to the previous menu trigger"),
            KeyRow("Arrow Down", "Open the focused menu / move to next item"),
            KeyRow("Arrow Up", "Move focus to the previous menu item"),
            KeyRow("Enter / Space", "Activate the focused menu item"),
            KeyRow("Escape", "Close the open menu"),
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),
            SectionH3("Menubar"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "MenubarMenu items"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("MenubarMenu"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Trigger + Content pair"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("MenubarTrigger"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Trigger label text"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("MenubarContent"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Menu items, separators, labels, submenus"),
                        ApiRow("align", "String", "\"start\"", "Alignment relative to trigger"),
                        ApiRow("side_offset", "Int", "5", "Distance from trigger in pixels"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("MenubarItem"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Item label and optional shortcut"),
                        ApiRow("disabled", "Bool", "false", "Disable this item"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("MenubarCheckboxItem"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Checkbox label text"),
                        ApiRow("checked", "Bool", "false", "Whether the item is checked"),
                        ApiRow("disabled", "Bool", "false", "Disable this item"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("MenubarRadioGroup"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "MenubarRadioItem children"),
                        ApiRow("value", "String", "\"\"", "Currently selected value"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("MenubarRadioItem"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Radio item label"),
                        ApiRow("value", "String", "\"\"", "Value for this radio option"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("MenubarSeparator"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("MenubarShortcut"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Shortcut text (e.g. \"Ctrl+T\")"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("MenubarSub"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "SubTrigger + SubContent pair"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("MenubarSubTrigger"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Sub-menu trigger label"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("MenubarSubContent"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Sub-menu items"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("MenubarLabel"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Label text"),
                        ApiRow("inset", "Bool", "false", "Add left padding to align with items"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("MenubarItemIndicator"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Indicator content (icon or check)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
        )
    )
end




MenubarPage
