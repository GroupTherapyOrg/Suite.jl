# Calendar.jl — Suite.jl Calendar Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none
# JS Modules: none
#
# Usage via package: using Suite; Calendar()
# Usage via extract: include("components/Calendar.jl"); Calendar()
#
# Behavior (Full Wasm):
#   - Month grid with day selection via compiled match_descendants / bit_descendants
#   - Month navigation via prev/next buttons (data-index 50/51)
#   - 12 pre-rendered month panels shown/hidden via MatchShow
#   - Single mode: match_descendants (data-state open when signal == index)
#   - Multiple mode: bit_descendants (data-state open when bit N set)
#   - DatePicker: split island (parent + trigger) with ShowDescendants
#
# Architecture:
#   - Single @island with 2 signals + 1 click handler (event delegation)
#   - Signal 1 (month_idx): Int32 0-11, which panel to show
#   - Signal 2 (selected): Int32, -1=none (single) or bitmask (multiple)
#   - 42 day cells per panel with data-index (0-41) → match/bit descendants
#   - Nav buttons with data-index 50 (prev) / 51 (next)
#   - 12 MatchShow panels: SSR pre-renders all 12, Wasm shows/hides
#
# Reference: Thaw Calendar — github.com/thaw-ui/thaw
# Reference: WAI-ARIA Grid — https://www.w3.org/WAI/ARIA/apg/patterns/grid/

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

using Dates

# --- Component Implementation ---

export Calendar, DatePicker

# --- MatchShow SSR function ---
# MatchShow is an AST-level construct (IslandTransform.jl detects it and generates
# hydrate_match_binding calls). This runtime function is only used for SSR evaluation.
function MatchShow(render::Function, signal_getter, match_value)
    content = render()
    visible = try signal_getter() == match_value catch; false end
    Div(:style => visible ? "" : "display:none", content)
end

# --- SVG Icons ---
const _CALENDAR_CHEVRON_LEFT = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m15 18-6-6 6-6"/></svg>"""

const _CALENDAR_CHEVRON_RIGHT = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>"""

const _CALENDAR_ICON_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/></svg>"""

# Day name abbreviations
const _DAY_ABBRS = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
const _DAY_NAMES = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

# Month names
const _MONTH_NAMES = ["January", "February", "March", "April", "May", "June",
                      "July", "August", "September", "October", "November", "December"]

"""
    _calendar_weeks(year, month; show_outside_days=true) -> Vector{Vector{NamedTuple}}

Generate the grid of days for a calendar month. Each week is 7 days.
Returns weeks of (date, day_num, outside, today) tuples.
Monday-first week (ISO standard).
"""
function _calendar_weeks(year::Int, month::Int; show_outside_days::Bool=true)
    first_day = Date(year, month, 1)
    last_day = Dates.lastdayofmonth(first_day)
    today = Dates.today()

    # Monday = 1, Sunday = 7 (Julia's dayofweek)
    start_dow = Dates.dayofweek(first_day)  # 1=Mon ... 7=Sun

    # Fill from the Monday of the week containing the 1st
    grid_start = first_day - Dates.Day(start_dow - 1)

    # We need enough weeks to cover the month (4-6 weeks)
    # Calculate end: last day's week, go to Sunday
    end_dow = Dates.dayofweek(last_day)
    grid_end = last_day + Dates.Day(7 - end_dow)

    weeks = Vector{Vector{NamedTuple{(:date, :day_num, :outside, :is_today, :iso_date), Tuple{Date, Int, Bool, Bool, String}}}}()

    current = grid_start
    while current <= grid_end
        week = []
        for _ in 1:7
            is_outside = Dates.month(current) != month
            push!(week, (
                date = current,
                day_num = Dates.day(current),
                outside = is_outside,
                is_today = current == today,
                iso_date = string(current),
            ))
            current += Dates.Day(1)
        end
        push!(weeks, week)
    end

    weeks
end

