# Sheet — Suite.jl component docs page
#
# Showcases Sheet with side variants (right, left, bottom, top) and keyboard dismiss.


function SheetPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3",
                "Sheet"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A panel that slides in from the edge of the screen, typically used for navigation, settings, or supplementary content."
            )
        ),

        # Default (right side) — Settings panel
        ComponentPreview(title="Default (Right)", description="A settings panel sliding in from the right side.",
            Div(:class => "w-full max-w-md",
                Main.Sheet(
                    Main.SheetTrigger(
                        Main.Button(variant="outline", "Open Settings")
                    ),
                    Main.SheetContent(
                        Main.SheetHeader(
                            Main.SheetTitle("Settings"),
                            Main.SheetDescription("Adjust your preferences below.")
                        ),
                        Div(:class => "py-4 space-y-4",
                            Div(:class => "space-y-2",
                                Main.Label("Name"),
                                Main.Input(placeholder="Your name")
                            ),
                            Div(:class => "space-y-2",
                                Main.Label("Email"),
                                Main.Input(placeholder="you@example.com")
                            ),
                        ),
                        Main.SheetFooter(
                            Main.SheetClose(
                                Main.Button(variant="outline", "Cancel")
                            ),
                            Main.Button("Save changes")
                        )
                    )
                )
            )
        ),

        # Left side — Navigation panel
        ComponentPreview(title="Left Side", description="A navigation panel sliding in from the left.",
            Div(:class => "w-full max-w-md",
                Main.Sheet(
                    Main.SheetTrigger(
                        Main.Button(variant="outline", "Open Navigation")
                    ),
                    Main.SheetContent(side="left",
                        Main.SheetHeader(
                            Main.SheetTitle("Navigation"),
                            Main.SheetDescription("Browse sections of the application.")
                        ),
                        Div(:class => "py-4 space-y-1",
                            Div(:class => "px-3 py-2 rounded-md text-sm font-medium text-accent-600 dark:text-accent-400 bg-accent-50 dark:bg-accent-950", "Dashboard"),
                            Div(:class => "px-3 py-2 rounded-md text-sm text-warm-600 dark:text-warm-400 hover:bg-warm-100 dark:hover:bg-warm-800 cursor-pointer", "Projects"),
                            Div(:class => "px-3 py-2 rounded-md text-sm text-warm-600 dark:text-warm-400 hover:bg-warm-100 dark:hover:bg-warm-800 cursor-pointer", "Team"),
                            Div(:class => "px-3 py-2 rounded-md text-sm text-warm-600 dark:text-warm-400 hover:bg-warm-100 dark:hover:bg-warm-800 cursor-pointer", "Settings"),
                        ),
                        Main.SheetFooter(
                            Main.SheetClose(
                                Main.Button(variant="outline", "Close")
                            )
                        )
                    )
                )
            )
        ),

        # Bottom side — Notification panel
        ComponentPreview(title="Bottom Side", description="A notification panel sliding up from the bottom.",
            Div(:class => "w-full max-w-md",
                Main.Sheet(
                    Main.SheetTrigger(
                        Main.Button(variant="outline", "Open Notifications")
                    ),
                    Main.SheetContent(side="bottom",
                        Main.SheetHeader(
                            Main.SheetTitle("Notifications"),
                            Main.SheetDescription("You have 3 unread notifications.")
                        ),
                        Div(:class => "py-4 space-y-3",
                            Div(:class => "flex items-start gap-3 p-3 rounded-md bg-warm-50 dark:bg-warm-900",
                                Div(:class => "w-2 h-2 mt-1.5 rounded-full bg-accent-600 shrink-0"),
                                Div(
                                    P(:class => "text-sm font-medium text-warm-800 dark:text-warm-100", "New comment on your post"),
                                    P(:class => "text-xs text-warm-500 dark:text-warm-400", "2 minutes ago")
                                )
                            ),
                            Div(:class => "flex items-start gap-3 p-3 rounded-md bg-warm-50 dark:bg-warm-900",
                                Div(:class => "w-2 h-2 mt-1.5 rounded-full bg-accent-600 shrink-0"),
                                Div(
                                    P(:class => "text-sm font-medium text-warm-800 dark:text-warm-100", "Project invitation received"),
                                    P(:class => "text-xs text-warm-500 dark:text-warm-400", "1 hour ago")
                                )
                            ),
                            Div(:class => "flex items-start gap-3 p-3 rounded-md bg-warm-50 dark:bg-warm-900",
                                Div(:class => "w-2 h-2 mt-1.5 rounded-full bg-accent-600 shrink-0"),
                                Div(
                                    P(:class => "text-sm font-medium text-warm-800 dark:text-warm-100", "Deployment completed"),
                                    P(:class => "text-xs text-warm-500 dark:text-warm-400", "3 hours ago")
                                )
                            ),
                        ),
                        Main.SheetFooter(
                            Main.SheetClose(
                                Main.Button(variant="outline", "Dismiss All")
                            )
                        )
                    )
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "Usage"
            ),
            Div(:class => "bg-warm-800 dark:bg-warm-950 rounded-md border border-warm-700 p-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-50",
                    Code(:class => "language-julia", """using Suite

Sheet(
    SheetTrigger(
        Button(variant="outline", "Open Sheet")
    ),
    SheetContent(side="right",
        SheetHeader(
            SheetTitle("Title"),
            SheetDescription("Description text.")
        ),
        P("Sheet body content goes here."),
        SheetFooter(
            SheetClose(Button(variant="outline", "Cancel")),
            Button("Confirm")
        )
    )
)""")
                )
            )
        ),

        # Keyboard interactions
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
                        KeyRow("Escape", "Closes the sheet"),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "API Reference"
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "Sheet"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Sheet trigger and content"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SheetTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Element that opens the sheet on click"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SheetContent"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("side", "String", "\"right\"", "Edge to slide from: \"top\", \"right\", \"bottom\", \"left\""),
                        ApiRow("children...", "Any", "-", "Content rendered inside the sheet panel"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SheetHeader"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Header content (title and description)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SheetFooter"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Footer content (action buttons)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SheetTitle"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Title text"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SheetDescription"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Description text"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SheetClose"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Element that closes the sheet on click"),
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

SheetPage
