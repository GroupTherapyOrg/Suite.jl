# Drawer — Suite.jl component docs page
#
# Showcases Drawer with drag-to-dismiss overlay, directional content, and form usage.


function DrawerPage()
    ComponentsLayout(
        # Header
        PageHeader("Drawer", "A drag-to-dismiss overlay panel with velocity and distance thresholds. Slides in from any edge of the screen."),

        # Default bottom drawer with handle
        ComponentPreview(title="Default", description="Bottom drawer with a visible grab handle.",
            Div(:class => "w-full max-w-md",
                Main.Drawer(
                    Main.DrawerTrigger(
                        Main.Button(variant="outline", "Open Drawer")
                    ),
                    Main.DrawerContent(
                        Main.DrawerHandle(),
                        Main.DrawerHeader(
                            Main.DrawerTitle("Move Goal"),
                            Main.DrawerDescription("Set your daily activity goal."),
                        ),
                        Div(:class => "p-4 pb-0",
                            Div(:class => "flex items-center justify-center space-x-2",
                                Div(:class => "flex-1 text-center",
                                    Div(:class => "text-7xl font-bold tracking-tighter text-warm-800 dark:text-warm-300", "350"),
                                    Div(:class => "text-[0.70rem] uppercase text-warm-500 dark:text-warm-400", "Calories/day"),
                                )
                            )
                        ),
                        Main.DrawerFooter(
                            Main.Button("Submit"),
                            Main.DrawerClose(
                                Main.Button(variant="outline", "Cancel")
                            ),
                        ),
                    ),
                )
            )
        ),

        # With form content (login form)
        ComponentPreview(title="With Form", description="Drawer containing a login form.",
            Div(:class => "w-full max-w-md",
                Main.Drawer(
                    Main.DrawerTrigger(
                        Main.Button(variant="outline", "Open Drawer")
                    ),
                    Main.DrawerContent(
                        Main.DrawerHandle(),
                        Main.DrawerHeader(
                            Main.DrawerTitle("Login"),
                            Main.DrawerDescription("Enter your credentials to continue."),
                        ),
                        Div(:class => "p-4 space-y-4",
                            Div(:class => "space-y-2",
                                Main.Label("Email"),
                                Main.Input(type="email", placeholder="you@example.com"),
                            ),
                            Div(:class => "space-y-2",
                                Main.Label("Password"),
                                Main.Input(type="password", placeholder="Enter your password"),
                            ),
                        ),
                        Main.DrawerFooter(
                            Main.Button("Sign In"),
                            Main.DrawerClose(
                                Main.Button(variant="outline", "Cancel")
                            ),
                        ),
                    ),
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            SectionH2("Usage"),
            Main.CodeBlock(language="julia", """using Suite

Drawer(
    DrawerTrigger(
        Button(variant="outline", "Open Drawer")
    ),
    DrawerContent(
        DrawerHandle(),
        DrawerHeader(
            DrawerTitle("Title"),
            DrawerDescription("Description text."),
        ),
        Div(:class => "p-4", P("Drawer body content.")),
        DrawerFooter(
            Button("Confirm"),
            DrawerClose(
                Button(variant="outline", "Cancel")
            ),
        ),
    ),
)""")
        ),

        # Keyboard shortcuts
        Div(:class => "mt-12 space-y-6",
            SectionH2("Keyboard Interactions"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(
                        Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Key"),
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Action")
                        )
                    ),
                    Main.TableBody(
                        KeyRow("Escape", "Close the drawer"),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),
            SectionH3("Drawer"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Drawer trigger and content"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("DrawerTrigger"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Element that opens the drawer on click"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("DrawerContent"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Content rendered inside the drawer panel"),
                        ApiRow("direction", "String", "\"bottom\"", "Slide direction: \"bottom\", \"top\", \"left\", or \"right\""),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("DrawerHeader"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Header content (title and description)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("DrawerFooter"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Footer content (action buttons)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("DrawerTitle"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Title text"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("DrawerDescription"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Description text"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("DrawerClose"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Element that closes the drawer on click"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("DrawerHandle"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes for the visual grab indicator"),
                    )
                )
            ),
        )
    )
end




DrawerPage
