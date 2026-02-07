# Avatar — Suite.jl component docs page
#
# Showcases Avatar with image, fallback, and sizes.


function AvatarPage()
    ComponentsLayout(
        # Header
        PageHeader("Avatar", "An image element with a fallback for representing the user."),

        # Default Preview
        ComponentPreview(title="With Fallback", description="Avatar showing initials when no image is available.",
            Div(:class => "flex items-center gap-4",
                Main.Avatar(Main.AvatarFallback("JD")),
                Main.Avatar(Main.AvatarFallback("AB")),
                Main.Avatar(Main.AvatarFallback("CN"))
            )
        ),

        # Sizes
        ComponentPreview(title="Sizes", description="Available avatar sizes.",
            Div(:class => "flex items-center gap-4",
                Main.Avatar(size="sm", Main.AvatarFallback("S")),
                Main.Avatar(Main.AvatarFallback("M")),
                Main.Avatar(size="lg", Main.AvatarFallback("L"))
            )
        ),

        # Usage
        UsageBlock("""using Suite

Avatar(
    AvatarImage(src="/avatar.jpg", alt="User"),
    AvatarFallback("JD"),
)

Avatar(size="lg",
    AvatarFallback("AB"),
)"""),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),

            SectionH3("Avatar"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("size", "String", "\"default\"", "default | sm | lg"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("children...", "Any", "-", "AvatarImage and/or AvatarFallback"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute"),
                    )
                )
            ),

            SectionH3("AvatarImage"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("src", "String", "\"\"", "Image URL"),
                        ApiRow("alt", "String", "\"\"", "Alt text for accessibility"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute"),
                    )
                )
            ),

            SectionH3("AvatarFallback"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("children...", "Any", "-", "Fallback content (initials, icon)"),
                        ApiRow("kwargs...", "Pair", "-", "Any HTML attribute"),
                    )
                )
            )
        )
    )
end


AvatarPage
