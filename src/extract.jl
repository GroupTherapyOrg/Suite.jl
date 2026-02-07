# Suite.jl Extraction System
#
# Copies component source files into a user's project directory,
# following the shadcn/ui philosophy: you own the code, not a dependency.

export extract

"""
    extract(components, target_dir; overwrite=false, include_deps=true, include_js=true, theme=:default)

Extract Suite.jl component source files into your project directory.

This copies the component source code so you can customize it freely,
just like `npx shadcn add` does for React projects.

# Arguments
- `components::Union{Symbol, Vector{Symbol}}`: Component(s) to extract
- `target_dir::String`: Directory to copy files into

# Keywords
- `overwrite::Bool = false`: Overwrite existing files (default: skip with warning)
- `include_deps::Bool = true`: Also extract component dependencies
- `include_js::Bool = true`: Copy suite.js if any component needs JS runtime
- `theme::Symbol = :default`: Apply theme substitutions to extracted source files

# Example
```julia
using Suite

# Extract a single component
Suite.extract(:Button, "src/components/")

# Extract multiple with dependencies
Suite.extract([:Dialog, :Card], "src/components/")

# Extract with a theme — class strings are substituted in the output
Suite.extract(:Button, "src/components/", theme=:ocean)
```
"""
function extract(components::Union{Symbol, Vector{Symbol}}, target_dir::String;
                 overwrite::Bool=false, include_deps::Bool=true, include_js::Bool=true,
                 theme::Symbol=:default)
    comps = components isa Symbol ? [components] : components

    # Resolve dependency graph
    all_comps = include_deps ? resolve_deps(comps) : comps

    # Create target directory
    mkpath(target_dir)

    # Track what we extracted
    extracted = String[]
    skipped = String[]
    needs_js = false

    # Copy utils.jl (always needed)
    utils_src = joinpath(@__DIR__, "utils.jl")
    utils_dst = joinpath(target_dir, "utils.jl")
    _copy_file(utils_src, utils_dst, overwrite) && push!(extracted, "utils.jl")

    # Resolve theme for source-level substitution
    t = theme !== :default ? get_theme(theme) : nothing

    # Copy each component
    for comp in all_comps
        meta = COMPONENT_REGISTRY[comp]
        src = joinpath(@__DIR__, "components", meta.file)
        dst = joinpath(target_dir, meta.file)

        if t !== nothing
            # Apply theme substitutions to source before writing
            if _copy_file_themed(src, dst, overwrite, t)
                push!(extracted, meta.file)
            else
                push!(skipped, meta.file)
            end
        else
            if _copy_file(src, dst, overwrite)
                push!(extracted, meta.file)
            else
                push!(skipped, meta.file)
            end
        end

        if !isempty(meta.js_modules)
            needs_js = true
        end
    end

    # Copy JS runtime if needed
    if include_js && needs_js
        js_src = joinpath(@__DIR__, "..", "js", "suite.js")
        js_dst = joinpath(target_dir, "suite.js")
        if _copy_file(js_src, js_dst, overwrite)
            push!(extracted, "suite.js")
        end
    end

    # Print summary
    if !isempty(extracted)
        println("Extracted $(length(extracted)) file(s) to $target_dir:")
        for f in extracted
            println("  + $f")
        end
    end
    if !isempty(skipped)
        println("Skipped $(length(skipped)) existing file(s) (use overwrite=true to replace):")
        for f in skipped
            println("  ~ $f")
        end
    end

    return extracted
end

"""
    list()

Print all available Suite.jl components with their tier and description.
"""
function list()
    if isempty(COMPONENT_REGISTRY)
        println("No components registered yet.")
        return
    end

    println("Suite.jl Components:")
    println("=" ^ 60)

    # Group by tier
    for tier in [:styling, :island, :js_runtime]
        tier_comps = filter(p -> p.second.tier == tier, COMPONENT_REGISTRY)
        isempty(tier_comps) && continue

        tier_label = Dict(:styling => "Pure Styling", :island => "Islands (Wasm)", :js_runtime => "JS Runtime")[tier]
        println("\n  $tier_label:")
        for (name, meta) in sort(collect(tier_comps), by=p -> string(p.first))
            deps_str = isempty(meta.suite_deps) ? "" : " [deps: $(join(meta.suite_deps, ", "))]"
            println("    :$(rpad(string(name), 20)) $(meta.description)$deps_str")
        end
    end
    println()
end

"""
    info(component::Symbol)

Print detailed information about a Suite.jl component.
"""
function info(component::Symbol)
    if !haskey(COMPONENT_REGISTRY, component)
        println("Unknown component: :$component")
        println("Run Suite.list() to see available components.")
        return
    end

    meta = COMPONENT_REGISTRY[component]
    println("Suite.jl Component: :$(meta.name)")
    println("  File:        src/components/$(meta.file)")
    println("  Tier:        $(meta.tier)")
    println("  Description: $(meta.description)")
    println("  Exports:     $(join(meta.exports, ", "))")
    println("  Suite deps:  $(isempty(meta.suite_deps) ? "none" : join(meta.suite_deps, ", "))")
    println("  JS modules:  $(isempty(meta.js_modules) ? "none" : join(meta.js_modules, ", "))")

    # Show full dependency tree
    all_deps = resolve_deps([component])
    if length(all_deps) > 1
        println("  Full dep tree: $(join(all_deps, " → "))")
    end
end

# --- Internal helpers ---

function _copy_file(src::String, dst::String, overwrite::Bool)
    if !isfile(src)
        @warn "Source file not found: $src"
        return false
    end

    if isfile(dst) && !overwrite
        # Check if content is identical
        if read(src, String) == read(dst, String)
            return false  # Skip silently, already up to date
        end
        return false  # Skip, file exists and differs
    end

    cp(src, dst; force=overwrite)
    return true
end

function _copy_file_themed(src::String, dst::String, overwrite::Bool, t::SuiteTheme)
    if !isfile(src)
        @warn "Source file not found: $src"
        return false
    end

    content = read(src, String)
    themed_content = apply_theme_to_source(content, t)

    if isfile(dst) && !overwrite
        if isfile(dst) && read(dst, String) == themed_content
            return false  # Skip silently, already up to date
        end
        return false  # Skip, file exists and differs
    end

    write(dst, themed_content)
    return true
end
