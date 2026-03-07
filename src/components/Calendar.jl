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
#   - Month grid with day selection via compiled match_descendants
#   - Month/year navigation via prev/next buttons (event delegation + data-role)
#   - Grid update via compiled_update_text / compiled_show_element / compiled_hide_element
#   - Today highlighting on initial render
#   - DatePicker: split island (parent + trigger) with ShowDescendants
#
# Architecture:
#   - Single @island with 4 signals + 1 click handler (event delegation)
#   - 42 day cells with data-index (0-41) → match_descendants for selected state
#   - 12 month name spans with data-index (100-111) → show/hide for month display
#   - 1 year span with data-index (200) → update_text for year display
#   - Nav buttons with data-role (1=prev, 2=next) → event delegation
#   - Date math (days_in_month, day_of_week) inlined as pure Int32 arithmetic
#
# Reference: Thaw Calendar — github.com/thaw-ui/thaw
# Reference: WAI-ARIA Grid — https://www.w3.org/WAI/ARIA/apg/patterns/grid/

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

using Dates

# --- Component Implementation ---

export Calendar, DatePicker

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

# SSR helper: builds the complete Calendar VNode tree.
# Extracted from the island body so the AST transform doesn't try to compile
# for-loops, string operations, or Dates calls.
function _calendar_render(; mode::String="single",
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
    id = "suite-calendar-" * string(rand(UInt32), base=16)

    root_classes = cn(
        "p-3",
        class
    )
    theme !== :default && (root_classes = apply_theme(root_classes, get_theme(theme)))

    # Build month panels
    month_panels = []
    for i in 0:(number_of_months - 1)
        display_month = month + i
        display_year = year
        while display_month > 12
            display_month -= 12
            display_year += 1
        end
        push!(month_panels, _calendar_month_panel(id, display_year, display_month,
              show_outside_days, fixed_weeks, mode, i, number_of_months, theme))
    end

    # Navigation buttons with data-role for event delegation
    nav = Nav(:class => "flex items-center justify-between absolute top-3 inset-x-3 z-10",
              :aria_label => "Calendar navigation",
              Therapy.Button(:type => "button",
                     :class => cn(_nav_button_classes(theme)),
                     Symbol("data-role") => "1",
                     :aria_label => "Go to previous month",
                     Therapy.RawHtml(_CALENDAR_CHEVRON_LEFT)),
              Therapy.Button(:type => "button",
                     :class => cn(_nav_button_classes(theme)),
                     Symbol("data-role") => "2",
                     :aria_label => "Go to next month",
                     Therapy.RawHtml(_CALENDAR_CHEVRON_RIGHT)),
    )

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
        nav,
        Div(:class => cn("flex gap-4", number_of_months > 1 ? "flex-row" : "flex-col"),
            month_panels...),
    )
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
    # Props: _m=month (index 0), _y=year (index 1) — alphabetical order
    current_month, set_month = create_signal(compiled_get_prop_i32(Int32(0)))
    current_year, set_year = create_signal(compiled_get_prop_i32(Int32(1)))
    selected_idx, set_selected = create_signal(Int32(-1))
    base_el_id, set_base = create_signal(compiled_get_elements_count())

    # Register match descendants for day selection (signal 2 = global 3, mode 0 = closed/open)
    compiled_register_match_descendants(Int32(3), Int32(0))

    # SSR content — complex rendering delegated to external helper
    content = _calendar_render(; mode=mode, month=month, year=year, selected=selected,
                      disabled_dates=disabled_dates, show_outside_days=show_outside_days,
                      fixed_weeks=fixed_weeks, number_of_months=number_of_months,
                      class=class, theme=theme, kwargs...)

    # Root Div with event delegation click handler
    # The AST transform sees this Div and generates cursor walk for it.
    # `content` is treated as an opaque child (Symbol), not recursed into.
    Div(:style => "display:contents",
        :on_click => () -> begin
            role = compiled_get_event_closest_role()
            # ─── Nav: prev month (role=1) ───
            if role == Int32(1)
                m = current_month()
                y = current_year()
                if m == Int32(1)
                    set_month(Int32(12))
                    set_year(y - Int32(1))
                end
                if m != Int32(1)
                    set_month(m - Int32(1))
                end
                # Update grid after month change
                m2 = current_month()
                y2 = current_year()
                base = base_el_id()
                # ── days_in_month(m2, y2) ──
                dim = Int32(31)
                if m2 == Int32(2)
                    # Leap year check: (y%4==0 && y%100!=0) || y%400==0
                    r4 = y2 - (y2 ÷ Int32(4)) * Int32(4)
                    r100 = y2 - (y2 ÷ Int32(100)) * Int32(100)
                    r400 = y2 - (y2 ÷ Int32(400)) * Int32(400)
                    dim = Int32(28)
                    if r4 == Int32(0)
                        if r100 != Int32(0)
                            dim = Int32(29)
                        end
                        if r100 == Int32(0)
                            if r400 == Int32(0)
                                dim = Int32(29)
                            end
                        end
                    end
                end
                if m2 == Int32(4)
                    dim = Int32(30)
                end
                if m2 == Int32(6)
                    dim = Int32(30)
                end
                if m2 == Int32(9)
                    dim = Int32(30)
                end
                if m2 == Int32(11)
                    dim = Int32(30)
                end
                # ── day_of_week(y2, m2, 1): Tomohiko Sakamoto ──
                # t[] = {0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4}
                # For m < 3, use y-1
                yy = y2
                if m2 < Int32(3)
                    yy = y2 - Int32(1)
                end
                # t[m2] via if-chain
                t_val = Int32(0)
                if m2 == Int32(2)
                    t_val = Int32(3)
                end
                if m2 == Int32(3)
                    t_val = Int32(2)
                end
                if m2 == Int32(4)
                    t_val = Int32(5)
                end
                if m2 == Int32(5)
                    t_val = Int32(0)
                end
                if m2 == Int32(6)
                    t_val = Int32(3)
                end
                if m2 == Int32(7)
                    t_val = Int32(5)
                end
                if m2 == Int32(8)
                    t_val = Int32(1)
                end
                if m2 == Int32(9)
                    t_val = Int32(4)
                end
                if m2 == Int32(10)
                    t_val = Int32(6)
                end
                if m2 == Int32(11)
                    t_val = Int32(2)
                end
                if m2 == Int32(12)
                    t_val = Int32(4)
                end
                # dow = (y + y/4 - y/100 + y/400 + t[m] + 1) % 7
                # Result: 0=Sun, 1=Mon, ..., 6=Sat
                # Convert to 0=Mon, ..., 6=Sun: dow_mon = (dow + 6) % 7
                raw_dow = (yy + yy ÷ Int32(4) - yy ÷ Int32(100) + yy ÷ Int32(400) + t_val + Int32(1))
                dow_sun = raw_dow - (raw_dow ÷ Int32(7)) * Int32(7)
                dow = (dow_sun + Int32(6)) - ((dow_sun + Int32(6)) ÷ Int32(7)) * Int32(7)
                # ── prev month's days_in_month ──
                pm = m2 - Int32(1)
                py = y2
                if m2 == Int32(1)
                    pm = Int32(12)
                    py = y2 - Int32(1)
                end
                prev_dim = Int32(31)
                if pm == Int32(2)
                    r4p = py - (py ÷ Int32(4)) * Int32(4)
                    r100p = py - (py ÷ Int32(100)) * Int32(100)
                    r400p = py - (py ÷ Int32(400)) * Int32(400)
                    prev_dim = Int32(28)
                    if r4p == Int32(0)
                        if r100p != Int32(0)
                            prev_dim = Int32(29)
                        end
                        if r100p == Int32(0)
                            if r400p == Int32(0)
                                prev_dim = Int32(29)
                            end
                        end
                    end
                end
                if pm == Int32(4)
                    prev_dim = Int32(30)
                end
                if pm == Int32(6)
                    prev_dim = Int32(30)
                end
                if pm == Int32(9)
                    prev_dim = Int32(30)
                end
                if pm == Int32(11)
                    prev_dim = Int32(30)
                end
                # ── Update 42 cells ──
                cell_base = base + Int32(13)
                i = Int32(0)
                while i < Int32(42)
                    if i < dow
                        # Previous month day
                        compiled_hide_element(cell_base + i)
                    end
                    if i >= dow
                        if i < dow + dim
                            # Current month day
                            day = i - dow + Int32(1)
                            compiled_update_text(cell_base + i, Float64(day))
                            compiled_show_element(cell_base + i)
                        end
                    end
                    if i >= dow + dim
                        # Next month day
                        compiled_hide_element(cell_base + i)
                    end
                    i = i + Int32(1)
                end
                # ── Update month name spans ──
                # Hide old month, show new month
                old_m = m  # m was the OLD month before set_month
                month_base = base
                compiled_hide_element(month_base + old_m - Int32(1))
                compiled_show_element(month_base + m2 - Int32(1))
                # ── Update year ──
                year_el = base + Int32(12)
                compiled_update_text(year_el, Float64(y2))
                # Reset selection
                set_selected(Int32(-1))
            end
            # ─── Nav: next month (role=2) ───
            if role == Int32(2)
                m = current_month()
                y = current_year()
                if m == Int32(12)
                    set_month(Int32(1))
                    set_year(y + Int32(1))
                end
                if m != Int32(12)
                    set_month(m + Int32(1))
                end
                # Update grid (same logic as prev, duplicated to avoid function calls)
                m2 = current_month()
                y2 = current_year()
                base = base_el_id()
                dim = Int32(31)
                if m2 == Int32(2)
                    r4 = y2 - (y2 ÷ Int32(4)) * Int32(4)
                    r100 = y2 - (y2 ÷ Int32(100)) * Int32(100)
                    r400 = y2 - (y2 ÷ Int32(400)) * Int32(400)
                    dim = Int32(28)
                    if r4 == Int32(0)
                        if r100 != Int32(0)
                            dim = Int32(29)
                        end
                        if r100 == Int32(0)
                            if r400 == Int32(0)
                                dim = Int32(29)
                            end
                        end
                    end
                end
                if m2 == Int32(4)
                    dim = Int32(30)
                end
                if m2 == Int32(6)
                    dim = Int32(30)
                end
                if m2 == Int32(9)
                    dim = Int32(30)
                end
                if m2 == Int32(11)
                    dim = Int32(30)
                end
                yy = y2
                if m2 < Int32(3)
                    yy = y2 - Int32(1)
                end
                t_val = Int32(0)
                if m2 == Int32(2)
                    t_val = Int32(3)
                end
                if m2 == Int32(3)
                    t_val = Int32(2)
                end
                if m2 == Int32(4)
                    t_val = Int32(5)
                end
                if m2 == Int32(5)
                    t_val = Int32(0)
                end
                if m2 == Int32(6)
                    t_val = Int32(3)
                end
                if m2 == Int32(7)
                    t_val = Int32(5)
                end
                if m2 == Int32(8)
                    t_val = Int32(1)
                end
                if m2 == Int32(9)
                    t_val = Int32(4)
                end
                if m2 == Int32(10)
                    t_val = Int32(6)
                end
                if m2 == Int32(11)
                    t_val = Int32(2)
                end
                if m2 == Int32(12)
                    t_val = Int32(4)
                end
                raw_dow = (yy + yy ÷ Int32(4) - yy ÷ Int32(100) + yy ÷ Int32(400) + t_val + Int32(1))
                dow_sun = raw_dow - (raw_dow ÷ Int32(7)) * Int32(7)
                dow = (dow_sun + Int32(6)) - ((dow_sun + Int32(6)) ÷ Int32(7)) * Int32(7)
                pm = m2 - Int32(1)
                py = y2
                if m2 == Int32(1)
                    pm = Int32(12)
                    py = y2 - Int32(1)
                end
                prev_dim = Int32(31)
                if pm == Int32(2)
                    r4p = py - (py ÷ Int32(4)) * Int32(4)
                    r100p = py - (py ÷ Int32(100)) * Int32(100)
                    r400p = py - (py ÷ Int32(400)) * Int32(400)
                    prev_dim = Int32(28)
                    if r4p == Int32(0)
                        if r100p != Int32(0)
                            prev_dim = Int32(29)
                        end
                        if r100p == Int32(0)
                            if r400p == Int32(0)
                                prev_dim = Int32(29)
                            end
                        end
                    end
                end
                if pm == Int32(4)
                    prev_dim = Int32(30)
                end
                if pm == Int32(6)
                    prev_dim = Int32(30)
                end
                if pm == Int32(9)
                    prev_dim = Int32(30)
                end
                if pm == Int32(11)
                    prev_dim = Int32(30)
                end
                cell_base = base + Int32(13)
                i = Int32(0)
                while i < Int32(42)
                    if i < dow
                        compiled_hide_element(cell_base + i)
                    end
                    if i >= dow
                        if i < dow + dim
                            day = i - dow + Int32(1)
                            compiled_update_text(cell_base + i, Float64(day))
                            compiled_show_element(cell_base + i)
                        end
                    end
                    if i >= dow + dim
                        compiled_hide_element(cell_base + i)
                    end
                    i = i + Int32(1)
                end
                month_base = base
                compiled_hide_element(month_base + m - Int32(1))
                compiled_show_element(month_base + m2 - Int32(1))
                year_el = base + Int32(12)
                compiled_update_text(year_el, Float64(y2))
                set_selected(Int32(-1))
            end
            # ─── Day cell click (role=0, has data-index) ───
            if role == Int32(0)
                idx = compiled_get_event_data_index()
                # Only handle day cell clicks (data-index 0-41), not month/year spans
                if idx >= Int32(0)
                    if idx < Int32(42)
                        set_selected(idx)
                    end
                end
            end
        end,
        content)
