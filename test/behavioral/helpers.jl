# Shared helpers for behavioral tests
# These utilities verify SSR output and Wasm structure

const DIST_DIR = joinpath(@__DIR__, "..", "..", "docs", "dist")

"""Render a component to HTML string."""
function render(component)
    Therapy.render_to_string(component)
end

"""Get the path to a .wasm file in docs/dist/."""
function wasm_path(name::String)
    joinpath(DIST_DIR, lowercase(name) * ".wasm")
end

"""Check if a .wasm file exists and passes validation."""
function wasm_valid(name::String)
    path = wasm_path(name)
    isfile(path) && success(pipeline(`wasm-tools validate $path`))
end

"""Get the text output of wasm-tools dump for a component."""
function wasm_dump(name::String)
    path = wasm_path(name)
    isfile(path) ? read(pipeline(`wasm-tools dump $path`), String) : ""
end

"""Check if a wasm file has a handler export matching the given prefix."""
function has_handler(name::String, handler::String="handler_")
    occursin(handler, wasm_dump(name))
end

"""Count handler exports in a wasm file."""
function count_handlers(name::String)
    count("handler_", wasm_dump(name))
end

"""Check if a wasm file imports a specific JS function."""
function has_import(name::String, import_name::String)
    occursin(import_name, wasm_dump(name))
end

"""Count components with handler exports across all wasm files."""
function count_components_with_handlers()
    wasm_files = filter(f -> endswith(f, ".wasm"), readdir(DIST_DIR))
    count = 0
    for f in wasm_files
        path = joinpath(DIST_DIR, f)
        dump = read(pipeline(`wasm-tools dump $path`), String)
        if occursin("handler_", dump)
            count += 1
        end
    end
    count
end
