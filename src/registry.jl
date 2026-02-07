# Suite.jl Component Registry
#
# Maps component names to metadata for extraction (Suite.extract).
# Each component file registers itself at the bottom via register_component!().

export ComponentMeta, register_component!, resolve_deps

"""
Metadata for a Suite.jl component, used by the extraction system.

# Fields
- `name::Symbol`: Component identifier (e.g., `:Button`, `:Dialog`)
- `file::String`: Filename relative to `src/components/` (e.g., `"Button.jl"`)
- `tier::Symbol`: Implementation tier — `:styling`, `:island`, or `:js_runtime`
- `description::String`: Brief description for `Suite.list()`
- `suite_deps::Vector{Symbol}`: Other Suite components this depends on
- `js_modules::Vector{Symbol}`: JS runtime modules needed (e.g., `[:FocusTrap]`)
- `exports::Vector{Symbol}`: Exported function names (e.g., `[:Button]`)
"""
struct ComponentMeta
    name::Symbol
    file::String
    tier::Symbol
    description::String
    suite_deps::Vector{Symbol}
    js_modules::Vector{Symbol}
    exports::Vector{Symbol}
end

const COMPONENT_REGISTRY = Dict{Symbol, ComponentMeta}()

"""
    register_component!(meta::ComponentMeta)

Register a component in the Suite.jl registry. Called at the bottom of each
component file to declare its metadata for the extraction system.
"""
function register_component!(meta::ComponentMeta)
    COMPONENT_REGISTRY[meta.name] = meta
end

"""
    resolve_deps(components::Vector{Symbol}) -> Vector{Symbol}

Resolve the full dependency graph for the given components via topological sort.
Returns components in dependency order (deps before dependents).
"""
function resolve_deps(components::Vector{Symbol})
    visited = Set{Symbol}()
    order = Symbol[]

    function visit(comp::Symbol)
        comp in visited && return
        haskey(COMPONENT_REGISTRY, comp) || error("Unknown component: :$comp. Run Suite.list() to see available components.")
        push!(visited, comp)
        meta = COMPONENT_REGISTRY[comp]
        for dep in meta.suite_deps
            visit(dep)
        end
        push!(order, comp)
    end

    for comp in components
        visit(comp)
    end

    return order
end
