# ApiReference.jl - Shared API reference table components for docs pages

"""
Render an API reference table with prop/type/default/description columns.
"""
function ApiTable(rows...)
    Div(:class => "mt-12 space-y-6",
        H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
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
                Tbody(rows...)
            )
        )
    )
end

"""
Render a single row in the API reference table.
"""
function ApiRow(prop, type, default, description)
    Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
        Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", prop),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", type),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", default),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", description)
    )
end

"""
Render a code usage example block.
"""
function UsageBlock(code::String)
    Div(:class => "mt-12 space-y-6",
        H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
            "Usage"
        ),
        Div(:class => "bg-warm-800 dark:bg-warm-950 rounded-md border border-warm-700 p-6 overflow-x-auto",
            Pre(:class => "text-sm text-warm-50",
                Code(:class => "language-julia", code)
            )
        )
    )
end

"""
Render a page header with title and description.
"""
function PageHeader(title::String, description::String)
    Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
        H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3", title),
        P(:class => "text-lg text-warm-600 dark:text-warm-300", description)
    )
end
