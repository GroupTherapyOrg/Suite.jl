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
using Therapy: provide_context, use_context

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

# --- Module init: re-register @island components after precompilation ---
# Julia precompilation preserves module variables but NOT mutations to other
# modules' mutable globals (like Therapy.ISLAND_REGISTRY). This __init__
# re-registers all IslandDef variables at load time.
function __init__()
    for name in names(@__MODULE__; all=false)
        isdefined(@__MODULE__, name) || continue
        val = getfield(@__MODULE__, name)
        if val isa Therapy.IslandDef
            Therapy.ISLAND_REGISTRY[val.name] = val
        end
    end

    # Register hydration bodies and props transforms for Wasm compilation
    Therapy.register_island_props_transform!(:Tabs, _TABS_PROPS_TRANSFORM)
    Therapy.register_hydration_body!(:Tabs, _TABS_HYDRATION_BODY)
    Therapy.register_island_props_transform!(:Accordion, _ACCORDION_PROPS_TRANSFORM)
    Therapy.register_hydration_body!(:Accordion, _ACCORDION_HYDRATION_BODY)
    Therapy.register_island_props_transform!(:ToggleGroup, _TOGGLEGROUP_PROPS_TRANSFORM)
    Therapy.register_hydration_body!(:ToggleGroup, _TOGGLEGROUP_HYDRATION_BODY)

    # Split island parents (Div + BindModal + children)
    Therapy.register_hydration_body!(:Dialog, _DIALOG_HYDRATION_BODY)
    Therapy.register_hydration_body!(:AlertDialog, _ALERTDIALOG_HYDRATION_BODY)
    Therapy.register_hydration_body!(:Sheet, _SHEET_HYDRATION_BODY)
    Therapy.register_hydration_body!(:Drawer, _DRAWER_HYDRATION_BODY)
    Therapy.register_hydration_body!(:Popover, _POPOVER_HYDRATION_BODY)
    Therapy.register_hydration_body!(:Tooltip, _TOOLTIP_HYDRATION_BODY)
    Therapy.register_hydration_body!(:HoverCard, _HOVERCARD_HYDRATION_BODY)
    Therapy.register_hydration_body!(:DropdownMenu, _DROPDOWNMENU_HYDRATION_BODY)
    Therapy.register_hydration_body!(:ContextMenu, _CONTEXTMENU_HYDRATION_BODY)

    # Split island child triggers (own signal + BindBool/events + children)
    Therapy.register_hydration_body!(:DialogTrigger, _DIALOGTRIGGER_HYDRATION_BODY)
    Therapy.register_hydration_body!(:AlertDialogTrigger, _ALERTDIALOGTRIGGER_HYDRATION_BODY)
    Therapy.register_hydration_body!(:SheetTrigger, _SHEETTRIGGER_HYDRATION_BODY)
    Therapy.register_hydration_body!(:DrawerTrigger, _DRAWERTRIGGER_HYDRATION_BODY)
    Therapy.register_hydration_body!(:PopoverTrigger, _POPOVERTRIGGER_HYDRATION_BODY)
    Therapy.register_hydration_body!(:TooltipTrigger, _TOOLTIPTRIGGER_HYDRATION_BODY)
    Therapy.register_hydration_body!(:HoverCardTrigger, _HOVERCARDTRIGGER_HYDRATION_BODY)
    Therapy.register_hydration_body!(:DropdownMenuTrigger, _DROPDOWNMENUTRIGGER_HYDRATION_BODY)
    Therapy.register_hydration_body!(:ContextMenuTrigger, _CONTEXTMENUTRIGGER_HYDRATION_BODY)
    Therapy.register_island_props_transform!(:NavigationMenu, _NAVIGATIONMENU_PROPS_TRANSFORM)
    Therapy.register_hydration_body!(:NavigationMenu, _NAVIGATIONMENU_HYDRATION_BODY)
    Therapy.register_island_props_transform!(:Menubar, _MENUBAR_PROPS_TRANSFORM)
    Therapy.register_hydration_body!(:Menubar, _MENUBAR_HYDRATION_BODY)

    # Wave 5: Complex inputs + remaining components
    Therapy.register_hydration_body!(:Select, _SELECT_HYDRATION_BODY)
    Therapy.register_hydration_body!(:Command, _COMMAND_HYDRATION_BODY)
    Therapy.register_hydration_body!(:CommandDialog, _COMMANDDIALOG_HYDRATION_BODY)
    Therapy.register_hydration_body!(:Slider, _SLIDER_HYDRATION_BODY)
    Therapy.register_hydration_body!(:Calendar, _CALENDAR_HYDRATION_BODY)
    Therapy.register_hydration_body!(:DatePicker, _DATEPICKER_HYDRATION_BODY)
    Therapy.register_hydration_body!(:DataTable, _DATATABLE_HYDRATION_BODY)
    Therapy.register_hydration_body!(:Form, _FORM_HYDRATION_BODY)
    Therapy.register_hydration_body!(:CodeBlock, _CODEBLOCK_HYDRATION_BODY)
    Therapy.register_hydration_body!(:TreeView, _TREEVIEW_HYDRATION_BODY)
    Therapy.register_hydration_body!(:Carousel, _CAROUSEL_HYDRATION_BODY)
    Therapy.register_hydration_body!(:ResizablePanelGroup, _RESIZABLE_HYDRATION_BODY)
    Therapy.register_hydration_body!(:Toaster, _TOASTER_HYDRATION_BODY)
    Therapy.register_hydration_body!(:ThemeSwitcher, _THEMESWITCHER_HYDRATION_BODY)
end

end # module Suite
