# Components index page — lists all available Suite.jl components

function ComponentsIndex()
    # Flatten all component items (skip Getting Started section)
    all_items = vcat([section.items for section in SUITE_COMPONENTS if section.section != "Getting Started"]...)

    cards = map(all_items) do item
        if item.implemented
            A(:href => "./components/$(item.slug)/",
              :class => "block p-4 rounded-lg border border-warm-200 dark:border-warm-700 hover:border-accent-600 dark:hover:border-accent-400 transition-colors",
                H3(:class => "text-sm font-semibold text-warm-800 dark:text-warm-50", item.title),
                P(:class => "text-xs text-warm-500 dark:text-warm-400 mt-1", "Available")
            )
        else
            Div(:class => "block p-4 rounded-lg border border-warm-200/50 dark:border-warm-700/50 opacity-50",
                H3(:class => "text-sm font-medium text-warm-500 dark:text-warm-500", item.title),
                P(:class => "text-xs text-warm-400 dark:text-warm-600 mt-1", "Coming soon")
            )
        end
    end

    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Components"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "Beautifully designed components built with Therapy.jl. Open source and customizable."
            )
        ),

        # Component grid
        Div(:class => "grid sm:grid-cols-2 lg:grid-cols-3 gap-4",
            cards...
        )
    )
end

ComponentsIndex