"""Build nav buttons with data-index for Wasm event delegation."""
function _calendar_nav(theme::Symbol=:default)
    Nav(:class => "flex items-center justify-between absolute top-3 inset-x-3 z-10",
        :aria_label => "Calendar navigation",
        Therapy.Button(:type => "button",
               :class => cn(_nav_button_classes(theme)),
               Symbol("data-index") => "50",
               :aria_label => "Go to previous month",
               Therapy.RawHtml(_CALENDAR_CHEVRON_LEFT)),
        Therapy.Button(:type => "button",
               :class => cn(_nav_button_classes(theme)),
               Symbol("data-index") => "51",
               :aria_label => "Go to next month",
               Therapy.RawHtml(_CALENDAR_CHEVRON_RIGHT)),
    )
end

# --- Props Transform ---
# Alphabetically sorted underscore props → compiled_get_prop_i32 indices:
#   _m (index 0) = initial month panel (always 0)
#   _mode (index 1) = 0=single, 1=multiple
#   _s (index 2) = initial selected: -1 (single), 0 (multiple)
const _CALENDAR_PROPS_TRANSFORM = (props, args) -> begin
    mode = get(props, :mode, "single")
    mode_flag = mode == "single" ? 0 : 1
    props[:_m] = 0
    props[:_mode] = mode_flag
    props[:_s] = mode_flag == 0 ? -1 : 0
end

@island function Calendar(; mode::String="single",
                        month::Int=Dates.month(Dates.today()),
                        year::Int=Dates.year(Dates.today()),
                        selected::String="",
                        disabled_dates::String="",
                        show_outside_days::Bool=true,
                        fixed_weeks::Bool=false,
                        number_of_months::Int=1,
                        class::String="",
                        theme::Symbol=:default,
                        kwargs...)
    # ─── Signals ───
    # Signal 0 (global 1): month_idx — which pre-rendered panel to show (0-11)
    month_idx, set_month_idx = create_signal(compiled_get_prop_i32(Int32(0)))
    # Signal 1 (global 2): selected — day index (single) or bitmask (multiple)
    selected_val, set_selected = create_signal(compiled_get_prop_i32(Int32(2)))

    # Mode-dependent binding on signal 1 (global 2) for day selection highlight
    mf = compiled_get_prop_i32(Int32(1))
    if mf == Int32(0)
        # Single mode: data-state = open when signal == index
        compiled_register_match_descendants(Int32(2), Int32(0))
    end
    if mf != Int32(0)
        # Multiple mode: data-state = open when bit N is set
        compiled_register_bit_descendants(Int32(2), Int32(0))
    end

    # ─── SSR Setup ───
    id = "suite-calendar-" * string(rand(UInt32), base=16)

    root_classes = cn(
        "p-3 text-warm-800 dark:text-warm-300",
        class
    )
    theme !== :default && (root_classes = apply_theme(root_classes, get_theme(theme)))

    # Pre-compute 12 month/year pairs starting from initial month
    _panels_data = [( ((month-1+i)%12)+1, year+((month-1+i)÷12) ) for i in 0:11]

    # Root with nav + 12 MatchShow panels
    Div(Symbol("data-calendar") => id,
        Symbol("data-calendar-mode") => mode,
        Symbol("data-calendar-month") => string(month),
        Symbol("data-calendar-year") => string(year),
        Symbol("data-calendar-selected") => selected,
        Symbol("data-calendar-disabled") => disabled_dates,
        Symbol("data-calendar-show-outside") => show_outside_days ? "true" : "false",
        Symbol("data-calendar-fixed-weeks") => fixed_weeks ? "true" : "false",
        Symbol("data-calendar-months-count") => string(number_of_months),
        :class => root_classes,
        :style => "position:relative",
        kwargs...,
        :on_click => () -> begin
            idx = compiled_get_event_data_index()
            # Nav: prev button (data-index 50)
            if idx == Int32(50)
                m = month_idx()
                if m != Int32(0)
                    set_month_idx(m - Int32(1))
                    set_selected(compiled_get_prop_i32(Int32(2)))
                end
            end
            # Nav: next button (data-index 51)
            if idx == Int32(51)
                m = month_idx()
                if m != Int32(11)
                    set_month_idx(m + Int32(1))
                    set_selected(compiled_get_prop_i32(Int32(2)))
                end
            end
            # Day cell (0-41)
            if idx >= Int32(0)
                if idx < Int32(42)
                    mf = compiled_get_prop_i32(Int32(1))
                    if mf == Int32(0)
                        set_selected(idx)
                    end
                    if mf != Int32(0)
                        mask = Core.Intrinsics.shl_int(Int32(1), idx)
                        set_selected(xor(selected_val(), mask))
                    end
                end
            end
        end,
        _calendar_nav(theme),
        Div(:class => "flex flex-col",
            MatchShow(month_idx, Int32(0)) do
                _calendar_month_panel(id, _panels_data[1]..., show_outside_days, fixed_weeks, mode, theme)
            end,
            MatchShow(month_idx, Int32(1)) do
                _calendar_month_panel(id, _panels_data[2]..., show_outside_days, fixed_weeks, mode, theme)
            end,
            MatchShow(month_idx, Int32(2)) do
                _calendar_month_panel(id, _panels_data[3]..., show_outside_days, fixed_weeks, mode, theme)
            end,
            MatchShow(month_idx, Int32(3)) do
                _calendar_month_panel(id, _panels_data[4]..., show_outside_days, fixed_weeks, mode, theme)
            end,
            MatchShow(month_idx, Int32(4)) do
                _calendar_month_panel(id, _panels_data[5]..., show_outside_days, fixed_weeks, mode, theme)
            end,
            MatchShow(month_idx, Int32(5)) do
                _calendar_month_panel(id, _panels_data[6]..., show_outside_days, fixed_weeks, mode, theme)
            end,
            MatchShow(month_idx, Int32(6)) do
                _calendar_month_panel(id, _panels_data[7]..., show_outside_days, fixed_weeks, mode, theme)
            end,
            MatchShow(month_idx, Int32(7)) do
                _calendar_month_panel(id, _panels_data[8]..., show_outside_days, fixed_weeks, mode, theme)
            end,
            MatchShow(month_idx, Int32(8)) do
                _calendar_month_panel(id, _panels_data[9]..., show_outside_days, fixed_weeks, mode, theme)
            end,
            MatchShow(month_idx, Int32(9)) do
                _calendar_month_panel(id, _panels_data[10]..., show_outside_days, fixed_weeks, mode, theme)
            end,
            MatchShow(month_idx, Int32(10)) do
                _calendar_month_panel(id, _panels_data[11]..., show_outside_days, fixed_weeks, mode, theme)
            end,
            MatchShow(month_idx, Int32(11)) do
                _calendar_month_panel(id, _panels_data[12]..., show_outside_days, fixed_weeks, mode, theme)
            end,
        ))
