# Command — Suite.jl component docs page
#
# Showcases Command with grouped items, fuzzy search, and dialog variant.


function CommandPage()
    ComponentsLayout(
        # Header
        PageHeader("Command", "A command palette with fuzzy search, keyboard navigation, and grouped items."),

        # Basic Preview
        ComponentPreview(title="Basic", description="Command palette with suggestion and settings groups.",
            Div(:class => "w-full max-w-md",
                Main.Command(
                    Main.CommandInput(placeholder="Type a command or search..."),
                    Main.CommandList(
                        Main.CommandEmpty("No results found."),
                        Main.CommandGroup(heading="Suggestions",
                            Main.CommandItem(value="calendar", "Calendar"),
                            Main.CommandItem(value="search", "Search"),
                            Main.CommandItem(value="emoji", "Emoji"),
                        ),
                        Main.CommandSeparator(),
                        Main.CommandGroup(heading="Settings",
                            Main.CommandItem(value="profile", "Profile", Main.CommandShortcut("⌘P")),
                            Main.CommandItem(value="billing", "Billing", Main.CommandShortcut("⌘B")),
                            Main.CommandItem(value="settings", "Settings", Main.CommandShortcut("⌘,")),
                        ),
                    ),
                )
            )
        ),

        # Dialog variant
        ComponentPreview(title="Dialog", description="Command palette rendered inside a dialog overlay.",
            Div(:class => "w-full max-w-md",
                Main.CommandDialog(
                    Main.CommandInput(placeholder="Type a command or search..."),
                    Main.CommandList(
                        Main.CommandEmpty("No results found."),
                        Main.CommandGroup(heading="Suggestions",
                            Main.CommandItem(value="calendar", "Calendar"),
                            Main.CommandItem(value="search", "Search"),
                            Main.CommandItem(value="emoji", "Emoji"),
                        ),
                        Main.CommandSeparator(),
                        Main.CommandGroup(heading="Settings",
                            Main.CommandItem(value="profile", "Profile", Main.CommandShortcut("⌘P")),
                            Main.CommandItem(value="billing", "Billing", Main.CommandShortcut("⌘B")),
                            Main.CommandItem(value="settings", "Settings", Main.CommandShortcut("⌘,")),
                        ),
                    ),
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            SectionH2("Usage"),
            Main.CodeBlock(language="julia", """using Suite

Command(
    CommandInput(placeholder="Type a command or search..."),
    CommandList(
        CommandEmpty("No results found."),
        CommandGroup(heading="Suggestions",
            CommandItem(value="calendar", "Calendar"),
            CommandItem(value="search", "Search"),
        ),
        CommandSeparator(),
        CommandGroup(heading="Settings",
            CommandItem(value="profile", "Profile",
                CommandShortcut("⌘P")),
            CommandItem(value="settings", "Settings",
                CommandShortcut("⌘,")),
        ),
    ),
)""")
        ),

        # Keyboard shortcuts
        Div(:class => "mt-12 space-y-6",
            SectionH2("Keyboard Interactions"),
            P(:class => "text-sm text-warm-600 dark:text-warm-400 mb-4",
                "Fuzzy search is built in with a recursive scoring algorithm. Vim-style bindings are supported."
            ),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(
                        Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Key"),
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Action")
                        )
                    ),
                    Main.TableBody(
                        KeyRow("Arrow Down", "Move focus to the next item"),
                        KeyRow("Arrow Up", "Move focus to the previous item"),
                        KeyRow("Enter", "Select the focused item"),
                        KeyRow("Escape", "Close the dialog"),
                        KeyRow("Ctrl+N / Ctrl+J", "Move focus to the next item (vim binding)"),
                        KeyRow("Ctrl+P / Ctrl+K", "Move focus to the previous item (vim binding)"),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),
            SectionH3("Command"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Command sub-components (container)"),
                    )
                )
            ),
            SectionH3("CommandInput"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("placeholder", "String", "\"Search...\"", "Placeholder text for the search input"),
                    )
                )
            ),
            SectionH3("CommandList"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("CommandEmpty"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Content shown when no results match"),
                    )
                )
            ),
            SectionH3("CommandGroup"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("heading", "String", "\"\"", "Group heading label"),
                    )
                )
            ),
            SectionH3("CommandItem"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("value", "String", "\"\"", "Unique value identifier for the item"),
                        ApiRow("disabled", "Bool", "false", "Disable this item"),
                    )
                )
            ),
            SectionH3("CommandSeparator"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("-", "-", "-", "Visual separator between groups"),
                    )
                )
            ),
            SectionH3("CommandShortcut"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Keyboard shortcut text"),
                    )
                )
            ),
            SectionH3("CommandDialog"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Wraps Command in a dialog overlay"),
                    )
                )
            ),
        )
    )
end




CommandPage
