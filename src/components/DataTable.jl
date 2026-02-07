# SuiteDataTable.jl — Suite.jl DataTable Component
#
# Tier: js_runtime (requires suite.js for sorting, filtering, pagination)
# Suite Dependencies: Table (renders via SuiteTable sub-components)
# JS Modules: DataTable
#
# Usage via package: using Suite; SuiteDataTable(data, columns)
# Usage via extract: include("components/DataTable.jl"); SuiteDataTable(...)
#
# Behavior (matches shadcn/ui DataTable pattern):
#   - Column sorting (click header, asc/desc/none cycle)
#   - Text filtering (input field filters across all columns)
#   - Pagination (page navigation, configurable page size)
#   - Row selection (checkbox column, select all)
#   - Column visibility (toggle column display)
#   - All state managed client-side via suite.js

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteDataTable, SuiteDataTableColumn

# --- SVG Icons ---
const _DT_SORT_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="ml-2 h-4 w-4 inline-block"><path d="m7 15 5 5 5-5"/><path d="m7 9 5-5 5 5"/></svg>"""

const _DT_SORT_ASC_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="ml-2 h-4 w-4 inline-block"><path d="m7 9 5-5 5 5"/></svg>"""

const _DT_SORT_DESC_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="ml-2 h-4 w-4 inline-block"><path d="m7 15 5 5 5-5"/></svg>"""

const _DT_CHEVRON_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="size-4"><path d="m6 9 6 6 6-6"/></svg>"""

"""
    SuiteDataTableColumn

Column definition for SuiteDataTable.

# Fields
- `key::String`: Data field key (accessor)
- `header::String`: Display header text
- `sortable::Bool`: Whether this column is sortable (default true)
- `hideable::Bool`: Whether this column can be hidden (default true)
- `cell::Union{Function,Nothing}`: Custom cell renderer `(value, row) -> VNode` (default nothing)
- `header_class::String`: Additional CSS classes for header cell
- `cell_class::String`: Additional CSS classes for data cells
- `align::String`: Text alignment: "left", "center", "right" (default "left")
"""
struct SuiteDataTableColumn
    key::String
    header::String
    sortable::Bool
    hideable::Bool
    cell::Union{Function,Nothing}
    header_class::String
    cell_class::String
    align::String
end

function SuiteDataTableColumn(key::String, header::String;
    sortable::Bool=true,
    hideable::Bool=true,
    cell::Union{Function,Nothing}=nothing,
    header_class::String="",
    cell_class::String="",
    align::String="left")
    SuiteDataTableColumn(key, header, sortable, hideable, cell, header_class, cell_class, align)
end

# Convenience: pair syntax "key" => "Header"
function SuiteDataTableColumn(pair::Pair{String,String}; kwargs...)
    SuiteDataTableColumn(pair.first, pair.second; kwargs...)
end

