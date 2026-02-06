# Tabs — Suite.jl component docs page
#
# Showcases SuiteTabs with roving tabindex and activation modes.

const SuiteTabs = Main.SuiteTabs
const SuiteTabsList = Main.SuiteTabsList
const SuiteTabsTrigger = Main.SuiteTabsTrigger
const SuiteTabsContent = Main.SuiteTabsContent

function TabsPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Tabs"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A set of layered sections of content — known as tab panels — that are displayed one at a time."
            )
        ),

        # Default Preview
        ComponentPreview(title="Default", description="Click tabs to switch between panels.",
            Div(:class => "w-full max-w-md",
                SuiteTabs(default_value="account",
                    SuiteTabsList(
                        SuiteTabsTrigger("Account", value="account"),
                        SuiteTabsTrigger("Password", value="password"),
                    ),
                    SuiteTabsContent(value="account",
                        Div(:class => "p-4 space-y-2",
                            P(:class => "text-sm font-medium text-warm-800 dark:text-warm-200", "Account settings"),
                            P(:class => "text-sm text-warm-600 dark:text-warm-400", "Make changes to your account here."),
                        )
                    ),
                    SuiteTabsContent(value="password",
                        Div(:class => "p-4 space-y-2",
                            P(:class => "text-sm font-medium text-warm-800 dark:text-warm-200", "Password settings"),
                            P(:class => "text-sm text-warm-600 dark:text-warm-400", "Change your password here."),
                        )
                    ),
                )
            )
        ),

        # Three tabs
        ComponentPreview(title="Multiple tabs", description="Tabs with three panels.",
            Div(:class => "w-full max-w-lg",
                SuiteTabs(default_value="overview",
                    SuiteTabsList(
                        SuiteTabsTrigger("Overview", value="overview"),
                        SuiteTabsTrigger("Analytics", value="analytics"),
                        SuiteTabsTrigger("Reports", value="reports"),
                    ),
                    SuiteTabsContent(value="overview",
                        Div(:class => "p-4",
                            P(:class => "text-sm text-warm-600 dark:text-warm-400", "Overview of your project metrics and recent activity.")
                        )
                    ),
                    SuiteTabsContent(value="analytics",
                        Div(:class => "p-4",
                            P(:class => "text-sm text-warm-600 dark:text-warm-400", "Detailed analytics and performance data.")
                        )
                    ),
                    SuiteTabsContent(value="reports",
                        Div(:class => "p-4",
                            P(:class => "text-sm text-warm-600 dark:text-warm-400", "Generated reports and exportable summaries.")
                        )
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

SuiteTabs(default_value="account",
    SuiteTabsList(
        SuiteTabsTrigger("Account", value="account"),
        SuiteTabsTrigger("Password", value="password"),
    ),
    SuiteTabsContent(value="account",
        P("Account settings content"),
    ),
    SuiteTabsContent(value="password",
        P("Password settings content"),
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
                        KeyRow("Tab", "Enter/exit the tab list"),
                        KeyRow("Arrow Right", "Focus next tab (horizontal)"),
                        KeyRow("Arrow Left", "Focus previous tab (horizontal)"),
                        KeyRow("Arrow Down", "Focus next tab (vertical)"),
                        KeyRow("Arrow Up", "Focus previous tab (vertical)"),
                        KeyRow("Home", "Focus first tab"),
                        KeyRow("End", "Focus last tab"),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "API Reference"
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteTabs"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("default_value", "String", "nothing", "Initially active tab value"),
                        ApiRow("orientation", "String", "\"horizontal\"", "\"horizontal\" or \"vertical\""),
                        ApiRow("activation_mode", "String", "\"automatic\"", "\"automatic\" or \"manual\""),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteTabsList"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("loop", "Bool", "true", "Arrow keys wrap around at ends"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteTabsTrigger"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("value", "String", "\"\"", "Unique tab identifier (required)"),
                        ApiRow("disabled", "Bool", "false", "Disable this tab"),
                        ApiRow("children...", "Any", "-", "Tab label content"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "SuiteTabsContent"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("value", "String", "\"\"", "Matching tab identifier (required)"),
                        ApiRow("children...", "Any", "-", "Panel content"),
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

TabsPage
