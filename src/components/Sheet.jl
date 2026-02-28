# Sheet.jl — Suite.jl Sheet Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none (leaf component)
# JS Modules: none
#
# Usage via package: using Suite; Sheet(...)
# Usage via extract: include("components/Sheet.jl"); Sheet(...)
#
# Behavior (Thaw-style inline Wasm):
#   - Modal by default: focus trapped, scroll locked, outside pointer disabled
#   - Escape key dismisses (via push_escape_handler Wasm import)
#   - Click outside overlay dismisses (via close button delegation)
#   - Slides from edge (top/right/bottom/left)
#   - Same behavior as Dialog, different CSS (slide vs zoom)
#   - Scroll lock via lock_scroll/unlock_scroll Wasm imports
#   - Signal-driven: BindBool maps open signal to data-state and aria-expanded
#   - Modal binding handles show/hide + data-state on overlay/content children

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Sheet, SheetTrigger, SheetContent,
       SheetHeader, SheetFooter, SheetTitle,
       SheetDescription, SheetClose

# Side-specific CSS classes for slide animations
const SHEET_SIDE_CLASSES = Dict{String, String}(
    "top" => "inset-x-0 top-0 border-b border-warm-200 dark:border-warm-700 data-[state=closed]:slide-out-to-top data-[state=open]:slide-in-from-top",
    "bottom" => "inset-x-0 bottom-0 border-t border-warm-200 dark:border-warm-700 data-[state=closed]:slide-out-to-bottom data-[state=open]:slide-in-from-bottom",
    "left" => "inset-y-0 left-0 h-full w-3/4 border-r border-warm-200 dark:border-warm-700 data-[state=closed]:slide-out-to-left data-[state=open]:slide-in-from-left sm:max-w-sm",
    "right" => "inset-y-0 right-0 h-full w-3/4 border-l border-warm-200 dark:border-warm-700 data-[state=closed]:slide-out-to-right data-[state=open]:slide-in-from-right sm:max-w-sm",
)

#   Sheet(children...; class, kwargs...) -> IslandVNode
#
# A slide-in panel from the edge of the screen. Modal with focus trap,
# scroll lock, and dismiss on Escape/click-outside.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# Parent island: creates signal, provides context for child islands.
# Modal binding handles show/hide + data-state on overlay/content children.
# Behavioral logic (scroll lock, focus, Escape) is inline Wasm in SheetTrigger.
#
# Examples:
#   Sheet(SheetTrigger(Button("Open")), SheetContent(side="right", SheetHeader(SheetTitle("Title"))))
@island function Sheet(children...; class::String="", kwargs...)
    # Signal for open state (Int32: 0=closed, 1=open)
    is_open, set_open = create_signal(Int32(0))

    # Provide context for child islands (single key with getter+setter tuple)
    provide_context(:sheet, (is_open, set_open))

    Div(Symbol("data-show") => ShowDescendants(is_open),  # show/hide + data-state binding (inline Wasm)
        :class => cn("", class),
        kwargs...,
        children...)
end

#   SheetTrigger(children...; class, kwargs...) -> IslandVNode
#
# The button that opens the sheet.
# Child island: owns signal + BindBool + inline Wasm behavior (compilable body).
#
# Inline Wasm behavior (Thaw-style):
#   - Open: store focus, set signal, lock scroll, register Escape handler
#   - Close: set signal, unlock scroll, pop Escape handler, restore focus
@island function SheetTrigger(children...; class::String="", kwargs...)
    is_open, set_open = use_context_signal(:sheet, Int32(0))

    Span(Symbol("data-sheet-trigger-wrapper") => "",
         :style => "display:contents",
         :class => cn("cursor-pointer", class),
         Symbol("data-state") => BindBool(is_open, "closed", "open"),
         :aria_haspopup => "dialog",
         :aria_expanded => BindBool(is_open, "false", "true"),
         :on_click => () -> begin
             if is_open() == Int32(0)
                 store_active_element()
                 set_open(Int32(1))
                 lock_scroll()
                 push_escape_handler(Int32(0))
             else
                 set_open(Int32(0))
                 unlock_scroll()
                 pop_escape_handler()
                 restore_active_element()
             end
         end,
         kwargs...,
         children...)