"""
    SuiteDataTable(data, columns; kwargs...) -> VNode

A full-featured data table with sorting, filtering, pagination, row selection,
and column visibility. Built on SuiteTable sub-components with suite.js runtime.

Follows the shadcn/ui DataTable pattern (TanStack Table equivalent for Julia).

# Arguments
- `data`: Vector of NamedTuples, Dicts, or any objects with property access
- `columns`: Vector of SuiteDataTableColumn definitions
- `filterable::Bool=true`: Show filter input
- `filter_placeholder::String="Filter..."`: Placeholder text for filter input
- `filter_columns::Vector{String}=String[]`: Columns to filter on (empty = all)
- `sortable::Bool=true`: Enable column sorting
- `paginated::Bool=true`: Enable pagination
- `page_size::Int=10`: Rows per page
- `selectable::Bool=false`: Show row selection checkboxes
- `column_visibility::Bool=false`: Show column visibility toggle
- `caption::String=""`: Table caption
- `class::String=""`: Additional CSS classes
- `theme::Symbol=:default`: Theme name

# Examples
```julia
data = [
    (name="Alice", email="alice@example.com", status="Active", amount=250.00),
    (name="Bob", email="bob@example.com", status="Inactive", amount=150.00),
]

columns = [
    SuiteDataTableColumn("name", "Name"),
    SuiteDataTableColumn("email", "Email"),
    SuiteDataTableColumn("status", "Status"),
    SuiteDataTableColumn("amount", "Amount", align="right"),
]

SuiteDataTable(data, columns, paginated=true, page_size=5, selectable=true)
```
"""
function SuiteDataTable(data::Vector, columns::Vector{SuiteDataTableColumn};
    filterable::Bool=true,
    filter_placeholder::String="Filter...",
    filter_columns::Vector{String}=String[],
    sortable::Bool=true,
    paginated::Bool=true,
    page_size::Int=10,
    selectable::Bool=false,
    column_visibility::Bool=false,
    caption::String="",
    class::String="",
    theme::Symbol=:default,
    kwargs...)

    id = "suite-dt-" * string(rand(UInt32), base=16)

    # Serialize data to JSON for JS consumption
    data_json = _dt_serialize_data(data, columns)

    # Column metadata JSON for JS
    col_meta = _dt_serialize_columns(columns)

    # Build initial table render (page 1, no sort, no filter)
    display_data = paginated ? data[1:min(page_size, length(data))] : data
    total_rows = length(data)
    total_pages = paginated ? max(1, ceil(Int, total_rows / page_size)) : 1

    wrapper_classes = cn("space-y-4", class)
    theme !== :default && (wrapper_classes = apply_theme(wrapper_classes, get_theme(theme)))

    Div(:class => wrapper_classes,
        Symbol("data-suite-datatable") => id,
        Symbol("data-suite-datatable-page-size") => string(page_size),
        Symbol("data-suite-datatable-sortable") => string(sortable),
        Symbol("data-suite-datatable-filterable") => string(filterable),
        Symbol("data-suite-datatable-selectable") => string(selectable),
        Symbol("data-suite-datatable-column-visibility") => string(column_visibility),
        kwargs...,

        # Hidden data store
        Script(:type => "application/json",
               Symbol("data-suite-datatable-store") => id,
               data_json),
        Script(:type => "application/json",
               Symbol("data-suite-datatable-columns") => id,
               col_meta),

        # Toolbar: filter + column visibility
        _dt_toolbar(id, filterable, filter_placeholder, filter_columns,
                    column_visibility, columns, selectable, theme),

        # Table
        _dt_table(id, display_data, columns, selectable, sortable, caption, theme),

        # Pagination footer
        paginated ? _dt_pagination(id, total_rows, total_pages, page_size, selectable, theme) :
            Span(),
    )
end

# --- Internal: Serialize data to JSON ---

function _dt_serialize_data(data::Vector, columns::Vector{SuiteDataTableColumn})
    rows = String[]
    for row in data
        fields = String[]
        for col in columns
            val = _dt_get_value(row, col.key)
            push!(fields, "\"$(col.key)\":$(_dt_json_value(val))")
        end
        push!(rows, "{" * join(fields, ",") * "}")
    end
    "[" * join(rows, ",") * "]"
end

function _dt_serialize_columns(columns::Vector{SuiteDataTableColumn})
    cols = String[]
    for col in columns
        push!(cols, "{\"key\":\"$(col.key)\",\"header\":\"$(col.header)\",\"sortable\":$(col.sortable),\"hideable\":$(col.hideable),\"align\":\"$(col.align)\"}")
    end
    "[" * join(cols, ",") * "]"
end

function _dt_get_value(row, key::String)
    sym = Symbol(key)
    if row isa AbstractDict
        get(row, key, get(row, sym, ""))
    else
        hasproperty(row, sym) ? getproperty(row, sym) : ""
    end
end

function _dt_json_value(val)
    if val isa AbstractString
        "\"" * replace(replace(string(val), "\\" => "\\\\"), "\"" => "\\\"") * "\""
    elseif val isa Number
        string(val)
    elseif val isa Bool
        val ? "true" : "false"
    elseif val === nothing
        "null"
    else
        "\"" * replace(replace(string(val), "\\" => "\\\\"), "\"" => "\\\"") * "\""
    end
end

# --- Internal: Toolbar ---

