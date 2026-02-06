# Suite.jl JS Runtime
#
# Bundles the suite.js JavaScript module that handles complex DOM behaviors
# (focus trapping, dismiss layers, floating positioning, roving focus).
#
# Architecture:
#   - suite.js is baked into the Julia package as a string constant
#   - suite_script() returns a Script VNode that loads it
#   - JS auto-discovers components via data-suite-* attributes
#   - No Node.js, no npm, no build step for users

export suite_script, suite_js_source

const SUITE_JS_PATH = joinpath(@__DIR__, "..", "js", "suite.js")

"""
    suite_js_source() -> String

Return the raw JavaScript source for the Suite.jl runtime.
"""
function suite_js_source()
    read(SUITE_JS_PATH, String)
end

"""
    suite_script() -> VNode

Return a `<script>` VNode that loads the Suite.jl JS runtime.
Include this once in your layout, typically before `</body>`.

# Example
```julia
function Layout(children...)
    Html(
        Head(Title("My App")),
        Body(
            children...,
            suite_script()
        )
    )
end
```
"""
function suite_script()
    Therapy.Script(suite_js_source())
end
