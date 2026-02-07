# Dialog — Suite.jl component docs page
#
# Showcases SuiteDialog with basic modal, form dialog, and keyboard interactions.

const SuiteDialog = Main.SuiteDialog
const SuiteDialogTrigger = Main.SuiteDialogTrigger
const SuiteDialogContent = Main.SuiteDialogContent
const SuiteDialogHeader = Main.SuiteDialogHeader
const SuiteDialogFooter = Main.SuiteDialogFooter
const SuiteDialogTitle = Main.SuiteDialogTitle
const SuiteDialogDescription = Main.SuiteDialogDescription
const SuiteDialogClose = Main.SuiteDialogClose

function DialogPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Dialog"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A modal window that overlays the main content, requiring user interaction before returning to the parent view."
            )
        ),

        # Basic Dialog Preview
        ComponentPreview(title="Basic", description="A simple dialog with a title, description, and action buttons.",
            Div(:class => "w-full max-w-md",
                SuiteDialog(
                    SuiteDialogTrigger(
                        Main.SuiteButton(variant="outline", "Open Dialog")
                    ),
                    SuiteDialogContent(
                        SuiteDialogHeader(
                            SuiteDialogTitle("Are you sure?"),
                            SuiteDialogDescription("This action cannot be undone. This will permanently delete your account and remove your data from our servers.")
                        ),
                        SuiteDialogFooter(
                            SuiteDialogClose(
                                Main.SuiteButton(variant="outline", "Cancel")
                            ),
                            Main.SuiteButton("Continue")
                        )
                    )
                )
            )
        ),

        # Dialog with Form
        ComponentPreview(title="With Form", description="A dialog containing form inputs for collecting user information.",
            Div(:class => "w-full max-w-md",
                SuiteDialog(
                    SuiteDialogTrigger(
                        Main.SuiteButton(variant="outline", "Edit Profile")
                    ),
                    SuiteDialogContent(
                        SuiteDialogHeader(
                            SuiteDialogTitle("Edit Profile"),
                            SuiteDialogDescription("Make changes to your profile here. Click save when you're done.")
                        ),
                        Div(:class => "grid gap-4 py-4",
                            Div(:class => "grid grid-cols-4 items-center gap-4",
                                Label(:class => "text-right text-sm font-medium text-warm-800 dark:text-warm-200", :for => "name", "Name"),
                                Input(:id => "name", :type => "text", :value => "Dale Black", :class => "col-span-3 flex h-10 w-full rounded-md border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-900 px-3 py-2 text-sm text-warm-800 dark:text-warm-200 placeholder:text-warm-400 focus:outline-none focus:ring-2 focus:ring-accent-600 focus:ring-offset-2")
                            ),
                            Div(:class => "grid grid-cols-4 items-center gap-4",
                                Label(:class => "text-right text-sm font-medium text-warm-800 dark:text-warm-200", :for => "username", "Username"),
                                Input(:id => "username", :type => "text", :value => "@daleblack", :class => "col-span-3 flex h-10 w-full rounded-md border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-900 px-3 py-2 text-sm text-warm-800 dark:text-warm-200 placeholder:text-warm-400 focus:outline-none focus:ring-2 focus:ring-accent-600 focus:ring-offset-2")
                            )
                        ),
                        SuiteDialogFooter(
                            SuiteDialogClose(
                                Main.SuiteButton(variant="outline", "Cancel")
                            ),
                            Main.SuiteButton("Save changes")
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

SuiteDialog(
    SuiteDialogTrigger(
        SuiteButton(variant="outline", "Open Dialog")
    ),
    SuiteDialogContent(
        SuiteDialogHeader(
            SuiteDialogTitle("Dialog Title"),
            SuiteDialogDescription("A brief description of the dialog purpose."),
        ),
        P("Your dialog content goes here."),
        SuiteDialogFooter(
            SuiteDialogClose(SuiteButton(variant="outline", "Cancel")),
            SuiteButton("Confirm"),
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
                        KeyRow("Escape", "Close the dialog"),
                        KeyRow("Tab", "Cycle focus through focusable elements inside the dialog"),
                        KeyRow("Shift + Tab", "Cycle focus backward through focusable elements"),
                    )
                )
            )
        ),

        # Accessibility
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "Accessibility"
            ),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(
                        Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Attribute"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Applied To"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Purpose")
                        )
                    ),
                    Tbody(
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs text-warm-800 dark:text-warm-200", "role=\"dialog\""),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "SuiteDialogContent"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Identifies the element as a dialog")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs text-warm-800 dark:text-warm-200", "aria-modal=\"true\""),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "SuiteDialogContent"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Indicates that the dialog is modal and blocks interaction with the rest of the page")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs text-warm-800 dark:text-warm-200", "aria-describedby"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "SuiteDialogContent"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Points to the SuiteDialogDescription for screen readers")
                        ),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "API Reference"
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteDialog"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Dialog sub-components (trigger, content)"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteDialogTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "The trigger element that opens the dialog"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteDialogContent"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Dialog body content"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteDialogHeader"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Header content (title, description)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteDialogFooter"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Footer content (action buttons)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteDialogTitle"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Dialog title text"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteDialogDescription"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Dialog description text"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteDialogClose"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Close button content"),
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

DialogPage
