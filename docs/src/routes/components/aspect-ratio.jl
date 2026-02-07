# Aspect Ratio — Suite.jl component docs page
#
# Showcases AspectRatio for fixed-ratio containers.


function AspectRatioPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3",
                "Aspect Ratio"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "Displays content within a desired ratio."
            )
        ),

        # 16:9 Preview
        ComponentPreview(title="16:9", description="The default 16:9 aspect ratio.",
            Div(:class => "w-[450px]",
                Main.AspectRatio(ratio=16/9,
                    Div(:class => "flex size-full items-center justify-center rounded-md bg-warm-200 dark:bg-warm-800 text-warm-600 dark:text-warm-400 text-sm",
                        "16:9"
                    )
                )
            )
        ),

        # 1:1 Preview
        ComponentPreview(title="1:1 (Square)", description="Square aspect ratio.",
            Div(:class => "w-[200px]",
                Main.AspectRatio(ratio=1/1,
                    Div(:class => "flex size-full items-center justify-center rounded-md bg-warm-200 dark:bg-warm-800 text-warm-600 dark:text-warm-400 text-sm",
                        "1:1"
                    )
                )
            )
        ),

        # 4:3 Preview
        ComponentPreview(title="4:3", description="Classic 4:3 ratio.",
            Div(:class => "w-[300px]",
                Main.AspectRatio(ratio=4/3,
                    Div(:class => "flex size-full items-center justify-center rounded-md bg-warm-200 dark:bg-warm-800 text-warm-600 dark:text-warm-400 text-sm",
                        "4:3"
                    )
                )
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "Usage"
            ),
            Main.CodeBlock(language="julia", """using Suite

AspectRatio(ratio=16/9,
    Img(:src => "/photo.jpg", :alt => "Photo",
        :class => "size-full object-cover"),
)

AspectRatio(ratio=1/1,
    Div("Square content"),
)""")
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "API Reference"
            ),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(
                        Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                        )
                    ),
                    Tbody(
                        ApiRow("ratio", "Real", "16/9", "Aspect ratio (width/height)"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("children...", "Any", "-", "Content to display within the ratio"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute")
                    )
                )
            )
        )
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

AspectRatioPage
