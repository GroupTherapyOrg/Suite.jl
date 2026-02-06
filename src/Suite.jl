module Suite

using Therapy

# --- Utility ---
include("utils.jl")

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
# include("components/Table.jl")
include("components/Textarea.jl")
# include("components/Typography.jl")
include("components/AspectRatio.jl")
include("components/Progress.jl")
# include("components/ScrollArea.jl")
# include("components/Breadcrumb.jl")
# include("components/Pagination.jl")

# --- Phase 2: Simple Islands (Wasm) ---
# include("components/Toggle.jl")
# include("components/Checkbox.jl")
# include("components/RadioGroup.jl")
# include("components/Slider.jl")
# include("components/Accordion.jl")
# include("components/Collapsible.jl")
# include("components/Tabs.jl")
# include("components/Switch.jl")
# include("components/ToggleGroup.jl")

# --- Phase 3: JS Runtime Components ---
# include("components/Dialog.jl")
# include("components/DropdownMenu.jl")
# include("components/Popover.jl")
# include("components/Tooltip.jl")
# include("components/Select.jl")
# include("components/Command.jl")
# include("components/Sheet.jl")
# include("components/AlertDialog.jl")
# include("components/ContextMenu.jl")
# include("components/NavigationMenu.jl")
# include("components/HoverCard.jl")
# include("components/Menubar.jl")
# include("components/Toast.jl")
# include("components/Drawer.jl")

# --- Phase 4: Complex Components ---
# include("components/Calendar.jl")
# include("components/DataTable.jl")
# include("components/Form.jl")
# include("components/Carousel.jl")
# include("components/Resizable.jl")

# --- JS Runtime ---
include("runtime.jl")

end # module Suite
