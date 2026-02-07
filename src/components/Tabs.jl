# SuiteTabs.jl — Suite.jl Tabs Component
#
# Tier: js_runtime (requires suite.js for tab selection + roving tabindex)
# Suite Dependencies: none
# JS Modules: Tabs
#
# Usage via package: using Suite; SuiteTabs(...)
# Usage via extract: include("components/Tabs.jl"); SuiteTabs(...)
#
# Behavior:
#   - TabsList with roving tabindex (arrow keys move focus)
#   - Automatic mode: focus selects tab. Manual mode: Enter/Space selects.
#   - ARIA: role=tablist, role=tab, role=tabpanel
#   - aria-selected, aria-controls, aria-labelledby, tabindex
#
# Reference: Radix UI Tabs — https://www.radix-ui.com/primitives/docs/components/tabs
# Reference: WAI-ARIA Tabs — https://www.w3.org/WAI/ARIA/apg/patterns/tabs/

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export SuiteTabs, SuiteTabsList, SuiteTabsTrigger, SuiteTabsContent

"""
    SuiteTabs(children...; default_value, orientation, activation, class, kwargs...) -> VNode

A set of layered panels, each associated with a tab trigger.

Requires `suite_script()` in your layout for JS behavior.

# Props
- `default_value`: the value of the initially selected tab (required)
- `orientation`: `"horizontal"` (default) or `"vertical"` — affects arrow key directions
- `activation`: `"automatic"` (default, focus selects) or `"manual"` (Enter/Space selects)

# Examples
```julia
SuiteTabs(default_value="tab1",
    SuiteTabsList(
        SuiteTabsTrigger("Account", value="tab1"),
        SuiteTabsTrigger("Password", value="tab2"),
    ),
    SuiteTabsContent(value="tab1",
        P("Account settings content"),
    ),
    SuiteTabsContent(value="tab2",
        P("Password settings content"),
    ),
)
```
"""
function SuiteTabs(children...; default_value::String="",
                   orientation::String="horizontal", activation::String="automatic",
                   class::String="", kwargs...)
    id = "suite-tabs-" * string(rand(UInt32), base=16)
    classes = cn("", class)

    Div(Symbol("data-suite-tabs") => id,
        Symbol("data-orientation") => orientation,
        Symbol("data-activation") => activation,
        Symbol("data-default-value") => default_value,
        :class => classes,
        kwargs...,
        children...)
end

"""
    SuiteTabsList(children...; loop, class, kwargs...) -> VNode

Contains the tab triggers. Renders as a tablist with roving tabindex.

# Props
- `loop`: whether keyboard navigation wraps (default `true`)
"""
function SuiteTabsList(children...; loop::Bool=true, theme::Symbol=:default,
                       class::String="", kwargs...)
    base = "inline-flex h-9 items-center justify-center rounded-lg bg-warm-100 dark:bg-warm-900 p-1 text-warm-600 dark:text-warm-500"
    classes = cn(base, class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    attrs = Pair{Symbol,Any}[
        Symbol("data-suite-tabslist") => "",
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
    SuiteTabsTrigger(children...; value, disabled, class, kwargs...) -> VNode

A tab trigger button. When clicked/focused, activates the corresponding content panel.

# Props
- `value`: identifies which TabsContent this trigger activates (required)
- `disabled`: disable this tab
"""
function SuiteTabsTrigger(children...; value::String="", disabled::Bool=false,
                          theme::Symbol=:default, class::String="", kwargs...)
    base = "inline-flex items-center justify-center whitespace-nowrap rounded-md px-3 py-1 text-sm font-medium ring-offset-warm-50 dark:ring-offset-warm-950 transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 data-[state=active]:bg-warm-50 dark:data-[state=active]:bg-warm-950 data-[state=active]:text-warm-800 dark:data-[state=active]:text-warm-300 data-[state=active]:shadow"
    classes = cn(base, class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    attrs = Pair{Symbol,Any}[
        :type => "button",
        :role => "tab",
        Symbol("data-suite-tabs-trigger") => value,
        Symbol("data-state") => "inactive",
        :aria_selected => "false",
        :tabindex => "-1",
        :class => classes,
    ]
    if disabled
        push!(attrs, :disabled => true)
        push!(attrs, Symbol("data-disabled") => "")
    end

    Button(attrs..., kwargs..., children...)
end

"""
    SuiteTabsContent(children...; value, class, kwargs...) -> VNode

The content panel associated with a tab trigger.

# Props
- `value`: identifies which TabsTrigger activates this panel (required)
"""
function SuiteTabsContent(children...; value::String="", theme::Symbol=:default,
                          class::String="", kwargs...)
    base = "mt-2 ring-offset-warm-50 dark:ring-offset-warm-950 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-600 focus-visible:ring-offset-2"
    classes = cn(base, class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-suite-tabs-content") => value,
        Symbol("data-state") => "inactive",
        :role => "tabpanel",
        :tabindex => "0",
        :hidden => true,
        :class => classes,
        kwargs...,
        children...)
end

# --- Initial state script ---

"""
    suite_tabs_init_script() -> VNode

Inline script that applies initial tab selection based on data-default-value.
The suite.js Tabs.init() handles ongoing interaction.
"""
function suite_tabs_init_script()
    Therapy.Script("""
    (function(){
        document.querySelectorAll('[data-suite-tabs][data-default-value]').forEach(function(root) {
            if (root._suiteTabsDefaultApplied) return;
            root._suiteTabsDefaultApplied = true;
            var val = root.getAttribute('data-default-value');
            if (!val) return;
            var list = root.querySelector('[data-suite-tabslist]');
            if (!list) return;
            // Activate matching trigger
            list.querySelectorAll('[data-suite-tabs-trigger]').forEach(function(t) {
                var isActive = t.getAttribute('data-suite-tabs-trigger') === val;
                t.setAttribute('data-state', isActive ? 'active' : 'inactive');
                t.setAttribute('aria-selected', String(isActive));
                t.setAttribute('tabindex', isActive ? '0' : '-1');
            });
            // Show matching content
            root.querySelectorAll('[data-suite-tabs-content]').forEach(function(p) {
                var isActive = p.getAttribute('data-suite-tabs-content') === val;
                p.setAttribute('data-state', isActive ? 'active' : 'inactive');
                p.hidden = !isActive;
            });
        });
    })();
    """)
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Tabs,
        "Tabs.jl",
        :js_runtime,
        "Tabbed interface with keyboard navigation and roving tabindex",
        Symbol[],
        [:Tabs],
        [:SuiteTabs, :SuiteTabsList, :SuiteTabsTrigger, :SuiteTabsContent],
    ))
end
