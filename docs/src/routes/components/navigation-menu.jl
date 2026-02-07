# Navigation Menu — Suite.jl component docs page
#
# Showcases NavigationMenu with trigger panels, content links, and direct link items.


function NavigationMenuPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Navigation Menu"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A collection of links for navigating websites, with support for trigger-activated content panels."
            )
        ),

        # Default Preview
        ComponentPreview(title="Default", description="Site navigation with trigger panels and a direct link.",
            Div(:class => "w-full max-w-2xl",
                Main.NavigationMenu(
                    Main.NavigationMenuList(
                        # Getting Started
                        Main.NavigationMenuItem(
                            Main.NavigationMenuTrigger("Getting Started"),
                            Main.NavigationMenuContent(
                                Main.NavigationMenuLink(href="/docs/introduction", title="Introduction",
                                    "Re-usable components built with Therapy.jl and Tailwind CSS."
                                ),
                                Main.NavigationMenuLink(href="/docs/installation", title="Installation",
                                    "How to install dependencies and structure your app."
                                ),
                                Main.NavigationMenuLink(href="/docs/typography", title="Typography",
                                    "Styles for headings, paragraphs, lists, and inline code."
                                ),
                            ),
                        ),

                        # Components
                        Main.NavigationMenuItem(
                            Main.NavigationMenuTrigger("Components"),
                            Main.NavigationMenuContent(
                                Main.NavigationMenuLink(href="/docs/components/button", title="Button",
                                    "Displays a button or a component that looks like a button."
                                ),
                                Main.NavigationMenuLink(href="/docs/components/dialog", title="Dialog",
                                    "A window overlaid on the primary content."
                                ),
                                Main.NavigationMenuLink(href="/docs/components/tabs", title="Tabs",
                                    "A set of layered sections of content, known as tab panels."
                                ),
                            ),
                        ),

                        # Direct link
                        Main.NavigationMenuItem(
                            Main.NavigationMenuLink(href="/docs", title="Documentation",
                                "Browse the full documentation."
                            ),
                        ),
                    ),
                    Main.NavigationMenuViewport(),
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

NavigationMenu(
    NavigationMenuList(
        NavigationMenuItem(
            NavigationMenuTrigger("Getting Started"),
            NavigationMenuContent(
                NavigationMenuLink(href="/intro", title="Introduction",
                    "A brief overview of the project."
                ),
            ),
        ),
        NavigationMenuItem(
            NavigationMenuLink(href="/docs", title="Documentation",
                "Browse the full docs."
            ),
        ),
    ),
    NavigationMenuViewport(),
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
                        KeyRow("Arrow Right", "Move focus to the next trigger"),
                        KeyRow("Arrow Left", "Move focus to the previous trigger"),
                        KeyRow("Arrow Down", "Open content panel / move into content"),
                        KeyRow("Tab", "Cycle through links within an open content panel"),
                        KeyRow("Enter / Space", "Activate the focused link or trigger"),
                        KeyRow("Escape", "Close the open content panel"),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "API Reference"
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "NavigationMenu"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "NavigationMenuList and NavigationMenuViewport"),
                        ApiRow("orientation", "String", "\"horizontal\"", "\"horizontal\" or \"vertical\""),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "NavigationMenuList"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "NavigationMenuItem children"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "NavigationMenuItem"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Trigger + Content pair, or a direct Link"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "NavigationMenuTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "Trigger label text"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "NavigationMenuContent"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("children...", "Any", "-", "NavigationMenuLink items"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "NavigationMenuLink"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("href", "String", "\"\"", "URL the link navigates to"),
                        ApiRow("title", "String", "\"\"", "Link heading text"),
                        ApiRow("children...", "Any", "-", "Description text displayed below the title"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "NavigationMenuViewport"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "NavigationMenuIndicator"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
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

NavigationMenuPage
