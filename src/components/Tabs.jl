# Tabs.jl — Suite.jl Tabs Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none
# JS Modules: none
#
# Usage via package: using Suite; Tabs(...)
# Usage via extract: include("components/Tabs.jl"); Tabs(...)
#
# Behavior:
#   - Signal-driven: BindBool maps per-tab active signal to data-state and aria-selected
#   - @island Tabs injects signal bindings into TabsTrigger/TabsContent children
#   - Content visibility via CSS data-[state=inactive]:hidden (no JS hidden toggling)
#   - Click on trigger selects tab (deselects all others)
#   - ARIA: role=tablist, role=tab, role=tabpanel, aria-selected
#
# Reference: Radix UI Tabs — https://www.radix-ui.com/primitives/docs/components/tabs
# Reference: WAI-ARIA Tabs — https://www.w3.org/WAI/ARIA/apg/patterns/tabs/

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export Tabs, TabsList, TabsTrigger, TabsContent

#   Tabs(children...; default_value, orientation, activation, class, kwargs...) -> IslandVNode
#
# A set of layered panels, each associated with a tab trigger.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# TabsTrigger children (inside TabsList) and TabsContent children are auto-detected
# and injected with signal bindings for data-state, aria-selected, and click handlers.
#
# Props:
#   default_value: the value of the initially selected tab
#   orientation: "horizontal" (default) or "vertical" — affects arrow key directions
#   activation: "automatic" (default) or "manual"
#
# Examples:
#   Tabs(default_value="tab1",
#       TabsList(TabsTrigger("Account", value="tab1"), TabsTrigger("Password", value="tab2")),
#       TabsContent(value="tab1", P("Account settings")),
#       TabsContent(value="tab2", P("Password settings")),
#   )
@island function Tabs(children...; default_value::String="",
                   orientation::String="horizontal", activation::String="automatic",
                   class::String="", kwargs...)
    # Collect triggers and content panels from children
    triggers = VNode[]
    contents = VNode[]

    for child in children
        if child isa VNode
            if haskey(child.props, Symbol("data-tabslist"))
                # Walk TabsList children to find triggers
                for trigger_child in child.children
                    if trigger_child isa VNode && haskey(trigger_child.props, Symbol("data-tabs-trigger"))
                        push!(triggers, trigger_child)
                    end
                end
            elseif haskey(child.props, Symbol("data-tabs-content"))
                push!(contents, child)
            end
        end
    end

    # Create per-trigger signals (Int32: 0=inactive, 1=active)
    trigger_signals = Tuple{Any, Any}[]
    for trigger in triggers
        value = string(trigger.props[Symbol("data-tabs-trigger")])
        is_active = value == default_value
        sig, set_sig = create_signal(Int32(is_active ? 1 : 0))
        push!(trigger_signals, (sig, set_sig))
    end

    # Inject BindBool and click handlers on triggers
    for (i, trigger) in enumerate(triggers)
        sig = trigger_signals[i][1]
        trigger.props[Symbol("data-state")] = BindBool(sig, "inactive", "active")
        trigger.props[:aria_selected] = BindBool(sig, "false", "true")
        trigger.props[Symbol("data-index")] = string(i - 1)  # 0-indexed for hydration
        # Set initial tabindex correctly (active=0, inactive=-1)
        value = string(trigger.props[Symbol("data-tabs-trigger")])
        is_active = value == default_value
        trigger.props[:tabindex] = is_active ? "0" : "-1"

        # Click handler (unless disabled)
        if !haskey(trigger.props, :disabled) && !haskey(trigger.props, Symbol("data-disabled"))
            let all_sigs = trigger_signals, my_idx = i
                trigger.props[:on_click] = function()
                    for (j, (_, setter)) in enumerate(all_sigs)
                        setter(j == my_idx ? Int32(1) : Int32(0))
                    end
                end
            end
        end
    end

    # Match content panels to triggers by value and inject BindBool
    for content in contents
        content_value = string(content.props[Symbol("data-tabs-content")])
        for (i, trigger) in enumerate(triggers)
            trigger_value = string(trigger.props[Symbol("data-tabs-trigger")])
            if trigger_value == content_value
                sig = trigger_signals[i][1]
                content.props[Symbol("data-state")] = BindBool(sig, "inactive", "active")
                # Remove HTML hidden attr — CSS handles visibility via data-state
                delete!(content.props, :hidden)
                # Add CSS class to hide when inactive
                current_class = get(content.props, :class, "")
                content.props[:class] = cn(current_class, "data-[state=inactive]:hidden")
                break
            end
        end
    end

    classes = cn("", class)

    Div(Symbol("data-tabs") => "",
        Symbol("data-orientation") => orientation,
        Symbol("data-activation") => activation,
        :class => classes,
        kwargs...,
        children...)
