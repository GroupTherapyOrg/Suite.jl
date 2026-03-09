# ComponentsSidebar.jl - Sidebar navigation for Suite.jl docs
#
# Three standalone sidebars: Getting Started, Components, Widgets.
# Each section has its own sidebar shown only on its routes.

# --- Getting Started ---
const GETTING_STARTED_ITEMS = [
    (slug = "index",            title = "Introduction",     implemented = true),
    (slug = "installation",     title = "Installation",     implemented = true),
    (slug = "theming",          title = "Theming",          implemented = true),
]

# --- Widgets ---
const WIDGET_ITEMS = [
    (slug = "index",            title = "Overview",          implemented = true),
    (slug = "bind",             title = "The @bind Pattern", implemented = true),
    (slug = "slider",           title = "Slider",            implemented = true),
]

# --- Components (alphabetical) ---
const COMPONENT_ITEMS = [
    (slug = "accordion",        title = "Accordion",        implemented = true),
    (slug = "alert",            title = "Alert",            implemented = true),
    (slug = "alert-dialog",     title = "Alert Dialog",     implemented = true),
    (slug = "aspect-ratio",     title = "Aspect Ratio",     implemented = true),
    (slug = "avatar",           title = "Avatar",           implemented = true),
    (slug = "badge",            title = "Badge",            implemented = true),
    (slug = "breadcrumb",       title = "Breadcrumb",       implemented = true),
    (slug = "button",           title = "Button",           implemented = true),
    (slug = "calendar",         title = "Calendar",         implemented = true),
    (slug = "card",             title = "Card",             implemented = true),
    (slug = "carousel",         title = "Carousel",         implemented = true),
    (slug = "checkbox",         title = "Checkbox",         implemented = false),
    (slug = "code-block",       title = "Code Block",       implemented = true),
    (slug = "collapsible",      title = "Collapsible",      implemented = true),
    (slug = "command",          title = "Command",          implemented = true),
    (slug = "context-menu",     title = "Context Menu",     implemented = true),
    (slug = "data-table",       title = "Data Table",       implemented = true),
    (slug = "date-picker",      title = "Date Picker",      implemented = true),
    (slug = "dialog",           title = "Dialog",           implemented = true),
    (slug = "drawer",           title = "Drawer",           implemented = true),
    (slug = "dropdown-menu",    title = "Dropdown Menu",    implemented = true),
    (slug = "empty",            title = "Empty",            implemented = true),
    (slug = "form",             title = "Form",             implemented = true),
    (slug = "hover-card",       title = "Hover Card",       implemented = true),
    (slug = "input",            title = "Input",            implemented = true),
    (slug = "kbd",              title = "Kbd",              implemented = true),
    (slug = "label",            title = "Label",            implemented = true),
    (slug = "menubar",          title = "Menubar",          implemented = true),
    (slug = "navigation-menu",  title = "Navigation Menu",  implemented = true),
    (slug = "pagination",       title = "Pagination",       implemented = true),
    (slug = "popover",          title = "Popover",          implemented = true),
    (slug = "progress",         title = "Progress",         implemented = true),
    (slug = "radio-group",      title = "Radio Group",      implemented = false),
    (slug = "resizable",        title = "Resizable",        implemented = true),
    (slug = "scroll-area",      title = "Scroll Area",      implemented = true),
    (slug = "select",           title = "Select",           implemented = true),
    (slug = "separator",        title = "Separator",        implemented = true),
    (slug = "sheet",            title = "Sheet",            implemented = true),
    (slug = "skeleton",         title = "Skeleton",         implemented = true),
    (slug = "slider",           title = "Slider",           implemented = true),
    (slug = "spinner",          title = "Spinner",          implemented = true),
    (slug = "status-bar",       title = "Status Bar",       implemented = true),
    (slug = "switch",           title = "Switch",           implemented = true),
    (slug = "table",            title = "Table",            implemented = true),
    (slug = "tabs",             title = "Tabs",             implemented = true),
    (slug = "textarea",         title = "Textarea",         implemented = true),
    (slug = "toast",            title = "Toast",            implemented = true),
    (slug = "toggle",           title = "Toggle",           implemented = true),
    (slug = "toggle-group",     title = "Toggle Group",     implemented = true),
    (slug = "toolbar",          title = "Toolbar",          implemented = true),
    (slug = "tooltip",          title = "Tooltip",          implemented = true),
    (slug = "tree-view",        title = "Tree View",        implemented = true),
    (slug = "typography",       title = "Typography",       implemented = true),
]

"""
Sidebar link for an implemented item — clickable with active state.
"""
function ComponentSidebarLink(slug, title; base_path="components")
    # "index" slug links to the section root, all others to slug subdirectory
    href = slug == "index" ? "./$(base_path)/" : "./$(base_path)/$(slug)/"
    NavLink(href, title;
        class = "block px-3 py-1.5 text-sm rounded transition-colors",
        active_class = "text-accent-700 dark:text-accent-400 bg-warm-100 dark:bg-warm-900 border-l-2 border-accent-600 -ml-0.5 pl-[calc(0.75rem+2px)]",
        inactive_class = "text-warm-600 dark:text-warm-400 hover:text-warm-800 dark:hover:text-white hover:bg-warm-50 dark:hover:bg-warm-900",
        exact = true
    )
end

"""
Muted text for an unimplemented component — not clickable.
"""
function ComponentSidebarMuted(title)
    Span(:class => "block px-3 py-1.5 text-sm text-warm-500 dark:text-warm-500 cursor-default", title)
end

"""
Render a sidebar section from an items list.
"""
function _render_sidebar_section(heading, items; base_path)
    Nav(:class => "py-4 px-2",
        H4(:class => "px-3 mb-2 text-xs font-semibold tracking-wider uppercase text-warm-600 dark:text-warm-400",
            heading
        ),
        Div(:class => "space-y-0.5 mb-2",
            map(items) do item
                if item.implemented
                    ComponentSidebarLink(item.slug, item.title; base_path)
                else
                    ComponentSidebarMuted(item.title)
                end
            end...
        )
    )
end

"""
Sidebar for Getting Started pages.
"""
function GettingStartedSidebar()
    _render_sidebar_section("Getting Started", GETTING_STARTED_ITEMS; base_path="getting-started")
end

"""
Sidebar for Component pages.
"""
function ComponentsSidebar()
    _render_sidebar_section("Components", COMPONENT_ITEMS; base_path="components")
end

"""
Sidebar for Widget pages.
"""
function WidgetsSidebar()
    _render_sidebar_section("Widgets", WIDGET_ITEMS; base_path="widgets")
end
