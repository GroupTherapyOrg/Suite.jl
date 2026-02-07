# Popover — Suite.jl component docs page
#
# Showcases Popover with basic usage, close button, and positioning.


function PopoverPage()
    ComponentsLayout(
        # Header
        PageHeader("Popover", "A floating panel that appears on click. Modal by default — focus is trapped and scroll is locked."),

        # Basic Preview
        ComponentPreview(title="Basic", description="Click the trigger to open a popover with form inputs.",
            Div(:class => "w-full max-w-md",
                Main.Popover(
                    Main.PopoverTrigger(
                        Main.Button(variant="outline", "Open popover")
                    ),
                    Main.PopoverContent(side="bottom", align="center", side_offset=4, class="w-80",
                        Div(:class => "grid gap-4",
                            Div(:class => "space-y-2",
                                H4(:class => "font-medium text-sm text-warm-800 dark:text-warm-300 leading-none", "Dimensions"),
                                P(:class => "text-sm text-warm-600 dark:text-warm-400", "Set the dimensions for the layer.")
                            ),
                            Div(:class => "grid gap-2",
                                Div(:class => "grid grid-cols-3 items-center gap-4",
                                    Label(:class => "text-sm text-warm-800 dark:text-warm-300", "Width"),
                                    Input(:class => "col-span-2 h-8 rounded-md border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-900 px-3 text-sm text-warm-800 dark:text-warm-300", :type => "text", :value => "100%")
                                ),
                                Div(:class => "grid grid-cols-3 items-center gap-4",
                                    Label(:class => "text-sm text-warm-800 dark:text-warm-300", "Height"),
                                    Input(:class => "col-span-2 h-8 rounded-md border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-900 px-3 text-sm text-warm-800 dark:text-warm-300", :type => "text", :value => "25px")
                                ),
                            )
                        )
                    ),
                )
            )
        ),

        # With close button
        ComponentPreview(title="With Close Button", description="Popover with an explicit close button inside the content.",
            Div(:class => "w-full max-w-md",
                Main.Popover(
                    Main.PopoverTrigger(
                        Main.Button(variant="outline", "Open popover")
                    ),
                    Main.PopoverContent(side="bottom", align="center", side_offset=4, class="w-72",
                        Div(:class => "flex items-center justify-between mb-3",
                            H4(:class => "font-medium text-sm text-warm-800 dark:text-warm-300 leading-none", "Notifications"),
                            Main.PopoverClose(
                                Button(:class => "h-6 w-6 inline-flex items-center justify-center rounded-sm text-warm-500 dark:text-warm-400 hover:text-warm-800 dark:hover:text-warm-200",
                                    Span(:class => "sr-only", "Close"),
                                    Span(:aria_hidden => "true", "\u00d7")
                                )
                            ),
                        ),
                        P(:class => "text-sm text-warm-600 dark:text-warm-400", "You have 3 unread messages."),
                    ),
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            SectionH2("Usage"),
            Main.CodeBlock(language="julia", """using Suite

Popover(
    PopoverTrigger(
        Button(variant="outline", "Open popover")
    ),
    PopoverContent(side="bottom", align="center",
        Div(
            H4("Dimensions"),
            P("Set the dimensions for the layer."),
        )
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
                        KeyRow("Escape", "Closes the popover and returns focus to the trigger"),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),
            SectionH3("Popover"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Trigger and content sub-components"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("PopoverTrigger"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Element that opens the popover on click"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("PopoverContent"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("side", "String", "\"bottom\"", "Preferred side of the trigger (\"top\", \"right\", \"bottom\", \"left\")"),
                        ApiRow("align", "String", "\"center\"", "Alignment along the side (\"start\", \"center\", \"end\")"),
                        ApiRow("side_offset", "Int", "4", "Distance in pixels from the trigger"),
                        ApiRow("children...", "Any", "-", "Popover panel content"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("PopoverClose"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Element that closes the popover on click"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("PopoverAnchor"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Custom anchor element for positioning the popover"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
        )
    )
end




PopoverPage
