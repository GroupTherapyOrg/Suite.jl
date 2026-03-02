# Pattern B — Event Delegation: Accordion, Tabs, ToggleGroup
# Reference: Thaw Accordion, TabList (thaw-behavioral-specs.md)
# Signal: single Int32 (index or bitmask), Handler: on_click + event delegation

@testset "Pattern B — Event Delegation" begin

    # =========================================================================
    # Accordion
    # Thaw ref: Accordion — click trigger expands/collapses items
    # =========================================================================
    @testset "Accordion" begin
        @testset "SSR structure" begin
            html = render(Accordion(
                AccordionItem(value="item-1",
                    AccordionTrigger("Question 1"),
                    AccordionContent(Div("Answer 1")),
                ),
                AccordionItem(value="item-2",
                    AccordionTrigger("Question 2"),
                    AccordionContent(Div("Answer 2")),
                ),
            ))
            @test occursin("Question 1", html)
            @test occursin("Question 2", html)
            @test occursin("Answer 1", html)
            @test occursin("Answer 2", html)
            @test occursin("<button", html)
            @test occursin("data-accordion-item", html)
            @test occursin("data-accordion-trigger", html)
        end

        @testset "Data state — all closed by default" begin
            html = render(Accordion(
                AccordionItem(value="item-1",
                    AccordionTrigger("Q1"),
                    AccordionContent(Div("A1")),
                ),
            ))
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "ARIA" begin
            html = render(Accordion(
                AccordionItem(value="item-1",
                    AccordionTrigger("Q1"),
                    AccordionContent(Div("A1")),
                ),
            ))
            @test occursin("aria-expanded", html)
        end

        @testset "Content visibility CSS" begin
            html = render(Accordion(
                AccordionItem(value="item-1",
                    AccordionTrigger("Q1"),
                    AccordionContent(Div("A1")),
                ),
            ))
            # Content should be hidden when closed
            @test occursin("data-[state=closed]:hidden", html) || occursin("hidden", html)
        end

        @testset "Event delegation data-index" begin
            html = render(Accordion(
                AccordionItem(value="a",
                    AccordionTrigger("Q1"),
                    AccordionContent(Div("A1")),
                ),
                AccordionItem(value="b",
                    AccordionTrigger("Q2"),
                    AccordionContent(Div("A2")),
                ),
            ))
            @test occursin("data-index=\"0\"", html)
            @test occursin("data-index=\"1\"", html)
        end

        @testset "Single vs multiple mode" begin
            html_single = render(Accordion(type="single",
                AccordionItem(value="a",
                    AccordionTrigger("Q1"),
                    AccordionContent(Div("A1")),
                ),
            ))
            @test occursin("data-accordion=\"single\"", html_single) ||
                  occursin("single", html_single)

            html_multiple = render(Accordion(type="multiple",
                AccordionItem(value="a",
                    AccordionTrigger("Q1"),
                    AccordionContent(Div("A1")),
                ),
            ))
            @test occursin("data-accordion=\"multiple\"", html_multiple) ||
                  occursin("multiple", html_multiple)
        end

        @testset "Island wrapping" begin
            html = render(Accordion(
                AccordionItem(value="a",
                    AccordionTrigger("Q1"),
                    AccordionContent(Div("A1")),
                ),
            ))
            @test occursin("therapy-island", html)
        end

        @testset "Wasm structure" begin
            @test wasm_valid("Accordion")
            @test has_handler("Accordion")
        end
    end

    # =========================================================================
    # Tabs
    # Thaw ref: TabList — click switches active tab, content panels show/hide
    # =========================================================================
    @testset "Tabs" begin
        @testset "SSR structure" begin
            html = render(Tabs(default_value="tab1",
                TabsList(
                    TabsTrigger(value="tab1", "Tab 1"),
                    TabsTrigger(value="tab2", "Tab 2"),
                ),
                TabsContent(value="tab1", Div("Content 1")),
                TabsContent(value="tab2", Div("Content 2")),
            ))
            @test occursin("Tab 1", html)
            @test occursin("Tab 2", html)
            @test occursin("Content 1", html)
            @test occursin("Content 2", html)
        end

        @testset "ARIA" begin
            html = render(Tabs(default_value="tab1",
                TabsList(
                    TabsTrigger(value="tab1", "Tab 1"),
                ),
                TabsContent(value="tab1", Div("Content")),
            ))
            @test occursin("role=\"tablist\"", html)
            @test occursin("role=\"tab\"", html)
            @test occursin("role=\"tabpanel\"", html)
            @test occursin("aria-selected", html)
        end

        @testset "Data state — active/inactive" begin
            html = render(Tabs(default_value="tab1",
                TabsList(
                    TabsTrigger(value="tab1", "Active"),
                    TabsTrigger(value="tab2", "Inactive"),
                ),
                TabsContent(value="tab1", Div("Content 1")),
                TabsContent(value="tab2", Div("Content 2")),
            ))
            @test occursin("data-state=\"active\"", html)
            @test occursin("data-state=\"inactive\"", html)
        end

        @testset "Content visibility" begin
            html = render(Tabs(default_value="tab1",
                TabsList(
                    TabsTrigger(value="tab1", "T1"),
                    TabsTrigger(value="tab2", "T2"),
                ),
                TabsContent(value="tab1", Div("C1")),
                TabsContent(value="tab2", Div("C2")),
            ))
            @test occursin("data-[state=inactive]:hidden", html) || occursin("hidden", html)
        end

        @testset "Event delegation data-index" begin
            html = render(Tabs(default_value="tab1",
                TabsList(
                    TabsTrigger(value="tab1", "T1"),
                    TabsTrigger(value="tab2", "T2"),
                ),
                TabsContent(value="tab1", Div("C1")),
                TabsContent(value="tab2", Div("C2")),
            ))
            @test occursin("data-index=\"0\"", html)
            @test occursin("data-index=\"1\"", html)
        end

        @testset "Tabindex — roving" begin
            html = render(Tabs(default_value="tab1",
                TabsList(
                    TabsTrigger(value="tab1", "T1"),
                    TabsTrigger(value="tab2", "T2"),
                ),
                TabsContent(value="tab1", Div("C1")),
                TabsContent(value="tab2", Div("C2")),
            ))
            # Active tab should have tabindex=0
            @test occursin("tabindex=\"0\"", html)
        end

        @testset "Island wrapping" begin
            html = render(Tabs(default_value="tab1",
                TabsList(
                    TabsTrigger(value="tab1", "T1"),
                ),
                TabsContent(value="tab1", Div("C1")),
            ))
            @test occursin("therapy-island", html)
        end

        @testset "Wasm structure" begin
            @test wasm_valid("Tabs")
            @test has_handler("Tabs")
        end
    end

    # =========================================================================
    # ToggleGroup
    # Thaw ref: N/A (Radix-style) — click toggles items, single/multiple modes
    # =========================================================================
    @testset "ToggleGroup" begin
        @testset "SSR structure" begin
            html = render(ToggleGroup(type="single",
                ToggleGroupItem(value="left", "Left"),
                ToggleGroupItem(value="center", "Center"),
                ToggleGroupItem(value="right", "Right"),
            ))
            @test occursin("Left", html)
            @test occursin("Center", html)
            @test occursin("Right", html)
            @test occursin("role=\"group\"", html)
        end

        @testset "Data state — off by default" begin
            html = render(ToggleGroup(type="single",
                ToggleGroupItem(value="a", "A"),
            ))
            @test occursin("data-state=\"off\"", html)
        end

        @testset "ARIA — single mode" begin
            html = render(ToggleGroup(type="single",
                ToggleGroupItem(value="a", "A"),
            ))
            # Single mode should have radio semantics
            @test occursin("aria-checked", html) || occursin("aria-pressed", html)
        end

        @testset "Event delegation data-index" begin
            html = render(ToggleGroup(type="single",
                ToggleGroupItem(value="a", "A"),
                ToggleGroupItem(value="b", "B"),
            ))
            @test occursin("data-index=\"0\"", html)
            @test occursin("data-index=\"1\"", html)
        end

        @testset "Island wrapping" begin
            html = render(ToggleGroup(type="single",
                ToggleGroupItem(value="a", "A"),
            ))
            @test occursin("therapy-island", html)
        end

        @testset "Wasm structure" begin
            @test wasm_valid("ToggleGroup")
            @test has_handler("ToggleGroup")
        end
    end
end
