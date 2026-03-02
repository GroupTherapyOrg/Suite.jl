# Pattern A — Simple Toggles: Toggle, Switch, ThemeToggle
# Reference: Thaw Switch, Toggle (thaw-behavioral-specs.md)
# Signal: single Int32 (0/1), Handler: on_click → toggle

@testset "Pattern A — Simple Toggles" begin
    # Smoke test — detailed specs in SUITE-2004
    @testset "Toggle smoke" begin
        html = render(Toggle("Bold"))
        @test occursin("<button", html)
        @test occursin("Bold", html)
    end
end