end

function _nav_button_classes(theme::Symbol=:default)
    classes = "inline-flex items-center justify-center cursor-pointer rounded-md h-7 w-7 bg-transparent hover:bg-warm-100 dark:hover:bg-warm-900 text-warm-800 dark:text-warm-300 border border-warm-200 dark:border-warm-700 p-0 opacity-75 hover:opacity-100 transition-opacity"
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    classes
end

"""
Build a single month panel with caption + grid.
Always renders exactly 6 weeks (42 cells) for Wasm grid update compatibility.
Simplified caption: just month name + year text (no data-index on caption elements).
"""
function _calendar_month_panel(cal_id, month, year, show_outside_days, fixed_weeks, mode, theme)
    weeks = _calendar_weeks(year, month; show_outside_days=true)  # Always generate all outside days

    # Pad to exactly 6 weeks for consistent 42-cell grid
    if length(weeks) < 6
        last_date = weeks[end][end].date
        while length(weeks) < 6
            week = []
            for d in 1:7
                current = last_date + Dates.Day(1)
                push!(week, (
                    date = current,
                    day_num = Dates.day(current),
                    outside = true,
                    is_today = current == Dates.today(),
                    iso_date = string(current),
                ))
                last_date = current
            end
            push!(weeks, week)
        end
    end

    # Simplified caption: just month name + year text
    month_label = _MONTH_NAMES[month] * " " * string(year)
    caption = Div(:class => "flex items-center justify-center h-7 relative",
                  :role => "status",
                  :aria_live => "polite",
                  Span(:class => "text-sm font-medium select-none text-warm-800 dark:text-warm-300",
                       month_label))

    # Weekday header
    weekday_cells = [Th(:scope => "col",
                        :class => _weekday_classes(theme),
                        :aria_label => _DAY_NAMES[i],
                        _DAY_ABBRS[i])
                     for i in 1:7]

    thead = Thead(:aria_hidden => "true",
                  Tr(:class => "flex",
                     weekday_cells...))

    # Day rows — flatten weeks into a linear cell index (0-41)
    cell_idx = 0
    week_rows = []
    for week in weeks
        day_cells = []
        for day in week
            push!(day_cells, _calendar_day_cell(cal_id, day, show_outside_days, mode, theme, cell_idx))
            cell_idx += 1
        end
        push!(week_rows, Tr(:class => "flex w-full mt-2", day_cells...))
    end

    tbody = Tbody(:class => "suite-calendar-weeks",
                  week_rows...)

    # Table
    grid_attrs = [
        :role => "grid",
        :aria_label => month_label,
        :class => "w-full border-collapse",
        Symbol("data-calendar-grid") => cal_id,
        Symbol("data-calendar-grid-month") => string(month),
        Symbol("data-calendar-grid-year") => string(year),
    ]
    if mode in ("multiple", "range")
        push!(grid_attrs, :aria_multiselectable => "true")
    end

    Div(:class => "flex flex-col gap-4 w-full",
        caption,
        Therapy.Table(grid_attrs..., thead, tbody))