end

"""
    SheetContent(children...; side, class, kwargs...) -> VNode

The sheet content panel. Slides from the specified edge.

# Arguments
- `side::String="right"`: Edge to slide from ("top", "right", "bottom", "left")
"""
function SheetContent(children...; side::String="right", theme::Symbol=:default, class::String="", kwargs...)
    side_classes = get(SHEET_SIDE_CLASSES, side, SHEET_SIDE_CLASSES["right"])

    classes = cn(
        "glass-panel",
        "bg-warm-50 dark:bg-warm-950 text-warm-800 dark:text-warm-300",
        "fixed z-50 gap-4 p-6 shadow-lg outline-none",
        "transition ease-in-out",
        "data-[state=closed]:duration-300 data-[state=open]:duration-500",
        "data-[state=open]:animate-in data-[state=closed]:animate-out",
        side_classes,
        class
    )
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(
        # Overlay backdrop
        Div(Symbol("data-sheet-overlay") => "",
            Symbol("data-state") => "closed",
            :class => "fixed inset-0 z-50 bg-warm-950/80 data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
            :style => "display:none",
        ),
        # Content
        Div(Symbol("data-sheet-content") => "",
            Symbol("data-state") => "closed",
            :role => "dialog",
            :aria_modal => "true",
            :tabindex => "-1",
            :class => classes,
            kwargs...,
            children...,
            # Default close button (X in top-right)
            Therapy.Button(:type => "button",
                   Symbol("data-sheet-close") => "",
                   :class => "absolute right-4 top-4 rounded-sm opacity-70 cursor-pointer ring-offset-warm-50 dark:ring-offset-warm-950 transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-accent-600 focus:ring-offset-2 disabled:pointer-events-none",
                   :aria_label => "Close",
                   Svg(:class => "h-4 w-4", :fill => "none", :viewBox => "0 0 24 24",
                       :stroke => "currentColor", :stroke_width => "2",
                       Path(:stroke_linecap => "round", :stroke_linejoin => "round",
                            :d => "M18 6L6 18M6 6l12 12")),
            ),
        ),
    )
end

"""
    SheetHeader(children...; class, kwargs...) -> VNode

Header section of the sheet.
"""
function SheetHeader(children...; class::String="", kwargs...)
    Div(:class => cn("flex flex-col gap-2 text-center sm:text-left", class),
        kwargs...,
        children...)
end

"""
    SheetFooter(children...; class, kwargs...) -> VNode

Footer section of the sheet.
"""
function SheetFooter(children...; class::String="", kwargs...)
    Div(:class => cn("flex flex-col-reverse gap-2 sm:flex-row sm:justify-end", class),
        kwargs...,
        children...)
end

"""
    SheetTitle(children...; class, kwargs...) -> VNode

Title of the sheet. Renders as h2.
"""
function SheetTitle(children...; class::String="", kwargs...)
    H2(:class => cn("text-lg leading-none font-semibold text-warm-800 dark:text-warm-300", class),
       kwargs...,
       children...)
end

"""
    SheetDescription(children...; class, kwargs...) -> VNode

Description text for the sheet.
"""
function SheetDescription(children...; class::String="", kwargs...)
    P(:class => cn("text-warm-600 dark:text-warm-500 text-sm", class),
      kwargs...,
      children...)
end

"""
    SheetClose(children...; class, kwargs...) -> VNode

A button that closes the sheet when clicked.
"""
function SheetClose(children...; class::String="", kwargs...)
    Span(Symbol("data-sheet-close") => "",
         :class => cn(class),
         :style => "display:contents",
         kwargs...,
         children...)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Sheet,
        "Sheet.jl",
        :island,
        "Slide-in panel from screen edge with focus trap and dismiss layer",
        Symbol[],
        Symbol[],
        [:Sheet, :SheetTrigger, :SheetContent,
         :SheetHeader, :SheetFooter, :SheetTitle,
         :SheetDescription, :SheetClose],
    ))
end
