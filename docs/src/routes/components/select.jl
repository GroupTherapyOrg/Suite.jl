# Select — Suite.jl component docs page
#
# Showcases Select with basic usage, grouped items, and keyboard nav.


function SelectPage()
    ComponentsLayout(
        # Header
        PageHeader("Select", "Displays a list of options for the user to pick from, triggered by a button."),

        # Basic Preview
        ComponentPreview(title="Basic", description="A simple fruit selector with five options.",
            Div(:class => "w-full max-w-xs",
                Main.Select(
                    Main.SelectTrigger(
                        Main.SelectValue(placeholder="Select a fruit"),
                    ),
                    Main.SelectContent(
                        Main.SelectScrollUpButton(),
                        Main.SelectItem(value="apple", "Apple"),
                        Main.SelectItem(value="banana", "Banana"),
                        Main.SelectItem(value="orange", "Orange"),
                        Main.SelectItem(value="grape", "Grape"),
                        Main.SelectItem(value="mango", "Mango"),
                        Main.SelectScrollDownButton(),
                    ),
                )
            )
        ),

        # With Groups
        ComponentPreview(title="With Groups", description="Items organized into labeled groups with a separator.",
            Div(:class => "w-full max-w-xs",
                Main.Select(
                    Main.SelectTrigger(
                        Main.SelectValue(placeholder="Select an option"),
                    ),
                    Main.SelectContent(
                        Main.SelectScrollUpButton(),
                        Main.SelectGroup(
                            Main.SelectLabel("Fruits"),
                            Main.SelectItem(value="apple", "Apple"),
                            Main.SelectItem(value="banana", "Banana"),
                            Main.SelectItem(value="orange", "Orange"),
                        ),
                        Main.SelectSeparator(),
                        Main.SelectGroup(
                            Main.SelectLabel("Vegetables"),
                            Main.SelectItem(value="carrot", "Carrot"),
                            Main.SelectItem(value="broccoli", "Broccoli"),
                            Main.SelectItem(value="spinach", "Spinach"),
                        ),
                        Main.SelectScrollDownButton(),
                    ),
                )
            )
        ),

        # Usage
        UsageBlock("""using Suite

Select(
    SelectTrigger(
        SelectValue(placeholder="Select a fruit"),
    ),
    SelectContent(
        SelectItem(value="apple", "Apple"),
        SelectItem(value="banana", "Banana"),
        SelectItem(value="orange", "Orange"),
    ),
)"""),

        # Keyboard shortcuts
        KeyboardTable(
            KeyRow("Arrow Down", "Move focus to the next item"),
            KeyRow("Arrow Up", "Move focus to the previous item"),
            KeyRow("Enter / Space", "Select the focused item"),
            KeyRow("Escape", "Close the select dropdown"),
            KeyRow("Home", "Move focus to the first item"),
            KeyRow("End", "Move focus to the last item"),
            KeyRow("Type-ahead", "Search by typing (1s timeout)"),
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),
            SectionH3("Select"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Select sub-components"),
                    )
                )
            ),
            SectionH3("SelectTrigger"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Trigger content (shows selected value)"),
                    )
                )
            ),
            SectionH3("SelectValue"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("placeholder", "String", "\"Select an option\"", "Text shown when no value is selected"),
                    )
                )
            ),
            SectionH3("SelectContent"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Content items and groups"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("SelectItem"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("value", "String", "-", "Unique value for this item (required)"),
                        ApiRow("disabled", "Bool", "false", "Disable this item"),
                        ApiRow("children...", "Any", "-", "Item display text"),
                    )
                )
            ),
            SectionH3("SelectGroup"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Group label and items (container)"),
                    )
                )
            ),
            SectionH3("SelectLabel"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("children...", "Any", "-", "Group label text"),
                    )
                )
            ),
            SectionH3("SelectSeparator"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("SelectScrollUpButton"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            SectionH3("SelectScrollDownButton"),
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




SelectPage
