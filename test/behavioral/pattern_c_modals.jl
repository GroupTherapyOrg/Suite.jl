# Pattern C — Modals & Floating: Dialog, Sheet, Popover, Select, etc.
# Reference: Thaw Dialog, Drawer, Popover, Select (thaw-behavioral-specs.md)
# Architecture: Parent + Trigger split, context signal, ShowDescendants

@testset "Pattern C — Modals & Floating" begin
    # CollapsibleTrigger smoke test (known working from suite-wasm loop)
    @testset "Collapsible smoke" begin
        @testset "SSR structure" begin
            html = render(Collapsible(
                CollapsibleTrigger("Toggle"),
                CollapsibleContent(Div("Content")),
            ))
            @test occursin("therapy-island", html)
            @test occursin("Toggle", html)
            @test occursin("Content", html)
        end

        @testset "Wasm structure" begin
            @test wasm_valid("CollapsibleTrigger")
            @test has_handler("CollapsibleTrigger")  # handler_0 (v2 compiled handler)
        end
    end
end
