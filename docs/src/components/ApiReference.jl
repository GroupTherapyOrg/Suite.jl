# ApiReference.jl - Shared API reference table components for docs pages

"""
Render an API reference table with prop/type/default/description columns.
"""
function ApiTable(rows...)
    Div(:class => "mt-12 space-y-6",
        SectionH2("API Reference"),
        Div(:class => "overflow-x-auto",
            Main.Table(
                Main.TableHeader(Main.TableRow(
                    Main.TableHead("Prop"),
                    Main.TableHead("Type"),
                    Main.TableHead("Default"),
                    Main.TableHead("Description"),
                )),
                Main.TableBody(rows...)
            )
        )
    )
end

"""
Render the API table header row (for use with raw Table wrapping).
"""
function ApiHead()
    Main.TableRow(
        Main.TableHead("Prop"),
        Main.TableHead("Type"),
        Main.TableHead("Default"),
        Main.TableHead("Description"),
    )
end

"""
Render a single row in the API reference table.
"""
function ApiRow(prop, type, default, description)
    Main.TableRow(
        Main.TableCell(:class => "text-accent-600 dark:text-accent-400 font-mono text-xs", prop),
        Main.TableCell(:class => "font-mono text-xs", type),
        Main.TableCell(:class => "font-mono text-xs", default),
        Main.TableCell(description),
    )
end

"""
Render a keyboard interactions table.
"""
function KeyboardTable(rows...)
    Div(:class => "mt-12 space-y-6",
        SectionH2("Keyboard Interactions"),
        Div(:class => "overflow-x-auto",
            Main.Table(
                Main.TableHeader(Main.TableRow(
                    Main.TableHead("Key"),
                    Main.TableHead("Action"),
                )),
                Main.TableBody(rows...)
            )
        )
    )
end

"""
Render a keyboard shortcut row with Kbd component.
"""
function KeyRow(key, action)
    Main.TableRow(
        Main.TableCell(Main.Kbd(key)),
        Main.TableCell(action),
    )
end

"""
Render a code usage example block.
"""
function UsageBlock(code::String)
    Div(:class => "mt-12 space-y-6",
        SectionH2("Usage"),
        Main.CodeBlock(code, language="julia"),
    )
end

"""
Render a page header with title and description.
"""
function PageHeader(title::String, description::String)
    Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
        H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3", title),
        P(:class => "text-lg text-warm-600 dark:text-warm-300", description)
    )
end

"""
Render a section H2 heading (shared styling for all docs pages).
"""
function SectionH2(text::String)
    H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4", text)
end

"""
Render a section H3 heading (shared styling for all docs pages).
"""
function SectionH3(text::String)
    H3(:class => "text-xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3", text)
end
