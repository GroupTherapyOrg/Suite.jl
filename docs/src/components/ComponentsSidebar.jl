# ComponentsSidebar.jl - Sidebar navigation for Suite.jl component docs
#
# Data-driven sidebar listing all shadcn/ui components.
# Implemented components are clickable links; unimplemented are muted.

# All components with their implementation status.
# Set `implemented = true` once the component exists in Suite.jl.
const SUITE_COMPONENTS = [
    # --- Getting Started ---
    (section = "Getting Started", items = [
        (slug = "introduction",     title = "Introduction",     implemented = false),
        (slug = "installation",     title = "Installation",     implemented = false),
    ]),
    # --- Components (alphabetical) ---
    (section = "Components", items = [
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
        (slug = "resizable",        title = "Resizable",        implemented = false),
        (slug = "scroll-area",      title = "Scroll Area",      implemented = true),
        (slug = "select",           title = "Select",           implemented = true),
        (slug = "separator",        title = "Separator",        implemented = true),
        (slug = "sheet",            title = "Sheet",            implemented = true),
        (slug = "skeleton",         title = "Skeleton",         implemented = true),
        (slug = "slider",           title = "Slider",           implemented = false),
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
    ]),
]

"""
Sidebar link for an implemented component — clickable with active state.
"""
function ComponentSidebarLink(slug, title)
    NavLink("./components/$(slug)/", title;
        class = "block px-3 py-1.5 text-sm text-warm-600 dark:text-warm-400 hover:text-warm-800 dark:hover:text-white hover:bg-warm-50 dark:hover:bg-warm-900 rounded transition-colors",
        active_class = "text-accent-700 dark:text-accent-400 bg-warm-100 dark:bg-warm-900 border-l-2 border-accent-600 -ml-0.5 pl-[calc(0.75rem+2px)]",
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
Render the full components sidebar.
"""
function ComponentsSidebar()
    Nav(:class => "py-4 px-2",
        map(SUITE_COMPONENTS) do section
            Fragment(
                H4(:class => "px-3 mb-2 mt-4 first:mt-0 text-xs font-semibold tracking-wider uppercase text-warm-600 dark:text-warm-400",
                    section.section
                ),
                Div(:class => "space-y-0.5 mb-2",
                    map(section.items) do item
                        if item.implemented
                            ComponentSidebarLink(item.slug, item.title)
                        else
                            ComponentSidebarMuted(item.title)
                        end
                    end...
                )
            )
        end...
    )
end
