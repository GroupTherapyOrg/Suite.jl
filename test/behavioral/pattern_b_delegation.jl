# Pattern B — Event Delegation: Accordion, Tabs, ToggleGroup
# Reference: Thaw Accordion, TabList (thaw-behavioral-specs.md)
# Signal: single Int32, Handler: on_click + event delegation

@testset "Pattern B — Event Delegation" begin
    # Smoke test — detailed specs in SUITE-2004
    @testset "Tabs smoke" begin
        html = render(Tabs(default_value="tab1",
            TabsList(
                TabsTrigger(value="tab1", "Tab 1"),
                TabsTrigger(value="tab2", "Tab 2"),
            ),
            TabsContent(value="tab1", Div("Content 1")),
            TabsContent(value="tab2", Div("Content 2")),
        ))
        @test occursin("Tab 1", html)
        @test occursin("Content 1", html)
    end
end
