# Scroll Area — Suite.jl component docs page
#
# Showcases ScrollArea for scrollable containers.


function ScrollAreaPage()
    ComponentsLayout(
        # Header
        PageHeader("Scroll Area", "Augments native scroll functionality for custom, cross-browser styling."),

        # Default Preview
        ComponentPreview(title="Default", description="A scrollable area with a fixed height.",
            Main.ScrollArea(class="h-[200px] w-[350px] rounded-md border border-warm-200 dark:border-warm-700 p-4",
                Div(:class => "space-y-4",
                    map(1:20) do i
                        Fragment(
                            Div(:class => "text-sm text-warm-800 dark:text-warm-300", "Item $i"),
                            if i < 20; Main.Separator() else Fragment() end
                        )
                    end...
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            SectionH2("Usage"),
            Main.CodeBlock(language="julia", """using Suite

ScrollArea(
    class="h-[200px] w-[350px] rounded-md border p-4",
    P("Scrollable content here..."),
)""")
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(
                        Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                        )
                    ),
                    Main.TableBody(
                        ApiRow("class", "String", "\"\"", "Size and styling (h-[200px], w-[350px], etc.)"),
                        ApiRow("children...", "Any", "-", "Scrollable content"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute")
                    )
                )
            )
        )
    )
end


ScrollAreaPage
