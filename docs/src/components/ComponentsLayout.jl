# ComponentsLayout.jl - Layout wrapper for doc pages with sidebar navigation
#
# Three layout functions for each section:
#   GettingStartedLayout(children...) — Getting Started sidebar
#   ComponentsLayout(children...)     — Components sidebar
#   WidgetsLayout(children...)        — Widgets sidebar

function _sidebar_layout(sidebar_fn, children...)
    Div(:class => "lg:grid lg:grid-cols-[16rem_minmax(0,1fr)] min-h-[calc(100vh-8rem)]",
        # Sidebar - hidden on mobile, visible on lg+
        Aside(:class => "hidden lg:block shrink-0 border-r border-warm-200 dark:border-warm-700 bg-warm-100/50 dark:bg-warm-900/50 overflow-y-auto",
            :style => "position: sticky; top: 0; height: calc(100vh - 4rem);",
            sidebar_fn()
        ),

        # Main content area
        Div(:class => "w-full min-w-0 px-4 sm:px-6 lg:px-8 py-8 max-w-4xl",
            children...
        )
    )
end

"""
Layout for Getting Started pages — shows Getting Started sidebar.
"""
function GettingStartedLayout(children...)
    _sidebar_layout(GettingStartedSidebar, children...)
end

"""
Layout for Component pages — shows Components sidebar.
"""
function ComponentsLayout(children...)
    _sidebar_layout(ComponentsSidebar, children...)
end

"""
Layout for Widget pages — shows Widgets sidebar.
"""
function WidgetsLayout(children...)
    _sidebar_layout(WidgetsSidebar, children...)
end
