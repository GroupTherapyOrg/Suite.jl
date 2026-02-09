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

export suite_script, suite_js_source, suite_theme_script

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

"""
    suite_theme_script() -> VNode

Return a `<script>` VNode that detects theme preference before first paint.
Include this in `<head>` to prevent flash of wrong theme (FOUC).

Checks `localStorage('therapy-theme')` first, then falls back to
`prefers-color-scheme: dark` media query. Adds `dark` class to `<html>`.

# Example
```julia
function Layout(children...)
    Html(
        Head(Title("My App"), suite_theme_script()),
        Body(children..., suite_script())
    )
end
```
"""
function suite_theme_script()
    Therapy.Script("""(function(){try{var bp=document.documentElement.getAttribute('data-base-path')||'';var sk=bp?'therapy-theme:'+bp:'therapy-theme';var tk=bp?'suite-active-theme:'+bp:'suite-active-theme';var s=localStorage.getItem(sk);if(s==='dark'||(!s&&window.matchMedia('(prefers-color-scheme:dark)').matches)){document.documentElement.classList.add('dark')}var t=localStorage.getItem(tk);if(t&&t!=='default'){document.documentElement.setAttribute('data-theme',t)}}catch(e){}})();""")
end
