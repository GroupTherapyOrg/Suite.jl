# Pattern C — Modals & Floating: Dialog, Sheet, Popover, Select, DropdownMenu,
#   Tooltip, HoverCard, Collapsible, DatePicker
# Reference: Thaw Dialog, Drawer, Popover, Select (thaw-behavioral-specs.md)
# Architecture: Parent + Trigger split, context signal, ShowDescendants

@testset "Pattern C — Modals & Floating" begin

    # =========================================================================
    # Dialog
    # Thaw ref: Dialog — overlay, Escape dismiss, scroll lock, focus return
    # =========================================================================
    @testset "Dialog" begin
        @testset "SSR structure" begin
            html = render(Dialog(
                DialogTrigger(Button("Open")),
                DialogContent(
                    DialogHeader(DialogTitle("Title"), DialogDescription("Desc")),
                    DialogFooter(Button("Close")),
                ),
            ))
            @test occursin("Open", html)
            @test occursin("Title", html)
            @test occursin("Desc", html)
        end

        @testset "ARIA" begin
            html = render(Dialog(
                DialogTrigger(Button("Open")),
                DialogContent(DialogHeader(DialogTitle("T"))),
            ))
            @test occursin("role=\"dialog\"", html)
            @test occursin("aria-modal=\"true\"", html)
            @test occursin("aria-haspopup=\"dialog\"", html)
            @test occursin("aria-expanded", html)
        end

        @testset "Data state — closed by default" begin
            html = render(Dialog(
                DialogTrigger(Button("Open")),
                DialogContent(DialogHeader(DialogTitle("T"))),
            ))
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Trigger wrapper" begin
            html = render(Dialog(
                DialogTrigger(Button("Open")),
                DialogContent(DialogHeader(DialogTitle("T"))),
            ))
            @test occursin("data-dialog-trigger-wrapper", html)
        end

        @testset "Overlay and content markers" begin
            html = render(Dialog(
                DialogTrigger(Button("Open")),
                DialogContent(DialogHeader(DialogTitle("T"))),
            ))
            @test occursin("data-dialog-overlay", html)
            @test occursin("data-dialog-content", html)
        end

        @testset "Close button" begin
            html = render(Dialog(
                DialogTrigger(Button("Open")),
                DialogContent(DialogHeader(DialogTitle("T"))),
            ))
            @test occursin("data-dialog-close", html)
        end

        @testset "Island wrapping" begin
            html = render(Dialog(
                DialogTrigger(Button("Open")),
                DialogContent(DialogHeader(DialogTitle("T"))),
            ))
            @test occursin("therapy-island", html)
        end

        @testset "Wasm structure" begin
            @test wasm_valid("Dialog")
            @test wasm_valid("DialogTrigger")
            @test has_handler("DialogTrigger")
        end

        @testset "Wasm imports — escape/scroll/focus" begin
            dump = wasm_dump("DialogTrigger")
            @test occursin("push_escape_handler", dump)
            @test occursin("lock_scroll", dump)
            @test occursin("store_active_element", dump)
        end
    end

    # =========================================================================
    # Sheet (Drawer)
    # Thaw ref: OverlayDrawer — slide from side, Escape dismiss, scroll lock
    # =========================================================================
    @testset "Sheet" begin
        @testset "SSR structure" begin
            html = render(Sheet(
                SheetTrigger(Button("Open")),
                SheetContent(
                    SheetHeader(SheetTitle("Title"), SheetDescription("Desc")),
                ),
            ))
            @test occursin("Open", html)
            @test occursin("Title", html)
        end

        @testset "ARIA" begin
            html = render(Sheet(
                SheetTrigger(Button("Open")),
                SheetContent(SheetHeader(SheetTitle("T"))),
            ))
            @test occursin("role=\"dialog\"", html)
            @test occursin("aria-modal", html)
        end

        @testset "Data state" begin
            html = render(Sheet(
                SheetTrigger(Button("Open")),
                SheetContent(SheetHeader(SheetTitle("T"))),
            ))
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Sheet markers" begin
            html = render(Sheet(
                SheetTrigger(Button("Open")),
                SheetContent(SheetHeader(SheetTitle("T"))),
            ))
            @test occursin("data-sheet-trigger-wrapper", html) ||
                  occursin("data-drawer-trigger-wrapper", html)
        end

        @testset "Island wrapping" begin
            html = render(Sheet(
                SheetTrigger(Button("Open")),
                SheetContent(SheetHeader(SheetTitle("T"))),
            ))
            @test occursin("therapy-island", html)
        end

        @testset "Wasm structure" begin
            sheet_valid = wasm_valid("Sheet") || wasm_valid("Drawer")
            @test sheet_valid
            trigger_valid = wasm_valid("SheetTrigger") || wasm_valid("DrawerTrigger")
            @test trigger_valid
        end
    end

    # =========================================================================
    # Popover
    # Thaw ref: Popover — click trigger, Escape dismiss, NO scroll lock
    # =========================================================================
    @testset "Popover" begin
        @testset "SSR structure" begin
            html = render(Popover(
                PopoverTrigger(Button("Click")),
                PopoverContent(Div("Content")),
            ))
            @test occursin("Click", html)
            @test occursin("Content", html)
        end

        @testset "ARIA" begin
            html = render(Popover(
                PopoverTrigger(Button("Click")),
                PopoverContent(Div("Content")),
            ))
            @test occursin("aria-expanded", html)
            @test occursin("aria-haspopup", html)
        end

        @testset "Data state" begin
            html = render(Popover(
                PopoverTrigger(Button("Click")),
                PopoverContent(Div("Content")),
            ))
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Popover content marker" begin
            html = render(Popover(
                PopoverTrigger(Button("Click")),
                PopoverContent(Div("Content")),
            ))
            @test occursin("data-popover-content", html)
        end

        @testset "Island wrapping" begin
            html = render(Popover(
                PopoverTrigger(Button("Click")),
                PopoverContent(Div("Content")),
            ))
            @test occursin("therapy-island", html)
        end

        @testset "Wasm structure" begin
            @test wasm_valid("Popover")
            @test wasm_valid("PopoverTrigger")
            @test has_handler("PopoverTrigger")
        end
    end

    # =========================================================================
    # Select
    # Thaw ref: Select — open dropdown, item selection, combobox role
    # =========================================================================
    @testset "Select" begin
        @testset "SSR structure" begin
            html = render(Select(
                SelectTrigger(SelectValue(placeholder="Pick...")),
                SelectContent(
                    SelectItem(value="apple", "Apple"),
                    SelectItem(value="banana", "Banana"),
                ),
            ))
            @test occursin("Pick...", html)
            @test occursin("Apple", html)
            @test occursin("Banana", html)
        end

        @testset "ARIA" begin
            html = render(Select(
                SelectTrigger(SelectValue(placeholder="Pick...")),
                SelectContent(
                    SelectItem(value="apple", "Apple"),
                ),
            ))
            @test occursin("role=\"combobox\"", html) || occursin("role=\"listbox\"", html)
            @test occursin("aria-expanded", html)
        end

        @testset "Data state" begin
            html = render(Select(
                SelectTrigger(SelectValue(placeholder="Pick...")),
                SelectContent(
                    SelectItem(value="apple", "Apple"),
                ),
            ))
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Select item attributes" begin
            html = render(Select(
                SelectTrigger(SelectValue(placeholder="Pick...")),
                SelectContent(
                    SelectItem(value="apple", "Apple"),
                ),
            ))
            @test occursin("data-select-item", html)
            @test occursin("role=\"option\"", html)
        end

        @testset "Island wrapping" begin
            html = render(Select(
                SelectTrigger(SelectValue(placeholder="Pick...")),
                SelectContent(SelectItem(value="a", "A")),
            ))
            @test occursin("therapy-island", html)
        end

        @testset "Wasm structure" begin
            @test wasm_valid("Select")
            @test wasm_valid("SelectTrigger")
            @test has_handler("SelectTrigger")
        end
    end

    # =========================================================================
    # DropdownMenu
    # Thaw ref: Menu — menu role, menuitem roles
    # =========================================================================
    @testset "DropdownMenu" begin
        @testset "SSR structure" begin
            html = render(DropdownMenu(
                DropdownMenuTrigger(Button("Options")),
                DropdownMenuContent(
                    DropdownMenuItem("Cut"),
                    DropdownMenuItem("Copy"),
                ),
            ))
            @test occursin("Options", html)
            @test occursin("Cut", html)
            @test occursin("Copy", html)
        end

        @testset "ARIA" begin
            html = render(DropdownMenu(
                DropdownMenuTrigger(Button("Options")),
                DropdownMenuContent(
                    DropdownMenuItem("Cut"),
                ),
            ))
            @test occursin("role=\"menu\"", html)
            @test occursin("role=\"menuitem\"", html)
            @test occursin("aria-haspopup", html)
            @test occursin("aria-expanded", html)
        end

        @testset "Data state" begin
            html = render(DropdownMenu(
                DropdownMenuTrigger(Button("Options")),
                DropdownMenuContent(DropdownMenuItem("Cut")),
            ))
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Island wrapping" begin
            html = render(DropdownMenu(
                DropdownMenuTrigger(Button("Options")),
                DropdownMenuContent(DropdownMenuItem("Cut")),
            ))
            @test occursin("therapy-island", html)
        end

        @testset "Wasm structure" begin
            @test wasm_valid("DropdownMenu")
            @test wasm_valid("DropdownMenuTrigger")
            @test has_handler("DropdownMenuTrigger")
        end
    end

    # =========================================================================
    # Tooltip
    # Thaw ref: Tooltip — hover show with delay, role=tooltip
    # =========================================================================
    @testset "Tooltip" begin
        @testset "SSR structure" begin
            html = render(TooltipProvider(
                Tooltip(
                    TooltipTrigger(Button("Hover")),
                    TooltipContent(Span("Tip text")),
                ),
            ))
            @test occursin("Hover", html)
            @test occursin("Tip text", html)
        end

        @testset "ARIA" begin
            html = render(TooltipProvider(
                Tooltip(
                    TooltipTrigger(Button("Hover")),
                    TooltipContent(Span("Tip")),
                ),
            ))
            @test occursin("role=\"tooltip\"", html)
        end

        @testset "Data state" begin
            html = render(TooltipProvider(
                Tooltip(
                    TooltipTrigger(Button("Hover")),
                    TooltipContent(Span("Tip")),
                ),
            ))
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Island wrapping" begin
            html = render(TooltipProvider(
                Tooltip(
                    TooltipTrigger(Button("Hover")),
                    TooltipContent(Span("Tip")),
                ),
            ))
            @test occursin("therapy-island", html)
        end

        @testset "Wasm structure" begin
            @test wasm_valid("Tooltip")
            @test wasm_valid("TooltipTrigger")
        end
    end

    # =========================================================================
    # HoverCard
    # =========================================================================
    @testset "HoverCard" begin
        @testset "SSR structure" begin
            html = render(HoverCard(
                HoverCardTrigger(A(href="#", "@user")),
                HoverCardContent(Div("Card content")),
            ))
            @test occursin("@user", html)
            @test occursin("Card content", html)
        end

        @testset "Data state" begin
            html = render(HoverCard(
                HoverCardTrigger(A(href="#", "User")),
                HoverCardContent(Div("Content")),
            ))
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Island wrapping" begin
            html = render(HoverCard(
                HoverCardTrigger(A(href="#", "User")),
                HoverCardContent(Div("Content")),
            ))
            @test occursin("therapy-island", html)
        end

        @testset "Wasm structure" begin
            @test wasm_valid("HoverCard")
            @test wasm_valid("HoverCardTrigger")
        end
    end

    # =========================================================================
    # Collapsible
    # Thaw ref: Collapse/Tree — click toggles content visibility
    # =========================================================================
    @testset "Collapsible" begin
        @testset "SSR structure" begin
            html = render(Collapsible(
                CollapsibleTrigger("Toggle"),
                CollapsibleContent(Div("Content")),
            ))
            @test occursin("Toggle", html)
            @test occursin("Content", html)
        end

        @testset "ARIA" begin
            html = render(Collapsible(
                CollapsibleTrigger("Toggle"),
                CollapsibleContent(Div("Content")),
            ))
            @test occursin("aria-expanded", html)
        end

        @testset "Data state" begin
            html = render(Collapsible(
                CollapsibleTrigger("Toggle"),
                CollapsibleContent(Div("Content")),
            ))
            @test occursin("data-state=\"closed\"", html)

            html = render(Collapsible(open=true,
                CollapsibleTrigger("Toggle"),
                CollapsibleContent(Div("Content")),
            ))
            @test occursin("data-state=\"open\"", html)
        end

        @testset "Content visibility CSS" begin
            html = render(Collapsible(
                CollapsibleTrigger("Toggle"),
                CollapsibleContent(Div("Content")),
            ))
            @test occursin("data-[state=closed]:hidden", html) || occursin("hidden", html)
        end

        @testset "Island wrapping" begin
            html = render(Collapsible(
                CollapsibleTrigger("Toggle"),
                CollapsibleContent(Div("Content")),
            ))
            @test occursin("therapy-island", html)
        end

        @testset "Wasm structure" begin
            @test wasm_valid("Collapsible")
            @test wasm_valid("CollapsibleTrigger")
            @test has_handler("CollapsibleTrigger")
        end
    end

    # =========================================================================
    # DatePicker
    # Thaw ref: DatePicker — opens Calendar in popover
    # =========================================================================
    @testset "DatePicker" begin
        @testset "Wasm structure" begin
            @test wasm_valid("DatePicker")
        end
    end
end
