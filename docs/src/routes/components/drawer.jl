# Drawer — Suite.jl component docs page
#
# Showcases SuiteDrawer with drag-to-dismiss overlay, directional content, and form usage.

const SuiteDrawer = Main.SuiteDrawer
const SuiteDrawerTrigger = Main.SuiteDrawerTrigger
const SuiteDrawerContent = Main.SuiteDrawerContent
const SuiteDrawerHeader = Main.SuiteDrawerHeader
const SuiteDrawerFooter = Main.SuiteDrawerFooter
const SuiteDrawerTitle = Main.SuiteDrawerTitle
const SuiteDrawerDescription = Main.SuiteDrawerDescription
const SuiteDrawerClose = Main.SuiteDrawerClose
const SuiteDrawerHandle = Main.SuiteDrawerHandle

function DrawerPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Drawer"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A drag-to-dismiss overlay panel with velocity and distance thresholds. Slides in from any edge of the screen."
            )
        ),

        # Default bottom drawer with handle
        ComponentPreview(title="Default", description="Bottom drawer with a visible grab handle.",
            Div(:class => "w-full max-w-md",
                SuiteDrawer(
                    SuiteDrawerTrigger(
                        Main.SuiteButton(variant="outline", "Open Drawer")
                    ),
                    SuiteDrawerContent(
                        SuiteDrawerHandle(),
                        SuiteDrawerHeader(
                            SuiteDrawerTitle("Move Goal"),
                            SuiteDrawerDescription("Set your daily activity goal."),
                        ),
                        Div(:class => "p-4 pb-0",
                            Div(:class => "flex items-center justify-center space-x-2",
                                Div(:class => "flex-1 text-center",
                                    Div(:class => "text-7xl font-bold tracking-tighter text-warm-800 dark:text-warm-50", "350"),
                                    Div(:class => "text-[0.70rem] uppercase text-warm-500 dark:text-warm-400", "Calories/day"),
                                )
                            )
                        ),
                        SuiteDrawerFooter(
                            Main.SuiteButton("Submit"),
                            SuiteDrawerClose(
                                Main.SuiteButton(variant="outline", "Cancel")
                            ),
                        ),
                    ),
                )
            )
        ),

        # With form content (login form)
        ComponentPreview(title="With Form", description="Drawer containing a login form.",
            Div(:class => "w-full max-w-md",
                SuiteDrawer(
                    SuiteDrawerTrigger(
                        Main.SuiteButton(variant="outline", "Open Drawer")
                    ),
                    SuiteDrawerContent(
                        SuiteDrawerHandle(),
                        SuiteDrawerHeader(
                            SuiteDrawerTitle("Login"),
                            SuiteDrawerDescription("Enter your credentials to continue."),
                        ),
                        Div(:class => "p-4 space-y-4",
                            Div(:class => "space-y-2",
                                Main.SuiteLabel("Email"),
                                Main.SuiteInput(type="email", placeholder="you@example.com"),
                            ),
                            Div(:class => "space-y-2",
                                Main.SuiteLabel("Password"),
                                Main.SuiteInput(type="password", placeholder="Enter your password"),
                            ),
                        ),
                        SuiteDrawerFooter(
                            Main.SuiteButton("Sign In"),
                            SuiteDrawerClose(
                                Main.SuiteButton(variant="outline", "Cancel")
                            ),
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

SuiteDrawer(
    SuiteDrawerTrigger(
        SuiteButton(variant="outline", "Open Drawer")
    ),
    SuiteDrawerContent(
        SuiteDrawerHandle(),
        SuiteDrawerHeader(
            SuiteDrawerTitle("Title"),
            SuiteDrawerDescription("Description text."),
        ),
        Div(:class => "p-4", P("Drawer body content.")),
        SuiteDrawerFooter(
            SuiteButton("Confirm"),
            SuiteDrawerClose(
                SuiteButton(variant="outline", "Cancel")
            ),
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
                        KeyRow("Escape", "Close the drawer"),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "API Reference"
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteDrawer"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Drawer trigger and content"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteDrawerTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Element that opens the drawer on click"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteDrawerContent"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Content rendered inside the drawer panel"),
                        ApiRow("direction", "String", "\"bottom\"", "Slide direction: \"bottom\", \"top\", \"left\", or \"right\""),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteDrawerHeader"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Header content (title and description)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteDrawerFooter"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Footer content (action buttons)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteDrawerTitle"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Title text"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteDrawerDescription"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Description text"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteDrawerClose"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Element that closes the drawer on click"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteDrawerHandle"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes for the visual grab indicator"),
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

DrawerPage
