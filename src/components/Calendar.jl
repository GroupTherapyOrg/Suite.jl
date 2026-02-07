# Calendar.jl — Suite.jl Calendar Component
#
# Tier: js_runtime (requires suite.js)
# Suite Dependencies: Button (for nav buttons)
# JS Modules: Calendar
#
# Usage via package: using Suite; Calendar()
# Usage via extract: include("components/Calendar.jl"); Calendar()
#
# Behavior (matches shadcn/ui Calendar / react-day-picker):
#   - Month grid with day selection
#   - Keyboard navigation (arrow keys, PageUp/Down, Home/End)
#   - Single, multiple, and range selection modes
#   - Month/year navigation via prev/next buttons
#   - Today highlighting
#   - Outside days display
#   - Disabled/hidden day support
#   - ARIA: role=grid, aria-label, roving tabindex

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

"""
    Calendar(; mode, month, year, selected, disabled_dates,
                   show_outside_days, fixed_weeks, class, theme, kwargs...) -> VNode

A date calendar grid with selection, navigation, and keyboard interaction.

# Arguments
- `mode::String="single"`: Selection mode ("single", "multiple", "range")
- `month::Int=current_month`: Displayed month (1-12)
- `year::Int=current_year`: Displayed year
- `selected::String=""`: Pre-selected date(s) as ISO string(s), comma-separated for multiple
- `disabled_dates::String=""`: Disabled dates as comma-separated ISO strings
- `show_outside_days::Bool=true`: Show days from adjacent months
- `fixed_weeks::Bool=false`: Always show 6 weeks
- `number_of_months::Int=1`: Number of months to display side by side
- `class::String=""`: Additional CSS classes
- `theme::Symbol=:default`: Theme preset

# Examples
```julia
# Single date selection
Calendar()

# Range selection with 2 months
Calendar(mode="range", number_of_months=2)

# Pre-selected date
Calendar(selected="2026-02-14")
```
"""
function Calendar(; mode::String="single",
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

    # Navigation buttons
    nav = Nav(:class => "flex items-center justify-between absolute top-3 inset-x-3 z-10",
              :aria_label => "Calendar navigation",
              Therapy.Button(:type => "button",
                     :class => cn(_nav_button_classes(theme)),
                     Symbol("data-suite-calendar-prev") => id,
                     :aria_label => "Go to previous month",
                     Therapy.RawHtml(_CALENDAR_CHEVRON_LEFT)),
              Therapy.Button(:type => "button",
                     :class => cn(_nav_button_classes(theme)),
                     Symbol("data-suite-calendar-next") => id,
                     :aria_label => "Go to next month",
                     Therapy.RawHtml(_CALENDAR_CHEVRON_RIGHT)),
    )

    Div(Symbol("data-suite-calendar") => id,
        Symbol("data-suite-calendar-mode") => mode,
        Symbol("data-suite-calendar-month") => string(month),
        Symbol("data-suite-calendar-year") => string(year),
        Symbol("data-suite-calendar-selected") => selected,
        Symbol("data-suite-calendar-disabled") => disabled_dates,
        Symbol("data-suite-calendar-show-outside") => show_outside_days ? "true" : "false",
        Symbol("data-suite-calendar-fixed-weeks") => fixed_weeks ? "true" : "false",
        Symbol("data-suite-calendar-months-count") => string(number_of_months),
        :class => root_classes,
        :style => "position:relative",
        kwargs...,
        nav,
        Div(:class => cn("flex gap-4", number_of_months > 1 ? "flex-row" : "flex-col"),
            month_panels...),
    )
end

function _nav_button_classes(theme::Symbol=:default)
    classes = "inline-flex items-center justify-center cursor-pointer rounded-md h-7 w-7 bg-transparent hover:bg-warm-100 dark:hover:bg-warm-900 text-warm-800 dark:text-warm-300 border border-warm-200 dark:border-warm-700 p-0 opacity-75 hover:opacity-100 transition-opacity"
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    classes
end

"""
Build a single month panel with caption + grid.
"""
function _calendar_month_panel(cal_id, year, month, show_outside_days, fixed_weeks, mode, month_index, total_months, theme)
    weeks = _calendar_weeks(year, month; show_outside_days=show_outside_days)

    # Pad to 6 weeks if fixed_weeks
    if fixed_weeks && length(weeks) < 6
        last_date = weeks[end][end].date
        while length(weeks) < 6
            week = []
            for d in 1:7
                current = last_date + Dates.Day(d + (length(weeks) - length(_calendar_weeks(year, month; show_outside_days=show_outside_days))) * 7)
                push!(week, (
                    date = current,
                    day_num = Dates.day(current),
                    outside = true,
                    is_today = current == Dates.today(),
                    iso_date = string(current),
                ))
            end
            push!(weeks, week)
            last_date = weeks[end][end].date
        end
    end

    month_label = _MONTH_NAMES[month] * " " * string(year)

    # Caption
    caption = Div(:class => "flex items-center justify-center h-7 relative",
                  Span(:class => "text-sm font-medium select-none",
                       :role => "status",
                       :aria_live => "polite",
                       Symbol("data-suite-calendar-caption") => cal_id,
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

    # Day rows
    week_rows = [_calendar_week_row(cal_id, week, show_outside_days, mode, theme) for week in weeks]

    tbody = Tbody(:class => "suite-calendar-weeks",
                  week_rows...)

    # Table
    grid_attrs = [
        :role => "grid",
        :aria_label => month_label,
        :class => "w-full border-collapse",
        Symbol("data-suite-calendar-grid") => cal_id,
        Symbol("data-suite-calendar-grid-month") => string(month),
        Symbol("data-suite-calendar-grid-year") => string(year),
    ]
    if mode in ("multiple", "range")
        push!(grid_attrs, :aria_multiselectable => "true")
    end

    Div(:class => "flex flex-col gap-4 w-full",
        Symbol("data-suite-calendar-month-panel") => string(month_index),
        caption,
        Therapy.Table(grid_attrs..., thead, tbody))
end

function _weekday_classes(theme::Symbol=:default)
    classes = "text-warm-600 dark:text-warm-500 rounded-md flex-1 font-normal text-xs select-none w-9 text-center"
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))
    classes
end

function _calendar_week_row(cal_id, week, show_outside_days, mode, theme)
    day_cells = [_calendar_day_cell(cal_id, day, show_outside_days, mode, theme) for day in week]
    Tr(:class => "flex w-full mt-2",
       day_cells...)
end

function _calendar_day_cell(cal_id, day, show_outside_days, mode, theme)
    # Outside days: hidden or shown but muted
    if day.outside && !show_outside_days
        return Td(:class => "relative w-9 h-9 p-0 text-center",
                  :role => "gridcell")
    end

    # Build cell classes
    cell_classes_parts = [
        "relative w-9 h-9 p-0 text-center select-none group/day"
    ]

    # Day button classes
    btn_parts = [
        "relative flex items-center justify-center cursor-pointer w-9 h-9 rounded-md",
        "text-sm font-normal p-0 border-0",
        "hover:bg-warm-100 dark:hover:bg-warm-900",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600",
        "transition-colors"
    ]

    # Modifiers as data attributes
    data_attrs = Pair{Symbol,String}[]
    push!(data_attrs, Symbol("data-suite-calendar-day") => day.iso_date)

    if day.outside
        push!(btn_parts, "text-warm-400 dark:text-warm-600 opacity-50")
        push!(data_attrs, Symbol("data-outside") => "true")
    else
        push!(btn_parts, "text-warm-800 dark:text-warm-300")
    end

    if day.is_today
        push!(btn_parts, "bg-warm-100 dark:bg-warm-900")
        push!(data_attrs, Symbol("data-today") => "true")
    end

    btn_classes = cn(btn_parts...)
    theme !== :default && (btn_classes = apply_theme(btn_classes, get_theme(theme)))

    cell_classes = cn(cell_classes_parts...)

    Td(:class => cell_classes,
       :role => "gridcell",
       data_attrs...,
       Therapy.Button(:type => "button",
              :class => btn_classes,
              :tabindex => "-1",
              Symbol("data-suite-calendar-day-btn") => day.iso_date,
              :aria_label => Dates.format(day.date, "E, U d, yyyy"),
              string(day.day_num)))
end

"""
    DatePicker(; mode, month, year, selected, placeholder,
                     show_outside_days, class, theme, kwargs...) -> VNode

A date picker combining a trigger button with a Calendar in a Popover.

# Arguments
- `mode::String="single"`: Selection mode ("single", "multiple", "range")
- `month::Int=current_month`: Initial displayed month
- `year::Int=current_year`: Initial displayed year
- `selected::String=""`: Pre-selected date(s)
- `placeholder::String="Pick a date"`: Trigger button text when no date selected
- `disabled_dates::String=""`: Disabled dates as comma-separated ISO strings
- `show_outside_days::Bool=true`: Show days from adjacent months
- `number_of_months::Int=1`: Number of months to display
- `class::String=""`: Additional CSS classes for the trigger button
- `theme::Symbol=:default`: Theme preset

# Examples
```julia
# Simple date picker
DatePicker()

# Range picker with 2 months
DatePicker(mode="range", number_of_months=2, placeholder="Select dates")

# Pre-selected date
DatePicker(selected="2026-02-14")
```
"""
function DatePicker(; mode::String="single",
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
    id = "suite-datepicker-" * string(rand(UInt32), base=16)

    # Trigger button classes (outline button style)
    trigger_classes = cn(
        "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium",
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

    Div(Symbol("data-suite-datepicker") => id,
        Symbol("data-suite-datepicker-mode") => mode,
        Symbol("data-suite-datepicker-selected") => selected,
        :style => "display:contents",
        kwargs...,
        # Trigger button
        Therapy.Button(:type => "button",
               :class => trigger_classes,
               Symbol("data-suite-datepicker-trigger") => id,
               :aria_haspopup => "dialog",
               :aria_expanded => "false",
               Span(:class => "flex-1 $text_class",
                    Symbol("data-suite-datepicker-value") => id,
                    display_text),
               Span(:class => "text-warm-400 dark:text-warm-600 shrink-0",
                    Therapy.RawHtml(_CALENDAR_ICON_SVG))),
        # Popover content (hidden by default)
        Div(Symbol("data-suite-datepicker-content") => id,
            Symbol("data-suite-datepicker-side") => "bottom",
            Symbol("data-suite-datepicker-align") => "start",
            Symbol("data-state") => "closed",
            :role => "dialog",
            :aria_modal => "true",
            :style => "display:none",
            :class => content_classes,
            # Calendar inside
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
        :js_runtime,
        "Date calendar grid with selection, navigation, and keyboard interaction",
        Symbol[],
        [:Calendar],
        [:Calendar, :DatePicker],
    ))
end
