# Command — Suite.jl component docs page
#
# Showcases Command with grouped items, fuzzy search, and dialog variant.


function CommandPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3",
                "Command"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A command palette with fuzzy search, keyboard navigation, and grouped items."
            )
        ),

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
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "Usage"
            ),
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
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "Keyboard Interactions"
            ),
            P(:class => "text-sm text-warm-600 dark:text-warm-400 mb-4",
                "Fuzzy search is built in with a recursive scoring algorithm. Vim-style bindings are supported."
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
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "API Reference"
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "Command"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Command sub-components (container)"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "CommandInput"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("placeholder", "String", "\"Search...\"", "Placeholder text for the search input"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "CommandList"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "CommandEmpty"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Content shown when no results match"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "CommandGroup"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("heading", "String", "\"\"", "Group heading label"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "CommandItem"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("value", "String", "\"\"", "Unique value identifier for the item"),
                        ApiRow("disabled", "Bool", "false", "Disable this item"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "CommandSeparator"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("-", "-", "-", "Visual separator between groups"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "CommandShortcut"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Keyboard shortcut text"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "CommandDialog"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Wraps Command in a dialog overlay"),
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

CommandPage