end

"""
    TabsList(children...; loop, class, kwargs...) -> VNode

Contains the tab triggers. Renders as a tablist with roving tabindex.

# Props
- `loop`: whether keyboard navigation wraps (default `true`)
"""
function TabsList(children...; loop::Bool=true, theme::Symbol=:default,
                       class::String="", kwargs...)
    base = "inline-flex h-9 items-center justify-center rounded-lg bg-warm-100 dark:bg-warm-900 p-1 text-warm-600 dark:text-warm-500"
    classes = cn(base, class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    attrs = Pair{Symbol,Any}[
        Symbol("data-tabslist") => "",
        :role => "tablist",
        :aria_orientation => "horizontal",
        :class => classes,
    ]
    if !loop
        push!(attrs, Symbol("data-no-loop") => "")
    end

    Div(attrs..., kwargs..., children...)
end

"""
    TabsTrigger(children...; value, disabled, class, kwargs...) -> VNode

A tab trigger button. When clicked/focused, activates the corresponding content panel.

# Props
- `value`: identifies which TabsContent this trigger activates (required)
- `disabled`: disable this tab
"""
function TabsTrigger(children...; value::String="", disabled::Bool=false,
                          theme::Symbol=:default, class::String="", kwargs...)
    base = "inline-flex items-center justify-center whitespace-nowrap cursor-pointer rounded-md px-3 py-1 text-sm font-medium ring-offset-warm-50 dark:ring-offset-warm-950 transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 data-[state=active]:bg-warm-50 dark:data-[state=active]:bg-warm-950 data-[state=active]:text-warm-800 dark:data-[state=active]:text-warm-300 data-[state=active]:shadow"
    classes = cn(base, class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    attrs = Pair{Symbol,Any}[
        :type => "button",
        :role => "tab",
        Symbol("data-tabs-trigger") => value,
        Symbol("data-state") => "inactive",
        :aria_selected => "false",
        :tabindex => "-1",
        :class => classes,
    ]
    if disabled
        push!(attrs, :disabled => true)
        push!(attrs, Symbol("data-disabled") => "")
    end

    Therapy.Button(attrs..., kwargs..., children...)
end

"""
    TabsContent(children...; value, class, kwargs...) -> VNode

The content panel associated with a tab trigger.

# Props
- `value`: identifies which TabsTrigger activates this panel (required)
"""
function TabsContent(children...; value::String="", theme::Symbol=:default,
                          class::String="", kwargs...)
    base = "mt-2 ring-offset-warm-50 dark:ring-offset-warm-950 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600 focus-visible:ring-offset-2"
    classes = cn(base, class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-tabs-content") => value,
        Symbol("data-state") => "inactive",
        :role => "tabpanel",
        :tabindex => "0",
        :hidden => true,
        :class => classes,
        kwargs...,
        children...)
end

# --- Hydration Support ---

const _TABS_PROPS_TRANSFORM = (props, args) -> begin
    triggers = Therapy.VNode[]
    for arg in args
        if arg isa Therapy.VNode && haskey(arg.props, Symbol("data-tabslist"))
            for child in arg.children
                if child isa Therapy.VNode && haskey(child.props, Symbol("data-tabs-trigger"))
                    push!(triggers, child)
                end
            end
        end
    end
    n = length(triggers)
    dv = string(get(props, :default_value, ""))
    active_idx = 0
    for (i, t) in enumerate(triggers)
        if string(t.props[Symbol("data-tabs-trigger")]) == dv
            active_idx = i - 1  # 0-indexed
            break
        end
    end
    props[:_a] = active_idx
    props[:_n] = n
end

const _TABS_HYDRATION_BODY = quote
    active, set_active = create_signal(compiled_get_prop_i32(Int32(0)))
    n = compiled_get_prop_i32(Int32(1))
    Div(
        Div(
            begin
                i = Int32(0)
                while i < n
                    Button(
                        Symbol("data-state") => MatchBindBool(active, i, "inactive", "active"),
                        :aria_selected => MatchBindBool(active, i, "false", "true"),
                        :on_click => (e) -> set_active(compiled_get_event_data_index()),
                    )
                    i = i + Int32(1)
                end
            end
        ),
        begin
            j = Int32(0)
            while j < n
                Div(
                    Symbol("data-state") => MatchBindBool(active, j, "inactive", "active"),
                )
                j = j + Int32(1)
            end
        end
    )
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Tabs,
        "Tabs.jl",
        :island,
        "Tabbed interface with keyboard navigation and roving tabindex",
        Symbol[],
        Symbol[],
        [:Tabs, :TabsList, :TabsTrigger, :TabsContent],
    ))
end
