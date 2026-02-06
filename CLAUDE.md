# Suite.jl — CLAUDE.md

> shadcn/ui + PlutoUI parity component library for Julia's Therapy.jl framework.
> Pure Julia API, Wasm-powered interactivity, baked-in JS for complex DOM behaviors.

## Quick Start

```julia
using Therapy
using Suite

# Use components directly
SuiteButton(variant="outline", "Click me")
SuiteCard(SuiteCardHeader(SuiteCardTitle("Hello")), SuiteCardContent("World"))

# Extract components to customize
Suite.extract(:Button, "src/components/")  # copies source to your project
Suite.list()                                # see all available components
Suite.info(:Dialog)                         # show deps, tier, exports
```

## Project Structure

```
Suite.jl/
├── src/
│   ├── Suite.jl              # Main module, includes + exports
│   ├── utils.jl              # cn() class merging utility
│   ├── registry.jl           # ComponentMeta struct, COMPONENT_REGISTRY
│   ├── extract.jl            # Suite.extract(), list(), info()
│   ├── runtime.jl            # JS runtime loader (suite_script())
│   └── components/           # One file per component
│       ├── Button.jl         # Reference implementation
│       ├── Card.jl           # (future)
│       └── ...
├── js/
│   └── suite.js              # Behavioral JS (FocusTrap, DismissLayer, etc.)
├── docs/
│   ├── app.jl                # Docs site entry point
│   ├── input.css             # Tailwind v4 design tokens
│   └── src/
│       ├── routes/           # Doc pages (file-based routing)
│       └── components/       # Layout, ComponentPreview, etc.
├── test/
│   └── runtests.jl           # Test suite
├── Project.toml              # Julia package manifest
└── CLAUDE.md                 # This file
```

## Three Component Tiers

| Tier | Strategy | Examples | Interactivity |
|------|----------|----------|---------------|
| **Pure Styling** | Therapy.jl functions + Tailwind | Button, Badge, Card, Alert | None (HTML + CSS) |
| **Islands** | `@island` + Wasm signals | Accordion, Tabs, Toggle | Julia via Wasm |
| **JS Runtime** | `data-suite-*` + suite.js | Dialog, Popover, Tooltip | Baked-in JS |

### Pure Styling Pattern

```julia
function SuiteButton(children...; variant="default", size="default", class="", kwargs...)
    base = "inline-flex items-center ..."
    variants = Dict("default" => "bg-accent-600 text-white ...", ...)
    sizes = Dict("default" => "h-10 px-4 py-2", ...)
    classes = cn(base, variants[variant], sizes[size], class)
    Button(:class => classes, kwargs..., children...)
end
```

### Island Pattern (future)

```julia
@island function SuiteAccordion(; items=[])
    open_index, set_open_index = create_signal(Int32(-1))
    # ... renders with signals
end
```

### JS Runtime Pattern (future)

```julia
function SuiteDialog(children...; class="", kwargs...)
    id = "suite-dialog-" * string(rand(UInt32), base=16)
    Div(:data_suite_dialog => id,
        # Julia renders HTML, suite.js handles focus trap + dismiss
        children...)
end
```

## Component File Template

Every component file follows this structure:

```julia
# --- Self-containment header ---
if !@isdefined(Div); using Therapy end
if !@isdefined(cn); include(joinpath(@__DIR__, "..", "utils.jl")) end

# --- Component Implementation ---
function SuiteFoo(children...; variant="default", class="", kwargs...)
    # ... implementation
end

# --- Registry ---
if @isdefined(register_component!)
    register_component!(ComponentMeta(
        :Foo, "Foo.jl", :styling, "Description",
        Symbol[], Symbol[], [:SuiteFoo],
    ))
end
```

The `@isdefined` guards enable dual-mode usage:
- **Package mode**: `using Suite` (guards skip, Therapy already loaded)
- **Extract mode**: `include("components/Foo.jl")` (guards import if needed)

## Design System

| Role | Color | Hex |
|------|-------|-----|
| Accent (primary) | Purple | `#9558b2` |
| Accent Secondary | Red | `#cb3c33` |
| Neutrals | Warm palette | `warm-50` to `warm-950` |

### Color Token Rules
- Backgrounds/borders/text: `warm-*` neutrals
- Buttons, links, active states: `accent-*` colors
- Never raw hex (except .jl wordmark)
- Never `bg-white`, `neutral-*`, `stone-*`

### shadcn → Suite.jl Mapping
| shadcn variable | Suite.jl token |
|----------------|----------------|
| `--background` | `bg-warm-50 dark:bg-warm-950` |
| `--foreground` | `text-warm-800 dark:text-warm-300` |
| `--primary` | `bg-accent-600` |
| `--destructive` | `bg-accent-secondary-600` |
| `--border` | `border-warm-200 dark:border-warm-700` |
| `--ring` | `ring-accent-600` |

## Naming Conventions

- **Components**: `SuiteButton`, `SuiteCard`, `SuiteDialog` (Suite prefix)
- **Sub-components**: `SuiteCardHeader`, `SuiteCardTitle`, etc.
- **Variants**: kwargs with String values: `variant="outline"`, `size="sm"`
- **HTML elements**: Pair syntax: `Div(:class => "...", children...)`
- **User components**: kwargs: `SuiteButton(variant="outline", "Click")`

## Commands

```bash
# Run tests (62 tests)
cd Suite.jl && julia +1.12 --project=. test/runtests.jl

# Build docs site
cd Suite.jl && julia +1.12 --project=. docs/app.jl build

# Dev server with HMR
cd Suite.jl && julia +1.12 --project=. docs/app.jl dev
```

## Extraction System

Suite.jl follows shadcn's philosophy: you own the code.

```julia
# Extract a component (+ its dependencies)
Suite.extract(:Dialog, "components/")
# → components/utils.jl, components/Button.jl, components/Dialog.jl, components/suite.js

# Extract without dependencies
Suite.extract(:Dialog, "components/"; include_deps=false)

# List all components
Suite.list()

# Component info
Suite.info(:Dialog)
# → File: Dialog.jl, Tier: js_runtime, Deps: [Button], JS: [FocusTrap, DismissLayer]
```

## Dependencies

- **Therapy.jl**: Web framework (VNodes, SSR, @island, App)
- **WasmTarget.jl**: Wasm compilation (transitive via Therapy.jl)

## Commit Style

```
SUITE-XXXX: Brief description
```
