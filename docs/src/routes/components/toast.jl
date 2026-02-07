# Toast — Suite.jl component docs page
#
# Showcases Toaster with default, success, error, warning, and info toast variants.
# Toasts are triggered from client-side JS; Toaster is placed once in the layout.


function ToastPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3",
                "Toast"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A succinct message that is displayed temporarily. Toasts are triggered from client-side JavaScript and managed by a single Toaster placed in your layout."
            )
        ),

        # Default Preview — trigger buttons
        ComponentPreview(title="Default", description="Click each button to trigger a different toast type.",
            Div(:class => "w-full max-w-lg flex flex-wrap gap-3",
                Therapy.RawHtml("""<button class="inline-flex items-center justify-center rounded-md text-sm font-medium h-10 px-4 py-2 bg-accent-600 text-white hover:bg-accent-700 transition-colors" onclick="Suite.toast('Event created')">Default</button>"""),
                Therapy.RawHtml("""<button class="inline-flex items-center justify-center rounded-md text-sm font-medium h-10 px-4 py-2 bg-green-600 text-white hover:bg-green-700 transition-colors" onclick="Suite.toast.success('File uploaded')">Success</button>"""),
                Therapy.RawHtml("""<button class="inline-flex items-center justify-center rounded-md text-sm font-medium h-10 px-4 py-2 bg-accent-secondary-600 text-white hover:bg-accent-secondary-700 transition-colors" onclick="Suite.toast.error('Something went wrong')">Error</button>"""),
                Therapy.RawHtml("""<button class="inline-flex items-center justify-center rounded-md text-sm font-medium h-10 px-4 py-2 bg-amber-600 text-white hover:bg-amber-700 transition-colors" onclick="Suite.toast.warning('Low disk space')">Warning</button>"""),
                Therapy.RawHtml("""<button class="inline-flex items-center justify-center rounded-md text-sm font-medium h-10 px-4 py-2 bg-blue-600 text-white hover:bg-blue-700 transition-colors" onclick="Suite.toast.info('Update available')">Info</button>"""),
            )
        ),

        # Dismissal Preview
        ComponentPreview(title="Programmatic Dismissal", description="Dismiss individual toasts by ID or dismiss all at once.",
            Div(:class => "w-full max-w-lg flex flex-wrap gap-3",
                Therapy.RawHtml("""<button class="inline-flex items-center justify-center rounded-md text-sm font-medium h-10 px-4 py-2 border border-warm-200 dark:border-warm-700 text-warm-800 dark:text-warm-300 hover:bg-warm-100 dark:hover:bg-warm-800 transition-colors" onclick="Suite.toast.dismissAll()">Dismiss All</button>"""),
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "Usage"
            ),
            Main.CodeBlock(language="julia", """using Suite

# Place Toaster once in your layout (e.g. at the root)
Toaster(position="bottom-right")

# Toasts are triggered from client-side JavaScript:
#   Suite.toast("Event created")
#   Suite.toast.success("File uploaded")
#   Suite.toast.error("Something went wrong")
#   Suite.toast.warning("Low disk space")
#   Suite.toast.info("Update available")

# Programmatic dismissal:
#   Suite.toast.dismiss(id)
#   Suite.toast.dismissAll()""")
        ),

        # Notes
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "Notes"
            ),
            Div(:class => "space-y-3 text-warm-600 dark:text-warm-300",
                P("Toasts are entirely client-side. The ", Span(:class => "font-mono text-sm text-accent-600 dark:text-accent-400", "Toaster"), " component renders the container element; individual toasts are created and managed by the ", Span(:class => "font-mono text-sm text-accent-600 dark:text-accent-400", "Suite.toast"), " JavaScript API."),
                P("Place ", Span(:class => "font-mono text-sm text-accent-600 dark:text-accent-400", "Toaster"), " once in your root layout. Multiple toasters on the same page will result in duplicate notifications."),
                P("Each call to ", Span(:class => "font-mono text-sm text-accent-600 dark:text-accent-400", "Suite.toast()"), " returns a toast ID that can be passed to ", Span(:class => "font-mono text-sm text-accent-600 dark:text-accent-400", "Suite.toast.dismiss(id)"), " for programmatic dismissal."),
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "API Reference"
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "Toaster"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(ApiHead()),
                    Tbody(
                        ApiRow("position", "String", "\"bottom-right\"", "Toast placement — \"top-left\", \"top-right\", \"top-center\", \"bottom-left\", \"bottom-right\", \"bottom-center\""),
                        ApiRow("duration", "Int", "4000", "Auto-dismiss duration in milliseconds"),
                        ApiRow("visible_toasts", "Int", "3", "Maximum number of toasts visible at once"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                    )
                )
            ),
            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-100 mt-6 mb-2", "Suite.toast (JS API)"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(
                        Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Method"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                        )
                    ),
                    Tbody(
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Suite.toast(message)"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Show a default toast")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Suite.toast.success(message)"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Show a success toast")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Suite.toast.error(message)"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Show an error toast")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Suite.toast.warning(message)"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Show a warning toast")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Suite.toast.info(message)"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Show an info toast")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Suite.toast.dismiss(id)"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Dismiss a specific toast by its ID")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", "Suite.toast.dismissAll()"),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Dismiss all visible toasts")
                        ),
                    )
                )
            ),
        )
    )
end

function ApiHead()
    Tr(:class => "border-b border-warm-200 dark:border-warm-700",
        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
        Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
    )
end

function ApiRow(prop, type, default, description)
    Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
        Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", prop),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", type),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", default),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", description)
    )
end

ToastPage
