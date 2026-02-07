# Alert — Suite.jl component docs page
#
# Showcases Alert with all variants and sub-components.


function AlertPage()
    ComponentsLayout(
        # Header
        PageHeader("Alert", "Displays a callout for important information."),

        # Default Preview
        ComponentPreview(title="Default", description="The default alert with neutral styling.",
            Main.Alert(
                Main.AlertTitle("Heads up!"),
                Main.AlertDescription("You can add components to your app using the CLI.")
            )
        ),

        # Destructive
        ComponentPreview(title="Destructive", description="Alert with destructive/error styling.",
            Main.Alert(variant="destructive",
                Main.AlertTitle("Error"),
                Main.AlertDescription("Your session has expired. Please log in again.")
            )
        ),

        # Usage
        UsageBlock("""using Suite

Alert(
    AlertTitle("Heads up!"),
    AlertDescription("You can add components using the CLI."),
)

Alert(variant="destructive",
    AlertTitle("Error"),
    AlertDescription("Something went wrong."),
)"""),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),

            # Alert
            SectionH3("Alert"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("variant", "String", "\"default\"", "default | destructive"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes to merge"),
                        ApiRow("children...", "Any", "-", "Alert content (AlertTitle, AlertDescription)"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute"),
                    )
                )
            ),

            # AlertTitle
            SectionH3("AlertTitle"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("children...", "Any", "-", "Title text"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute"),
                    )
                )
            ),

            # AlertDescription
            SectionH3("AlertDescription"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("children...", "Any", "-", "Description text"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute"),
                    )
                )
            )
        )
    )
end


AlertPage
