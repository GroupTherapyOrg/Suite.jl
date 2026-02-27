# CodeBlock.jl — Suite.jl CodeBlock Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none
# JS Modules: none
#
# Usage via package: using Suite; CodeBlock("println(\"Hello\")", language="julia")
# Usage via extract: include("components/CodeBlock.jl"); CodeBlock(...)
#
# Behavior:
#   - Styled code display container with optional copy-to-clipboard, language badge,
#     and line numbers.
#   - Signal-driven: BindModal(mode=18) handles copy button + Julia syntax highlighting
#   - Copy button: copies code text to clipboard, shows checkmark feedback for 2s
#   - Julia/jl language: auto-highlighted with keyword/string/comment/number colors
#   - Sessions.jl uses this for cell code display and output rendering.

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---

export CodeBlock

# Copy icon SVG
const _CODEBLOCK_COPY_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="14" height="14" x="8" y="8" rx="2" ry="2"/><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/></svg>"""

#   CodeBlock(code; language, show_line_numbers, show_copy, class, kwargs...) -> IslandVNode
#
# A styled code display block with optional copy button, line numbers, and language badge.
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# Options:
# - `language`: Language name to display as badge (e.g., "julia", "javascript")
# - `show_line_numbers`: Whether to display line numbers (default: `false`)
# - `show_copy`: Whether to show copy-to-clipboard button (default: `true`)
#
# Examples:
#   CodeBlock("using Suite\nButton(\"Click\")", language="julia")
#   CodeBlock("npm install", language="bash", show_copy=true)
#   CodeBlock(read("script.jl", String), language="julia", show_line_numbers=true)
@island function CodeBlock(code::String=""; language::String="", show_line_numbers::Bool=false,
                   show_copy::Bool=true, class::String="", theme::Symbol=:default, kwargs...)
    # Fire-and-forget signal — triggers BindModal(mode=18) once on hydration
    is_active, set_active = create_signal(Int32(1))

    wrapper_classes = cn("group relative overflow-hidden rounded-lg border border-warm-200 dark:border-warm-700 bg-warm-950 dark:bg-warm-950", class)
    theme !== :default && (wrapper_classes = apply_theme(wrapper_classes, get_theme(theme)))

    # Header with language badge and copy button
    header_items = Any[]

    if !isempty(language)
        push!(header_items,
            Span(:class => "text-[11px] font-mono uppercase tracking-wider text-warm-400 dark:text-warm-500 select-none",
                 language))
    end

    if show_copy
        push!(header_items,
            Therapy.Button(
                :class => "cursor-pointer ml-auto inline-flex items-center gap-1.5 rounded px-2 py-1 text-xs text-warm-400 hover:text-warm-200 hover:bg-warm-800 transition-colors",
                Symbol("data-codeblock-copy") => "true",
                RawHtml(_CODEBLOCK_COPY_SVG),
            ))
    end

    has_header = !isempty(language) || show_copy

    # Code content with optional line numbers
    code_lines = split(code, '\n')

    code_content = if show_line_numbers
        # Line numbers + code side by side
        Div(:class => "flex",
            # Line numbers gutter
            Div(:class => "flex-none select-none border-r border-warm-800 px-3 py-4 text-right font-mono text-xs leading-6 text-warm-600",
                map(i -> Div(string(i)), 1:length(code_lines))...
            ),
            # Code area
            Pre(:class => "flex-1 overflow-x-auto p-4 font-mono text-sm leading-6 text-warm-200",
                Code(:class => "block", code)
            ),
        )
    else
        Pre(:class => "overflow-x-auto p-4 font-mono text-sm leading-6 text-warm-200",
            Code(:class => "block", code)
        )
    end

    lang_attr = isempty(language) ? Pair{Symbol,String}[] : [Symbol("data-codeblock-lang") => language]
    Div(:class => wrapper_classes,
        Symbol("data-modal") => BindModal(is_active, Int32(18)),
        lang_attr..., kwargs...,
        has_header ? Div(:class => "flex items-center gap-2 border-b border-warm-800 px-4 py-2",
            header_items...
        ) : nothing,
        code_content,
    )
end

# --- Hydration Body (Wasm compilation) ---
# CodeBlock: mode=18 (fire-and-forget, copy button + syntax highlighting handled by JS modal handler)
const _CODEBLOCK_HYDRATION_BODY = quote
    is_active, set_active = create_signal(Int32(1))
    Div(Symbol("data-modal") => BindModal(is_active, Int32(18)))
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :CodeBlock,
        "CodeBlock.jl",
        :island,
        "Styled code display with copy button, line numbers, and language badge",
        Symbol[],
        Symbol[],
        [:CodeBlock],
    ))
end
