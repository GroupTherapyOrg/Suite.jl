module Suite

# Import Therapy module for qualified access (Therapy.Button, Therapy.Input, etc.)
# BUT don't bring conflicting HTML element names into scope, so that Suite's
# own Button/Input/etc. are NEW functions rather than method extensions.
import Therapy

# Import non-conflicting Therapy exports that Suite components use directly
using Therapy: VNode, Fragment, Show, For, ForNode, RawHtml
using Therapy: Div, Span, A, Br, Hr
using Therapy: H5, H6, Strong, Em, Code, Pre
using Therapy: Ul, Ol, Li, Dl, Dt, Dd
using Therapy: Thead, Tbody, Tfoot, Tr, Th, Td, Caption
using Therapy: Img, Video, Audio, Source, Iframe
using Therapy: Header, Footer, Nav, MainEl, Section, Article, Aside
using Therapy: Details, Summary, Figure, Figcaption
using Therapy: Option, Fieldset, Legend
using Therapy: Script, Style, Meta
using Therapy: Svg, Path, Circle, Rect, Line, Polygon, Polyline, Text, G, Defs, Use
using Therapy: render_to_string, render_page
using Therapy: @island, island, IslandDef, get_islands, clear_islands!
using Therapy: create_signal, BindBool, BindModal

using Dates

# --- Utility ---
include("utils.jl")

# --- Theme System ---
include("themes.jl")
include("theme_classes.jl")

# --- Component Registry & Extraction ---
include("registry.jl")
include("extract.jl")

# --- Phase 1: Pure Styling Components ---
include("components/Button.jl")
include("components/Badge.jl")
include("components/Alert.jl")
include("components/Avatar.jl")
include("components/Card.jl")
include("components/Input.jl")
include("components/Label.jl")
include("components/Separator.jl")
include("components/Skeleton.jl")
include("components/Table.jl")
include("components/Textarea.jl")
include("components/Typography.jl")
include("components/AspectRatio.jl")
include("components/Progress.jl")
include("components/ScrollArea.jl")
include("components/Breadcrumb.jl")
include("components/Pagination.jl")

# --- Phase 2: Interactive Components ---
include("components/Collapsible.jl")
include("components/Accordion.jl")
include("components/Tabs.jl")
include("components/Toggle.jl")
include("components/ToggleGroup.jl")
include("components/Switch.jl")
# include("components/Checkbox.jl")
# include("components/RadioGroup.jl")
include("components/Slider.jl")

# --- Theme Components ---
include("components/ThemeToggle.jl")
include("components/ThemeSwitcher.jl")

# --- Phase 3: Island Components ---
include("components/Dialog.jl")
include("components/AlertDialog.jl")
include("components/DropdownMenu.jl")
include("components/Popover.jl")
include("components/Tooltip.jl")
include("components/Select.jl")
include("components/Command.jl")
include("components/Sheet.jl")
include("components/Drawer.jl")
include("components/ContextMenu.jl")
include("components/NavigationMenu.jl")
include("components/HoverCard.jl")
include("components/Menubar.jl")
include("components/Toast.jl")

# --- Phase 4: Complex Components ---
include("components/Calendar.jl")
include("components/DataTable.jl")
include("components/Form.jl")
include("components/Carousel.jl")
include("components/Resizable.jl")

# --- Composite Components ---
include("components/Footer.jl")
include("components/SiteNav.jl")

# --- Sessions.jl Components (SUITE-0904) ---
include("components/Kbd.jl")
include("components/Spinner.jl")
include("components/Empty.jl")
include("components/CodeBlock.jl")
include("components/Toolbar.jl")
include("components/StatusBar.jl")
include("components/TreeView.jl")

# --- Theme Script (FOUC prevention) ---
include("runtime.jl")

end # module Suite
