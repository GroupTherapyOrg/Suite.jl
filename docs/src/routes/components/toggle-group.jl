# Toggle Group — Suite.jl component docs page
#
# Showcases ToggleGroup with single/multiple modes and variants.


function ToggleGroupPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Toggle Group"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A group of toggle buttons where selection is managed collectively."
            )
        ),

        # Single selection
        ComponentPreview(title="Single selection", description="Only one item can be active at a time.",
            Main.ToggleGroup(type="single", default_value="center",
                Main.ToggleGroupItem(value="left", "Left"),
                Main.ToggleGroupItem(value="center", "Center"),
                Main.ToggleGroupItem(value="right", "Right"),
            )
        ),

        # Multiple selection
        ComponentPreview(title="Multiple selection", description="Any combination of items can be active.",
            Main.ToggleGroup(type="multiple", default_value=["bold", "italic"],
                Main.ToggleGroupItem(value="bold", "B"),
                Main.ToggleGroupItem(value="italic", "I"),
                Main.ToggleGroupItem(value="underline", "U"),
            )
        ),

        # Outline variant
        ComponentPreview(title="Outline variant", description="Toggle group with outlined items.",
            Main.ToggleGroup(type="single", variant="outline",
                Main.ToggleGroupItem(value="a", "A"),
                Main.ToggleGroupItem(value="b", "B"),
                Main.ToggleGroupItem(value="c", "C"),
            )
        ),

        # Sizes
        ComponentPreview(title="Sizes", description="Small, default, and large sizes.",
            Div(:class => "flex flex-col gap-4",
                Main.ToggleGroup(type="single", size="sm",
                    Main.ToggleGroupItem(value="1", "Sm"),
                    Main.ToggleGroupItem(value="2", "Sm"),
                ),
                Main.ToggleGroup(type="single",
                    Main.ToggleGroupItem(value="1", "Default"),
                    Main.ToggleGroupItem(value="2", "Default"),
                ),
                Main.ToggleGroup(type="single", size="lg",
                    Main.ToggleGroupItem(value="1", "Lg"),
                    Main.ToggleGroupItem(value="2", "Lg"),
                ),
            )
        ),

        # Disabled
        ComponentPreview(title="Disabled", description="A disabled toggle group.",
            Main.ToggleGroup(type="single", disabled=true,
                Main.ToggleGroupItem(value="a", "A"),
                Main.ToggleGroupItem(value="b", "B"),
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

# Single selection
ToggleGroup(type="single", default_value="center",
    ToggleGroupItem(value="left", "Left"),
    ToggleGroupItem(value="center", "Center"),
    ToggleGroupItem(value="right", "Right"),
)

# Multiple selection
ToggleGroup(type="multiple",
    ToggleGroupItem(value="bold", "B"),
    ToggleGroupItem(value="italic", "I"),
    ToggleGroupItem(value="underline", "U"),
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
                        KeyRow("Enter / Space", "Toggle the focused item"),
                        KeyRow("Arrow Right", "Focus next item (horizontal)"),
                        KeyRow("Arrow Left", "Focus previous item (horizontal)"),
                        KeyRow("Arrow Down", "Focus next item (vertical)"),
                        KeyRow("Arrow Up", "Focus previous item (vertical)"),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "API Reference"
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "ToggleGroup"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("type", "String", "\"single\"", "\"single\" or \"multiple\" — selection mode"),
                        ApiRow("default_value", "String/Vector", "nothing", "Initially selected value(s)"),
                        ApiRow("variant", "String", "\"default\"", "\"default\" or \"outline\""),
                        ApiRow("size", "String", "\"default\"", "\"default\", \"sm\", or \"lg\""),
                        ApiRow("orientation", "String", "\"horizontal\"", "\"horizontal\" or \"vertical\""),
                        ApiRow("disabled", "Bool", "false", "Disable all items"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "ToggleGroupItem"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("value", "String", "\"\"", "Unique identifier for this item (required)"),
                        ApiRow("variant", "String", "\"default\"", "Override group variant"),
                        ApiRow("size", "String", "\"default\"", "Override group size"),
                        ApiRow("disabled", "Bool", "false", "Disable this specific item"),
                        ApiRow("children...", "Any", "-", "Item content (text, icons)"),
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

ToggleGroupPage
