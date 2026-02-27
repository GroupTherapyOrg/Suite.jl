# Suite.jl Theme Script
#
# Provides a FOUC-prevention script that detects theme preference before first paint.
# All component interactivity is now handled by @island (Wasm) — no JS runtime needed.

export suite_theme_script

"""
    suite_theme_script(; default_theme="") -> VNode

Return a `<script>` VNode that detects theme preference before first paint.
Include this in `<head>` to prevent flash of wrong theme (FOUC).

Checks `localStorage('therapy-theme')` first, then falls back to
`prefers-color-scheme: dark` media query. Adds `dark` class to `<html>`.

If `default_theme` is set (e.g. `"islands"`), that theme is applied when
no user preference exists in localStorage.

# Example
```julia
function Layout(children...)
    Html(
        Head(Title("My App"), suite_theme_script(default_theme="islands")),
        Body(children...)
    )
end
```
"""
function suite_theme_script(; default_theme::String="")
    dt = isempty(default_theme) ? "" : default_theme
    Therapy.Script("""(function(){try{var bp=document.documentElement.getAttribute('data-base-path')||'';var sk=bp?'therapy-theme:'+bp:'therapy-theme';var tk=bp?'suite-active-theme:'+bp:'suite-active-theme';var dt='$(dt)';var s=localStorage.getItem(sk);if(s==='dark'||(!s&&window.matchMedia('(prefers-color-scheme:dark)').matches)){document.documentElement.classList.add('dark')}var t=localStorage.getItem(tk);if(t&&t!=='default'){document.documentElement.setAttribute('data-theme',t)}else if(dt){document.documentElement.setAttribute('data-theme',dt)}}catch(e){}})();""")
end