end

function _nav_button_classes(theme::Symbol=:default)
    classes = "inline-flex items-center justify-center cursor-pointer rounded-md h-7 w-7 bg-transparent hover:bg-warm-100 dark:hover:bg-warm-900 text-warm-800 dark:text-warm-300 border border-warm-200 dark:border-warm-700 p-0 opacity-75 hover:opacity-100 transition-opacity"
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    classes
end

"""
Build a single month panel with caption + grid.
Always renders exactly 6 weeks (42 cells) for Wasm grid update compatibility.
"""
function _calendar_month_panel(cal_id, year, month, show_outside_days, fixed_weeks, mode, month_index, total_months, theme)
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

    # Caption with 12 month name spans + year span
    month_spans = [Span(:class => "text-sm font-medium select-none",
                        Symbol("data-index") => string(100 + i - 1),
                        :style => i == month ? "" : "display:none",
                        _MONTH_NAMES[i])
                   for i in 1:12]
    year_span = Span(:class => "text-sm font-medium select-none ml-1",
                     Symbol("data-index") => "200",
                     string(year))

    caption = Div(:class => "flex items-center justify-center h-7 relative",
                  :role => "status",
                  :aria_live => "polite",
                  month_spans...,
                  year_span)

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
    month_label = _MONTH_NAMES[month] * " " * string(year)
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
        Symbol("data-calendar-month-panel") => string(month_index),
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

# --- Props Transform ---
const _CALENDAR_PROPS_TRANSFORM = (props, args) -> begin
    m = get(props, :month, Dates.month(Dates.today()))
    y = get(props, :year, Dates.year(Dates.today()))
    # Alphabetical order: _m=0, _y=1
    props[:_m] = m
    props[:_y] = y
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