end

function _weekday_classes(theme::Symbol=:default)
    classes = "text-warm-600 dark:text-warm-500 rounded-md flex-1 font-normal text-xs select-none w-9 text-center"
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    classes
end

"""
Build a single day cell as a flat <td> with data-index for Wasm interactivity.
"""
function _calendar_day_cell(cal_id, day, show_outside_days, mode, theme, index::Int)
    # Cell classes — flat td (no inner button for Wasm compatibility)
    cell_parts = [
        "relative flex items-center justify-center cursor-pointer w-9 h-9 rounded-md",
        "text-sm font-normal p-0 select-none",
        "hover:bg-warm-100 dark:hover:bg-warm-900",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600",
        "transition-colors",
        "data-[state=open]:bg-accent-100 data-[state=open]:text-accent-900",
        "dark:data-[state=open]:bg-accent-900 dark:data-[state=open]:text-accent-100",
    ]

    data_attrs = Pair{Symbol,String}[]
    push!(data_attrs, Symbol("data-index") => string(index))

    if day.outside
        push!(cell_parts, "text-warm-400 dark:text-warm-600 opacity-50")
        push!(data_attrs, Symbol("data-outside") => "true")
    end
    if !day.outside
        push!(cell_parts, "text-warm-800 dark:text-warm-300")
    end

    if day.is_today
        push!(cell_parts, "bg-warm-100 dark:bg-warm-900")
        push!(data_attrs, Symbol("data-today") => "true")
    end

    cell_classes = cn(cell_parts...)
    theme !== :default && (cell_classes = apply_theme(cell_classes, get_theme(theme)))

    # Outside days hidden initially (Wasm will show/hide on month nav)
    style = day.outside ? "display:none" : ""

    Td(:class => cell_classes,
       :role => "gridcell",
       :tabindex => "-1",
       :style => style,
       data_attrs...,
       string(day.day_num))
end

