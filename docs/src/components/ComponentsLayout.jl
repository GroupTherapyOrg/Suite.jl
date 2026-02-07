# ComponentsLayout.jl - Layout wrapper for component doc pages
#
# Wraps component page content with sidebar navigation.
# Each component page uses: () -> ComponentsLayout("button", content...)

"""
Wrap component page content with sidebar navigation.

Usage in component pages:
```julia
() -> ComponentsLayout("button",
    H1("Button"),
    P("A button component..."),
)
```
"""
function ComponentsLayout(children...)
    Div(:class => "lg:grid lg:grid-cols-[16rem_minmax(0,1fr)] min-h-[calc(100vh-8rem)]",
        # Sidebar - hidden on mobile, visible on lg+
        Aside(:class => "hidden lg:block shrink-0 border-r border-warm-200 dark:border-warm-700 bg-warm-100/50 dark:bg-warm-900/50 overflow-y-auto",
            :style => "position: sticky; top: 0; height: calc(100vh - 4rem);",
            ComponentsSidebar()
        ),

        # Main content area — w-full ensures stable width regardless of content
        Div(:class => "w-full min-w-0 px-4 sm:px-6 lg:px-8 py-8 max-w-4xl",
            children...
        )
    )
end
