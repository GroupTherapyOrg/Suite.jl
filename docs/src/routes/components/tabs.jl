# Tabs — Suite.jl component docs page
#
# Showcases Tabs with roving tabindex and activation modes.


function TabsPage()
    ComponentsLayout(
        # Header
        PageHeader("Tabs", "A set of layered sections of content — known as tab panels — that are displayed one at a time."),

        # Default Preview
        ComponentPreview(title="Default", description="Click tabs to switch between panels.",
            Div(:class => "w-full max-w-md",
                Main.Tabs(default_value="account",
                    Main.TabsList(
                        Main.TabsTrigger("Account", value="account"),
                        Main.TabsTrigger("Password", value="password"),
                    ),
                    Main.TabsContent(value="account",
                        Div(:class => "p-4 space-y-2",
                            P(:class => "text-sm font-medium text-warm-800 dark:text-warm-300", "Account settings"),
                            P(:class => "text-sm text-warm-600 dark:text-warm-400", "Make changes to your account here."),
                        )
                    ),
                    Main.TabsContent(value="password",
                        Div(:class => "p-4 space-y-2",
                            P(:class => "text-sm font-medium text-warm-800 dark:text-warm-300", "Password settings"),
                            P(:class => "text-sm text-warm-600 dark:text-warm-400", "Change your password here."),
                        )
                    ),
                )
            )
        ),

        # Three tabs
        ComponentPreview(title="Multiple tabs", description="Tabs with three panels.",
            Div(:class => "w-full max-w-lg",
                Main.Tabs(default_value="overview",
                    Main.TabsList(
                        Main.TabsTrigger("Overview", value="overview"),
                        Main.TabsTrigger("Analytics", value="analytics"),
                        Main.TabsTrigger("Reports", value="reports"),
                    ),
                    Main.TabsContent(value="overview",
                        Div(:class => "p-4",
                            P(:class => "text-sm text-warm-600 dark:text-warm-400", "Overview of your project metrics and recent activity.")
                        )
                    ),
                    Main.TabsContent(value="analytics",
                        Div(:class => "p-4",
                            P(:class => "text-sm text-warm-600 dark:text-warm-400", "Detailed analytics and performance data.")
                        )
                    ),
                    Main.TabsContent(value="reports",
                        Div(:class => "p-4",
                            P(:class => "text-sm text-warm-600 dark:text-warm-400", "Generated reports and exportable summaries.")
                        )
                    ),
                )
            )
        ),

        # Usage
        UsageBlock("""using Suite

Tabs(default_value="account",
    TabsList(
        TabsTrigger("Account", value="account"),
        TabsTrigger("Password", value="password"),
    ),
    TabsContent(value="account",
        P("Account settings content"),
    ),
    TabsContent(value="password",
        P("Password settings content"),
    ),
)"""),

        # Keyboard shortcuts
        KeyboardTable(
            KeyRow("Tab", "Enter/exit the tab list"),
            KeyRow("Arrow Right", "Focus next tab (horizontal)"),
            KeyRow("Arrow Left", "Focus previous tab (horizontal)"),
            KeyRow("Arrow Down", "Focus next tab (vertical)"),
            KeyRow("Arrow Up", "Focus previous tab (vertical)"),
            KeyRow("Home", "Focus first tab"),
            KeyRow("End", "Focus last tab"),
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),
            SectionH3("Tabs"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("default_value", "String", "nothing", "Initially active tab value"),
                        ApiRow("orientation", "String", "\"horizontal\"", "\"horizontal\" or \"vertical\""),
                        ApiRow("activation_mode", "String", "\"automatic\"", "\"automatic\" or \"manual\""),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("TabsList"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("loop", "Bool", "true", "Arrow keys wrap around at ends"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("TabsTrigger"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("value", "String", "\"\"", "Unique tab identifier (required)"),
                        ApiRow("disabled", "Bool", "false", "Disable this tab"),
                        ApiRow("children...", "Any", "-", "Tab label content"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("TabsContent"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("value", "String", "\"\"", "Matching tab identifier (required)"),
                        ApiRow("children...", "Any", "-", "Panel content"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
        )
    )
end




TabsPage
