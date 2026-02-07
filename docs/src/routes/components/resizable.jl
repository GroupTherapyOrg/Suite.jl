# Resizable — Suite.jl component docs page

function ResizablePage()
    ComponentsLayout(
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3", "Resizable"),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "Draggable panel groups for creating resizable layouts with min/max constraints."
            )
        ),

        # Default
        ComponentPreview(title="Default", description="Two horizontal panels with a drag handle.",
            Div(:class => "w-full max-w-2xl border border-warm-200 dark:border-warm-700 rounded-lg overflow-hidden",
                Main.ResizablePanelGroup(direction="horizontal", class="h-48",
                    Main.ResizablePanel(default_size=50,
                        Div(:class => "flex h-full items-center justify-center p-6",
                            Span(:class => "font-semibold text-warm-600 dark:text-warm-300", "Panel A")
                        )
                    ),
                    Main.ResizableHandle(with_handle=true),
                    Main.ResizablePanel(default_size=50,
                        Div(:class => "flex h-full items-center justify-center p-6",
                            Span(:class => "font-semibold text-warm-600 dark:text-warm-300", "Panel B")
                        )
                    ),
                )
            )
        ),

        # Vertical
        ComponentPreview(title="Vertical", description="Vertically stacked panels.",
            Div(:class => "w-full max-w-2xl border border-warm-200 dark:border-warm-700 rounded-lg overflow-hidden",
                Main.ResizablePanelGroup(direction="vertical", class="h-64",
                    Main.ResizablePanel(default_size=40,
                        Div(:class => "flex h-full items-center justify-center p-6",
                            Span(:class => "font-semibold text-warm-600 dark:text-warm-300", "Top")
                        )
                    ),
                    Main.ResizableHandle(with_handle=true),
                    Main.ResizablePanel(default_size=60,
                        Div(:class => "flex h-full items-center justify-center p-6",
                            Span(:class => "font-semibold text-warm-600 dark:text-warm-300", "Bottom")
                        )
                    ),
                )
            )
        ),

        # Three panels
        ComponentPreview(title="Three Panels", description="Three panels with two handles.",
            Div(:class => "w-full max-w-2xl border border-warm-200 dark:border-warm-700 rounded-lg overflow-hidden",
                Main.ResizablePanelGroup(direction="horizontal", class="h-48",
                    Main.ResizablePanel(default_size=25,
                        Div(:class => "flex h-full items-center justify-center p-4",
                            Span(:class => "font-semibold text-warm-600 dark:text-warm-300", "Sidebar")
                        )
                    ),
                    Main.ResizableHandle(),
                    Main.ResizablePanel(default_size=50,
                        Div(:class => "flex h-full items-center justify-center p-4",
                            Span(:class => "font-semibold text-warm-600 dark:text-warm-300", "Content")
                        )
                    ),
                    Main.ResizableHandle(),
                    Main.ResizablePanel(default_size=25,
                        Div(:class => "flex h-full items-center justify-center p-4",
                            Span(:class => "font-semibold text-warm-600 dark:text-warm-300", "Inspector")
                        )
                    ),
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            SectionH2("Usage"),
            Main.CodeBlock(language="julia", """using Suite

ResizablePanelGroup(direction="horizontal",
    ResizablePanel(default_size=30,
        Div("Sidebar content")
    ),
    ResizableHandle(with_handle=true),
    ResizablePanel(default_size=70,
        Div("Main content")
    ),
)""")
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "ResizablePanelGroup"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                    )),
                    Main.TableBody(
                        ApiRow("direction", "String", "\"horizontal\"", "Layout direction: \"horizontal\" or \"vertical\""),
                        ApiRow("children", "Any", "-", "ResizablePanel and ResizableHandle elements"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "ResizablePanel"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                    )),
                    Main.TableBody(
                        ApiRow("default_size", "Int", "0", "Initial size as percentage (0 = auto-distribute)"),
                        ApiRow("min_size", "Int", "10", "Minimum size percentage"),
                        ApiRow("max_size", "Int", "100", "Maximum size percentage"),
                        ApiRow("children", "Any", "-", "Panel content"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "ResizableHandle"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                        Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                    )),
                    Main.TableBody(
                        ApiRow("with_handle", "Bool", "false", "Whether to show a visible grip icon"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
        )
    )
end


ResizablePage
