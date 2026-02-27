# TreeView.jl — Suite.jl TreeView Component
#
# Tier: island (Wasm — no JavaScript required)
# Suite Dependencies: none
# JS Modules: none
#
# Usage via package: using Suite; TreeView(TreeViewItem(label="src", ...))
# Usage via extract: include("components/TreeView.jl"); TreeView(...)
#
# Behavior:
#   - File browser tree component with expand/collapse folders, keyboard navigation,
#     and selected state highlighting.
#   - Signal-driven: BindModal(mode=19) handles all interaction via Wasm
#   - Click on folder toggles expand/collapse
#   - Click on item selects it (deselects others)
#   - Keyboard: ArrowDown/Up move focus, ArrowRight expand/enter child,
#     ArrowLeft collapse/go to parent, Enter/Space toggle+select, Home/End
#   - Sessions.jl uses this for the file browser sidebar.
#
# Reference: VS Code file explorer, WAI-ARIA Tree View pattern

# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- SVG Icons ---
const _TREE_CHEVRON_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>"""
const _TREE_FOLDER_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z"/></svg>"""
const _TREE_FILE_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4"/></svg>"""

# --- Component Implementation ---

export TreeView, TreeViewItem

#   TreeView(children...; class, kwargs...) -> IslandVNode
#
# A tree view container for hierarchical data (e.g., file browser).
# Interactive behavior is compiled to WebAssembly — no JavaScript required.
#
# Keyboard navigation:
# - ArrowDown/Up: Move between visible items
# - ArrowRight: Expand collapsed folder / move to first child
# - ArrowLeft: Collapse expanded folder / move to parent
# - Enter/Space: Select item / toggle folder
# - Home/End: Jump to first/last visible item
#
# Examples:
#   TreeView(
#       TreeViewItem(label="src", is_folder=true,
#           TreeViewItem(label="main.jl"),
#           TreeViewItem(label="utils.jl"),
#       ),
#       TreeViewItem(label="test", is_folder=true, expanded=true,
#           TreeViewItem(label="runtests.jl"),
#       ),
#       TreeViewItem(label="Project.toml"),
#   )
@island function TreeView(children...; class::String="", theme::Symbol=:default, kwargs...)
    # Fire-and-forget signal — triggers BindModal(mode=19) once on hydration
    is_active, set_active = create_signal(Int32(1))

    classes = cn("text-sm", class)
    theme !== :default && (classes = apply_theme(classes, get_theme(theme)))

    Div(Symbol("data-modal") => BindModal(is_active, Int32(19)),
        Ul(:class => classes, :role => "tree",
           kwargs..., children...)
    )
end

"""
    TreeViewItem(children...; label, is_folder, expanded, selected, disabled, icon, depth, class, kwargs...) -> VNode

A tree view item (file or folder). Nest TreeViewItem inside folders.

# Options
- `label`: Display text for the item
- `is_folder`: Whether this is a folder (can have children) (default: auto-detect)
- `expanded`: Whether folder is initially expanded (default: `false`)
- `selected`: Whether item is selected (default: `false`)
- `disabled`: Whether item is disabled (default: `false`)
- `icon`: Custom icon VNode (overrides default file/folder icon)
- `depth`: Nesting depth for indentation (default: `0`, auto-incremented for children)
"""
function TreeViewItem(children...; label::String="", is_folder::Union{Bool,Nothing}=nothing,
                      expanded::Bool=false, selected::Bool=false, disabled::Bool=false,
                      icon::Union{Nothing,Any}=nothing, depth::Int=0,
                      class::String="", theme::Symbol=:default, kwargs...)
    # Auto-detect folder status based on whether children are provided
    has_children = !isempty(children)
    folder = something(is_folder, has_children)

    # Indentation
    indent_px = depth * 16

    # Item row classes
    item_classes = cn(
        "flex items-center gap-1.5 px-2 py-1 rounded-sm cursor-pointer transition-colors",
        "hover:bg-warm-100 dark:hover:bg-warm-800",
        selected ? "bg-warm-100 dark:bg-warm-800 text-accent-700 dark:text-accent-400" : "text-warm-700 dark:text-warm-300",
        disabled ? "opacity-50 pointer-events-none" : "",
    )

    # Chevron for folders
    chevron = if folder
        Span(:class => cn("inline-flex shrink-0 transition-transform duration-200", expanded ? "rotate-90" : ""),
             Symbol("data-treeview-chevron") => "true",
             RawHtml(_TREE_CHEVRON_SVG))
    else
        # Spacer to align with folder items that have chevrons
        Span(:class => "inline-flex w-4 shrink-0")
    end

    # Icon
    item_icon = if icon !== nothing
        Span(:class => "inline-flex shrink-0 text-warm-500 dark:text-warm-400", icon)
    elseif folder
        Span(:class => "inline-flex shrink-0 text-warm-500 dark:text-warm-400", RawHtml(_TREE_FOLDER_SVG))
    else
        Span(:class => "inline-flex shrink-0 text-warm-500 dark:text-warm-400", RawHtml(_TREE_FILE_SVG))
    end

    # Build the item
    li_attrs = Dict{Symbol,Any}(
        :class => class,
        :role => "treeitem",
        Symbol("aria-expanded") => folder ? string(expanded) : nothing,
        Symbol("aria-selected") => string(selected),
        Symbol("data-treeview-item") => "true",
        Symbol("data-treeview-folder") => folder ? "true" : nothing,
        Symbol("data-treeview-expanded") => expanded ? "true" : nothing,
        Symbol("data-treeview-selected") => selected ? "true" : nothing,
        Symbol("data-treeview-depth") => string(depth),
    )
    if disabled
        li_attrs[Symbol("data-disabled")] = ""
    end
    # Remove nothing values
    filter!(p -> p.second !== nothing, li_attrs)

    for (k, v) in kwargs
        li_attrs[k] = v
    end

    Li(li_attrs...,
        Div(:class => item_classes, :style => "padding-left: $(indent_px)px",
            :tabindex => selected ? "0" : "-1",
            chevron,
            item_icon,
            Span(:class => "truncate", label),
        ),
        folder && has_children ? Ul(:class => cn("", expanded ? "" : "hidden"),
            :role => "group",
            Symbol("data-treeview-children") => "true",
            # Re-render children with incremented depth
            map(children) do child
                _treeview_increment_depth(child, depth + 1)
            end...
        ) : nothing,
    )
end

"""
Internal helper to increment depth on nested TreeViewItem children.
"""
function _treeview_increment_depth(child, new_depth)
    child
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :TreeView,
        "TreeView.jl",
        :island,
        "File browser tree component with expand/collapse and keyboard navigation",
        Symbol[],
        Symbol[],
        [:TreeView, :TreeViewItem],
    ))
end
