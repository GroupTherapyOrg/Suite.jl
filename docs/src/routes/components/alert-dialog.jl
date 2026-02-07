# Alert Dialog — Suite.jl component docs page
#
# Showcases SuiteAlertDialog with basic confirmation and destructive variant.
# Uses role=alertdialog — cannot be dismissed by Escape or click-outside.

const SuiteAlertDialog = Main.SuiteAlertDialog
const SuiteAlertDialogTrigger = Main.SuiteAlertDialogTrigger
const SuiteAlertDialogContent = Main.SuiteAlertDialogContent
const SuiteAlertDialogHeader = Main.SuiteAlertDialogHeader
const SuiteAlertDialogFooter = Main.SuiteAlertDialogFooter
const SuiteAlertDialogTitle = Main.SuiteAlertDialogTitle
const SuiteAlertDialogDescription = Main.SuiteAlertDialogDescription
const SuiteAlertDialogAction = Main.SuiteAlertDialogAction
const SuiteAlertDialogCancel = Main.SuiteAlertDialogCancel

function AlertDialogPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Alert Dialog"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A modal dialog that interrupts the user with important content and expects a response. Uses role=alertdialog and cannot be dismissed by Escape or clicking outside."
            )
        ),

        # Basic Preview
        ComponentPreview(title="Basic", description="A simple confirmation dialog with Cancel and Continue actions.",
            Div(:class => "w-full max-w-md",
                SuiteAlertDialog(
                    SuiteAlertDialogTrigger(
                        Main.SuiteButton(variant="outline", "Show Alert Dialog")
                    ),
                    SuiteAlertDialogContent(
                        SuiteAlertDialogHeader(
                            SuiteAlertDialogTitle("Are you sure?"),
                            SuiteAlertDialogDescription("This action cannot be undone. This will permanently apply the changes to your account."),
                        ),
                        SuiteAlertDialogFooter(
                            SuiteAlertDialogCancel("Cancel"),
                            SuiteAlertDialogAction("Continue"),
                        ),
                    ),
                )
            )
        ),

        # Destructive Preview
        ComponentPreview(title="Destructive", description="A destructive confirmation dialog with a styled delete action.",
            Div(:class => "w-full max-w-md",
                SuiteAlertDialog(
                    SuiteAlertDialogTrigger(
                        Main.SuiteButton(variant="destructive", "Delete")
                    ),
                    SuiteAlertDialogContent(
                        SuiteAlertDialogHeader(
                            SuiteAlertDialogTitle("Delete item?"),
                            SuiteAlertDialogDescription("This action cannot be undone. This will permanently delete this item and remove its data from our servers."),
                        ),
                        SuiteAlertDialogFooter(
                            SuiteAlertDialogCancel("Cancel"),
                            SuiteAlertDialogAction("Delete"),
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

SuiteAlertDialog(
    SuiteAlertDialogTrigger(
        SuiteButton(variant="outline", "Show Alert Dialog")
    ),
    SuiteAlertDialogContent(
        SuiteAlertDialogHeader(
            SuiteAlertDialogTitle("Are you sure?"),
            SuiteAlertDialogDescription("This action cannot be undone."),
        ),
        SuiteAlertDialogFooter(
            SuiteAlertDialogCancel("Cancel"),
            SuiteAlertDialogAction("Continue"),
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
                        KeyRow("Tab", "Move focus between Cancel and Action buttons"),
                        KeyRow("Enter / Space", "Activate the focused button"),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "API Reference"
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteAlertDialog"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "AlertDialog sub-components"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteAlertDialogTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Element that opens the dialog"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteAlertDialogContent"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Dialog content (header, footer, etc.)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteAlertDialogHeader"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Header content (title, description)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteAlertDialogFooter"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Footer content (action buttons)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteAlertDialogTitle"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Dialog title text"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteAlertDialogDescription"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Dialog description text"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteAlertDialogAction"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Action button text (e.g. \"Continue\", \"Delete\")"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteAlertDialogCancel"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Cancel button text (e.g. \"Cancel\")"),
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

AlertDialogPage