#   DatePicker(; mode, month, year, selected, placeholder,
#                    show_outside_days, class, theme, kwargs...) -> IslandVNode
#
# A date picker combining a trigger button with a Calendar in a Popover.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# Architecture: Split islands (Thaw-style)
#   - DatePicker (parent island): creates open signal, provides context, uses ShowDescendants
#   - Trigger uses inline Wasm for open/close behavior (store_active_element, push_escape_handler)
@island function DatePicker(; mode::String="single",
                          month::Int=Dates.month(Dates.today()),
                          year::Int=Dates.year(Dates.today()),
                          selected::String="",
                          placeholder::String="Pick a date",
                          disabled_dates::String="",
                          show_outside_days::Bool=true,
                          number_of_months::Int=1,
                          class::String="",
                          theme::Symbol=:default,
                          kwargs...)
    # Signal for open state (Int32: 0=closed, 1=open)
    is_open, set_open = create_signal(Int32(0))

    id = "suite-datepicker-" * string(rand(UInt32), base=16)

    # Trigger button classes (outline button style)
    trigger_classes = cn(
        "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium cursor-pointer",
        "border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-950",
        "hover:bg-warm-100 dark:hover:bg-warm-900 text-warm-800 dark:text-warm-300",
        "h-10 px-4 py-2 w-[280px] text-left",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600",
        "transition-colors",
        class
    )
    theme !== :default && (trigger_classes = apply_theme(trigger_classes, get_theme(theme)))

    # Display text: show selected or placeholder
    display_text = isempty(selected) ? placeholder : _format_display_date(selected, mode)
    text_class = isempty(selected) ? "text-warm-400 dark:text-warm-600" : ""

    # Popover content classes
    content_classes = cn(
        "bg-warm-50 dark:bg-warm-900 text-warm-800 dark:text-warm-300",
        "data-[state=open]:animate-in data-[state=closed]:animate-out",
        "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
        "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
        "data-[side=bottom]:slide-in-from-top-2",
        "data-[side=top]:slide-in-from-bottom-2",
        "z-50 rounded-md border border-warm-200 dark:border-warm-700",
        "p-0 shadow-md outline-hidden w-auto"
    )
    theme !== :default && (content_classes = apply_theme(content_classes, get_theme(theme)))

    Div(Symbol("data-show") => ShowDescendants(is_open),  # show/hide + data-state binding (inline Wasm)
        Symbol("data-datepicker") => id,
        Symbol("data-datepicker-mode") => mode,
        Symbol("data-datepicker-selected") => selected,
        :style => "display:contents",
        kwargs...,
        # Trigger wrapper with inline Wasm click handler
        Span(Symbol("data-datepicker-trigger-wrapper") => "",
            :style => "display:contents",
            :on_click => () -> begin
                if is_open() == Int32(0)
                    # Opening: inline Wasm behavior
                    store_active_element()
                    set_open(Int32(1))
                    push_escape_handler(Int32(0))
                else
                    # Closing: inline Wasm behavior
                    set_open(Int32(0))
                    pop_escape_handler()
                    restore_active_element()
                end
            end,
            # Trigger button
            Therapy.Button(:type => "button",
                   :class => trigger_classes,
                   Symbol("data-datepicker-trigger") => id,
                   :aria_haspopup => "dialog",
                   :aria_expanded => BindBool(is_open, "false", "true"),
                   Span(:class => "flex-1 $text_class",
                        Symbol("data-datepicker-value") => id,
                        display_text),
                   Span(:class => "text-warm-400 dark:text-warm-600 shrink-0",
                        Therapy.RawHtml(_CALENDAR_ICON_SVG)))),
        # Popover content (hidden by default)
        Div(Symbol("data-datepicker-content") => id,
            Symbol("data-datepicker-side") => "bottom",
            Symbol("data-datepicker-align") => "start",
            Symbol("data-state") => "closed",
            :role => "dialog",
            :aria_modal => "true",
            :style => "display:none",
            :class => content_classes,
            # Calendar inside (nested @island)
            Calendar(mode=mode, month=month, year=year, selected=selected,
                         disabled_dates=disabled_dates, show_outside_days=show_outside_days,
                         number_of_months=number_of_months, theme=theme)),
    )
end

"""Format selected date(s) for display in the trigger button."""
function _format_display_date(selected::String, mode::String)
    dates = strip.(split(selected, ","))
    filter!(!isempty, dates)
    isempty(dates) && return ""

    if mode == "range" && length(dates) >= 2
        try
            d1 = Date(dates[1])
            d2 = Date(dates[2])
            return Dates.format(d1, "U d, yyyy") * " - " * Dates.format(d2, "U d, yyyy")
        catch
            return join(dates, " - ")
        end
    elseif mode == "multiple"
        return string(length(dates)) * " date" * (length(dates) == 1 ? "" : "s") * " selected"
    else
        try
            d = Date(dates[1])
            return Dates.format(d, "E, U d, yyyy")
        catch
            return dates[1]
        end
    end
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Calendar,
        "Calendar.jl",
        :island,
        "Date calendar grid with selection, navigation, and keyboard interaction",
        Symbol[],
        Symbol[],
        [:Calendar, :DatePicker],
    ))
end
