# Navigation Menu — Suite.jl component docs page
#
# Showcases NavigationMenu with trigger panels, content links, and direct link items.


function NavigationMenuPage()
    ComponentsLayout(
        # Header
        PageHeader("Navigation Menu", "A collection of links for navigating websites, with support for trigger-activated content panels."),

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
        UsageBlock("""using Suite

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
)"""),

        # Keyboard shortcuts
        KeyboardTable(
            KeyRow("Arrow Right", "Move focus to the next trigger"),
            KeyRow("Arrow Left", "Move focus to the previous trigger"),
            KeyRow("Arrow Down", "Open content panel / move into content"),
            KeyRow("Tab", "Cycle through links within an open content panel"),
            KeyRow("Enter / Space", "Activate the focused link or trigger"),
            KeyRow("Escape", "Close the open content panel"),
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),
            SectionH3("NavigationMenu"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "NavigationMenuList and NavigationMenuViewport"),
                        ApiRow("orientation", "String", "\"horizontal\"", "\"horizontal\" or \"vertical\""),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("NavigationMenuList"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "NavigationMenuItem children"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("NavigationMenuItem"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Trigger + Content pair, or a direct Link"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("NavigationMenuTrigger"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Trigger label text"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("NavigationMenuContent"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "NavigationMenuLink items"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("NavigationMenuLink"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("href", "String", "\"\"", "URL the link navigates to"),
                        ApiRow("title", "String", "\"\"", "Link heading text"),
                        ApiRow("children...", "Any", "-", "Description text displayed below the title"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("NavigationMenuViewport"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("NavigationMenuIndicator"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
        )
    )
end




NavigationMenuPage