function _dt_toolbar(id, filterable, placeholder, filter_columns, column_visibility,
                     columns, selectable, theme)
    items = []

    if filterable
        filter_cols_attr = isempty(filter_columns) ? "" : join(filter_columns, ",")
        input_classes = cn("flex h-9 w-full max-w-sm rounded-md border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-950 px-3 py-1 text-sm text-warm-800 dark:text-warm-300 placeholder:text-warm-500 dark:placeholder:text-warm-600 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600 focus-visible:border-accent-600 disabled:cursor-not-allowed disabled:opacity-50")
        theme !== :default && (input_classes = apply_theme(input_classes, get_theme(theme)))
        push!(items, Input(:type => "text",
                          :placeholder => placeholder,
                          :class => input_classes,
                          Symbol("data-suite-datatable-filter") => id,
                          Symbol("data-suite-datatable-filter-columns") => filter_cols_attr))
    end

    if column_visibility
        vis_btn_classes = cn("ml-auto inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium h-9 px-3 border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-950 text-warm-800 dark:text-warm-300 hover:bg-warm-100 dark:hover:bg-warm-900 transition-colors")
        theme !== :default && (vis_btn_classes = apply_theme(vis_btn_classes, get_theme(theme)))

        col_items = []
        for col in columns
            col.hideable || continue
            item_classes = cn("flex items-center gap-2 px-2 py-1.5 text-sm cursor-pointer rounded hover:bg-warm-100 dark:hover:bg-warm-900 text-warm-800 dark:text-warm-300")
            theme !== :default && (item_classes = apply_theme(item_classes, get_theme(theme)))
            push!(col_items,
                Label(:class => item_classes,
                    Input(:type => "checkbox",
                          :checked => "checked",
                          :class => "sr-only",
                          Symbol("data-suite-datatable-col-toggle") => id,
                          :value => col.key),
                    Span("✓ ", Symbol("data-suite-datatable-col-check") => col.key,
                         :class => "text-accent-600 w-4"),
                    Span(col.header),
                ))
        end

        dropdown_classes = cn("absolute right-0 top-full mt-1 z-50 min-w-[150px] rounded-md border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-950 p-1 shadow-md hidden")
        theme !== :default && (dropdown_classes = apply_theme(dropdown_classes, get_theme(theme)))

        push!(items, Div(:class => "relative ml-auto",
            Symbol("data-suite-datatable-col-vis") => id,
            Button(:type => "button",
                   :class => vis_btn_classes,
                   Symbol("data-suite-datatable-col-vis-trigger") => id,
                   "Columns ",
                   Therapy.RawHtml(_DT_CHEVRON_SVG)),
            Div(:class => dropdown_classes,
                Symbol("data-suite-datatable-col-vis-content") => id,
                col_items...),
        ))
    end

    isempty(items) && return Span()

    toolbar_classes = cn("flex items-center gap-2")
    Div(:class => toolbar_classes, items...)
end

# --- Internal: Table render ---

function _dt_table(id, data, columns, selectable, sortable, caption, theme)
    # Header
    header_cells = []
    if selectable
        cb_classes = cn("h-4 w-4 rounded border border-warm-300 dark:border-warm-600 accent-accent-600")
        push!(header_cells,
            Th(:class => "w-12 px-2 align-middle",
                Input(:type => "checkbox",
                      :class => cb_classes,
                      Symbol("data-suite-datatable-select-all") => id,
                      Symbol("aria-label") => "Select all rows")))
    end
    for col in columns
        align_class = col.align == "right" ? "text-right" :
                      col.align == "center" ? "text-center" : "text-left"
        head_classes = cn("h-10 px-2 align-middle font-medium whitespace-nowrap text-warm-600 dark:text-warm-500", align_class, col.header_class)
        theme !== :default && (head_classes = apply_theme(head_classes, get_theme(theme)))

        if sortable && col.sortable
            btn_classes = cn("inline-flex items-center justify-center whitespace-nowrap font-medium transition-colors hover:text-warm-800 dark:hover:text-warm-300 -ml-1 h-8 px-1")
            push!(header_cells,
                Th(:class => head_classes,
                    Symbol("data-suite-datatable-col") => col.key,
                    Button(:type => "button",
                           :class => btn_classes,
                           Symbol("data-suite-datatable-sort") => id,
                           :value => col.key,
                           col.header,
                           Therapy.RawHtml(_DT_SORT_SVG))))
        else
            push!(header_cells,
                Th(:class => head_classes,
                    Symbol("data-suite-datatable-col") => col.key,
                    col.header))
        end
    end

    # Body rows
    body_rows = _dt_render_rows(id, data, columns, selectable, theme)

    # Assemble table
    table_classes = cn("w-full caption-bottom text-sm")
    theme !== :default && (table_classes = apply_theme(table_classes, get_theme(theme)))

    header_row_classes = cn("border-b border-warm-200 dark:border-warm-700")
    theme !== :default && (header_row_classes = apply_theme(header_row_classes, get_theme(theme)))

    Div(:class => "relative w-full overflow-x-auto rounded-md border border-warm-200 dark:border-warm-700",
        Symbol("data-suite-datatable-wrapper") => id,
        Table(:class => table_classes,
            Thead(:class => header_row_classes,
                Tr(header_cells...)),
            Tbody(Symbol("data-suite-datatable-body") => id,
                body_rows...),
            caption != "" ? Caption(:class => "text-warm-600 dark:text-warm-500 mt-4 text-sm", caption) : Span(),
        ),
    )
