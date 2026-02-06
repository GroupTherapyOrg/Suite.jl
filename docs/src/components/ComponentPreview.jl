# ComponentPreview.jl - Live component preview wrapper
#
# Mirrors shadcn/ui's component preview: bordered container with
# centered component and optional code tab.

"""
Render a live component preview with optional description.
Used on component docs pages to showcase component variants.
"""
function ComponentPreview(children...; title="", description="", class="")
    classes = isempty(class) ? "space-y-4" : "space-y-4 $class"
    Div(:class => classes,
        # Title + description
        if !isempty(title)
            Div(
                H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300", title),
                if !isempty(description)
                    P(:class => "text-sm text-warm-600 dark:text-warm-500", description)
                else
                    Fragment()
                end
            )
        else
            Fragment()
        end,

        # Preview container
        Div(:class => "flex min-h-[150px] w-full items-center justify-center rounded-lg border border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-950 p-10",
            children...
        )
    )
end
