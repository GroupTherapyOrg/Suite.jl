# Alert Dialog — Suite.jl component docs page
#
# Showcases AlertDialog with basic confirmation and destructive variant.
# Uses role=alertdialog — cannot be dismissed by Escape or click-outside.


function AlertDialogPage()
    ComponentsLayout(
        # Header
        PageHeader("Alert Dialog", "A modal dialog that interrupts the user with important content and expects a response. Uses role=alertdialog and cannot be dismissed by Escape or clicking outside."),

        # Basic Preview
        ComponentPreview(title="Basic", description="A simple confirmation dialog with Cancel and Continue actions.",
            Div(:class => "w-full max-w-md",
                Main.AlertDialog(
                    Main.AlertDialogTrigger(
                        Main.Button(variant="outline", "Show Alert Dialog")
                    ),
                    Main.AlertDialogContent(
                        Main.AlertDialogHeader(
                            Main.AlertDialogTitle("Are you sure?"),
                            Main.AlertDialogDescription("This action cannot be undone. This will permanently apply the changes to your account."),
                        ),
                        Main.AlertDialogFooter(
                            Main.AlertDialogCancel("Cancel"),
                            Main.AlertDialogAction("Continue"),
                        ),
                    ),
                )
            )
        ),

        # Destructive Preview
        ComponentPreview(title="Destructive", description="A destructive confirmation dialog with a styled delete action.",
            Div(:class => "w-full max-w-md",
                Main.AlertDialog(
                    Main.AlertDialogTrigger(
                        Main.Button(variant="destructive", "Delete")
                    ),
                    Main.AlertDialogContent(
                        Main.AlertDialogHeader(
                            Main.AlertDialogTitle("Delete item?"),
                            Main.AlertDialogDescription("This action cannot be undone. This will permanently delete this item and remove its data from our servers."),
                        ),
                        Main.AlertDialogFooter(
                            Main.AlertDialogCancel("Cancel"),
                            Main.AlertDialogAction("Delete"),
                        ),
                    ),
                )
            )
        ),

        # Usage
        UsageBlock("""using Suite

AlertDialog(
    AlertDialogTrigger(
        Button(variant="outline", "Show Alert Dialog")
    ),
    AlertDialogContent(
        AlertDialogHeader(
            AlertDialogTitle("Are you sure?"),
            AlertDialogDescription("This action cannot be undone."),
        ),
        AlertDialogFooter(
            AlertDialogCancel("Cancel"),
            AlertDialogAction("Continue"),
        ),
    ),
)"""),

        # Keyboard shortcuts
        KeyboardTable(
            KeyRow("Tab", "Move focus between Cancel and Action buttons"),
            KeyRow("Enter / Space", "Activate the focused button"),
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),
            SectionH3("AlertDialog"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "AlertDialog sub-components"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("AlertDialogTrigger"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Element that opens the dialog"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("AlertDialogContent"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Dialog content (header, footer, etc.)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("AlertDialogHeader"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Header content (title, description)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("AlertDialogFooter"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Footer content (action buttons)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("AlertDialogTitle"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Dialog title text"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("AlertDialogDescription"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Dialog description text"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("AlertDialogAction"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Action button text (e.g. \"Continue\", \"Delete\")"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("AlertDialogCancel"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Cancel button text (e.g. \"Cancel\")"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
        )
    )
end




AlertDialogPage