end

function _dt_render_rows(id, data, columns, selectable, theme)
    rows = []
    if isempty(data)
        colspan = length(columns) + (selectable ? 1 : 0)
        row_classes = cn("border-b border-warm-200 dark:border-warm-700")
        cell_classes = cn("p-2 align-middle text-center text-warm-500 dark:text-warm-600 h-24")
        push!(rows, Tr(:class => row_classes,
            Td(:colspan => string(colspan), :class => cell_classes, "No results.")))
        return rows
    end

    for (i, row) in enumerate(data)
        row_classes = cn("border-b border-warm-200 dark:border-warm-700 transition-colors hover:bg-warm-100/50 dark:hover:bg-warm-900/50 data-[state=selected]:bg-warm-100 dark:data-[state=selected]:bg-warm-900")
        theme !== :default && (row_classes = apply_theme(row_classes, get_theme(theme)))

        cells = []
        if selectable
            cb_classes = cn("h-4 w-4 rounded border border-warm-300 dark:border-warm-600 accent-accent-600")
            push!(cells,
                Td(:class => "w-12 px-2 align-middle",
                    Input(:type => "checkbox",
                          :class => cb_classes,
                          Symbol("data-suite-datatable-select-row") => id,
                          :value => string(i - 1),
                          Symbol("aria-label") => "Select row")))
        end

        for col in columns
            val = _dt_get_value(row, col.key)
            align_class = col.align == "right" ? "text-right" :
                          col.align == "center" ? "text-center" : "text-left"
            cell_classes = cn("p-2 align-middle whitespace-nowrap", align_class, col.cell_class)

            if col.cell !== nothing
                content = col.cell(val, row)
                push!(cells, Td(:class => cell_classes, content))
            else
                push!(cells, Td(:class => cell_classes, string(val)))
            end
        end

        push!(rows, Tr(:class => row_classes,
                       Symbol("data-suite-datatable-row") => id,
                       Symbol("data-row-index") => string(i - 1),
                       cells...))
    end
    rows
end

# --- Internal: Pagination ---

function _dt_pagination(id, total_rows, total_pages, page_size, selectable, theme)
    info_classes = cn("flex-1 text-sm text-warm-600 dark:text-warm-500")
    nav_classes = cn("flex items-center gap-2")

    btn_base = cn("inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium h-9 px-3 border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-950 text-warm-800 dark:text-warm-300 hover:bg-warm-100 dark:hover:bg-warm-900 transition-colors disabled:pointer-events-none disabled:opacity-50")
    theme !== :default && (btn_base = apply_theme(btn_base, get_theme(theme)))

    pagination_classes = cn("flex items-center justify-between px-2 py-4")

    Div(:class => pagination_classes,
        Symbol("data-suite-datatable-pagination") => id,

        # Selection info (left side)
        selectable ?
            Div(:class => info_classes,
                Symbol("data-suite-datatable-selection-info") => id,
                "0 of $total_rows row(s) selected.") :
            Div(:class => info_classes,
                Symbol("data-suite-datatable-row-info") => id,
                "$total_rows row(s) total."),

        # Page navigation (right side)
        Div(:class => nav_classes,
            Span(:class => "text-sm text-warm-600 dark:text-warm-500",
                 Symbol("data-suite-datatable-page-info") => id,
                 "Page 1 of $total_pages"),
            Button(:type => "button",
                   :class => btn_base,
                   :disabled => "disabled",
                   Symbol("data-suite-datatable-prev") => id,
                   "Previous"),
            Button(:type => "button",
                   :class => btn_base,
                   total_pages <= 1 ? (:disabled => "disabled") : (:data_x => ""),
                   Symbol("data-suite-datatable-next") => id,
                   "Next"),
        ),
    )
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :DataTable,
        "DataTable.jl",
        :js_runtime,
        "Full-featured data table with sorting, filtering, pagination, row selection",
        [:Table],
        [:DataTable],
        [:SuiteDataTable, :SuiteDataTableColumn],
    ))
end
