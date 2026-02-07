# Table.jl — Suite.jl Table Component
#
# Tier: styling (pure HTML + Tailwind classes, no JS/Wasm)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Table(TableHeader(...), TableBody(...))
# Usage via extract: include("components/Table.jl"); Table(...)
#
# Reference: shadcn/ui Table — https://ui.shadcn.com/docs/components/table

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Table, TableHeader, TableBody, TableFooter,
       TableRow, TableHead, TableCell, TableCaption

"""
    Table(children...; class, kwargs...) -> VNode

A styled data table with scrollable container.
Equivalent to shadcn/ui's Table component.

# Examples
```julia
Table(
    TableHeader(
        TableRow(
            TableHead("Name"),
            TableHead("Email"),
        ),
    ),
    TableBody(
        TableRow(
            TableCell("Alice"),
            TableCell("alice@example.com"),
        ),
    ),
)
```
"""
function Table(children...; class::String="", kwargs...)
    table_classes = cn("w-full caption-bottom text-sm", class)

    Div(:class => "relative w-full overflow-x-auto",
        Therapy.Table(:class => table_classes, kwargs..., children...),
    )
end

"""
    TableHeader(children...; class, kwargs...) -> VNode

Table header section (`<thead>`).
"""
function TableHeader(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("border-b border-warm-200 dark:border-warm-700", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    Thead(:class => classes, kwargs..., children...)
end

"""
    TableBody(children...; class, kwargs...) -> VNode

Table body section (`<tbody>`).
"""
function TableBody(children...; class::String="", kwargs...)
    classes = cn("", class)
    Tbody(:class => classes, kwargs..., children...)
end

"""
    TableFooter(children...; class, kwargs...) -> VNode

Table footer section (`<tfoot>`).
"""
function TableFooter(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("bg-warm-100/50 dark:bg-warm-900/50 border-t border-warm-200 dark:border-warm-700 font-medium", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    Tfoot(:class => classes, kwargs..., children...)
end

"""
    TableRow(children...; class, kwargs...) -> VNode

A table row (`<tr>`).
"""
function TableRow(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("border-b border-warm-200 dark:border-warm-700 transition-colors hover:bg-warm-100/50 dark:hover:bg-warm-900/50", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    Tr(:class => classes, kwargs..., children...)
end

"""
    TableHead(children...; class, kwargs...) -> VNode

A table header cell (`<th>`).
"""
function TableHead(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("h-10 px-2 text-left align-middle font-medium whitespace-nowrap text-warm-600 dark:text-warm-500", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    Th(:class => classes, kwargs..., children...)
end

"""
    TableCell(children...; class, kwargs...) -> VNode

A table data cell (`<td>`).
"""
function TableCell(children...; class::String="", kwargs...)
    classes = cn("p-2 align-middle whitespace-nowrap", class)
    Td(:class => classes, kwargs..., children...)
end

"""
    TableCaption(children...; class, kwargs...) -> VNode

A table caption (`<caption>`).
"""
function TableCaption(children...; class::String="", theme::Symbol=:default, kwargs...)
    classes = cn("text-warm-600 dark:text-warm-500 mt-4 text-sm", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    Caption(:class => classes, kwargs..., children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Table,
        "Table.jl",
        :styling,
        "Styled data table with header, body, footer",
        Symbol[],
        Symbol[],
        [:Table, :TableHeader, :TableBody, :TableFooter,
         :TableRow, :TableHead, :TableCell, :TableCaption],
    ))
end
