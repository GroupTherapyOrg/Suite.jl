#!/usr/bin/env julia
# Suite.jl Documentation Site
#
# Usage (from Suite.jl root directory):
#   julia +1.12 --project=. docs/app.jl dev    # Development server with HMR
#   julia +1.12 --project=. docs/app.jl build  # Build static site to docs/dist

# Use local Therapy.jl if available (sibling directory)
local_therapy = joinpath(dirname(@__DIR__), "..", "Therapy.jl")
if isdir(local_therapy)
    push!(LOAD_PATH, local_therapy)
end

# Use local Suite.jl package
push!(LOAD_PATH, dirname(@__DIR__))

using Therapy
using Suite

# Resolve name conflicts: Suite components take precedence over Therapy HTML elements.
# These Suite.jl names shadow Therapy.jl's raw HTML element functions of the same name.
# Users who need the raw HTML element can use Therapy.Button, Therapy.Input, etc.
import Suite: Button, Input, Form, Label, P, H1, H2, H3, H4,
              Blockquote, Table, Textarea, Select,
              Kbd, Spinner, Empty, EmptyIcon, EmptyTitle, EmptyDescription, EmptyAction,
              CodeBlock, Toolbar, ToolbarGroup, ToolbarSeparator,
              StatusBar, StatusBarSection, StatusBarItem,
              TreeView, TreeViewItem

# Change to docs directory for relative paths
cd(@__DIR__)

# =============================================================================
# App Configuration
# =============================================================================

app = App(
    routes_dir = "src/routes",
    components_dir = "src/components",
    title = "Suite.jl",
    output_dir = "dist",
    base_path = "/Suite.jl",
    layout = :Layout
)

# =============================================================================
# Run - dev or build based on args
# =============================================================================

Therapy.run(app)
