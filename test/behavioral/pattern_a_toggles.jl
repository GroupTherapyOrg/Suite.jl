# Pattern A — Simple Toggles: Toggle, Switch, ThemeToggle
# Reference: Thaw Switch, Toggle (thaw-behavioral-specs.md)
# Signal: single Int32 (0/1), Handler: on_click → toggle

@testset "Pattern A — Simple Toggles" begin

    # =========================================================================
    # Toggle
    # Thaw ref: ToggleButton — click toggles pressed state
    # =========================================================================
    @testset "Toggle" begin
        @testset "SSR structure" begin
            html = render(Toggle("Bold"))
            @test occursin("<button", html)
            @test occursin("Bold", html)
            @test occursin("type=\"button\"", html)
        end

        @testset "Data state" begin
            # Default: unpressed
            html = render(Toggle("Bold"))
            @test occursin("data-state=\"off\"", html)

            # Pressed initial state
            html = render(Toggle("Bold", pressed=true))
            @test occursin("data-state=\"on\"", html)
        end

        @testset "ARIA" begin
            html = render(Toggle("Bold"))
            @test occursin("aria-pressed=\"false\"", html)

            html = render(Toggle("Bold", pressed=true))
            @test occursin("aria-pressed=\"true\"", html)
        end

        @testset "Variants" begin
            html = render(Toggle("B", variant="outline"))
            @test occursin("border", html)
        end

        @testset "Disabled" begin
            html = render(Toggle("B", disabled=true))
            @test occursin("disabled", html)
        end

        @testset "Island wrapping" begin
            html = render(Toggle("B"))
            @test occursin("therapy-island", html)
        end

        @testset "Wasm structure" begin
            @test wasm_valid("Toggle")
            @test has_handler("Toggle")
        end
    end

    # =========================================================================
    # Switch
    # Thaw ref: Switch — click toggles checked state, thumb slides
    # =========================================================================
    @testset "Switch" begin
        @testset "SSR structure" begin
            html = render(Switch())
            @test occursin("<button", html)
            @test occursin("type=\"button\"", html)
            # Thumb element
            @test occursin("<span", html)
        end

        @testset "ARIA" begin
            html = render(Switch())
            @test occursin("role=\"switch\"", html)
            @test occursin("aria-checked=\"false\"", html)

            html = render(Switch(checked=true))
            @test occursin("aria-checked=\"true\"", html)
        end

        @testset "Data state" begin
            html = render(Switch())
            @test occursin("data-state=\"unchecked\"", html)

            html = render(Switch(checked=true))
            @test occursin("data-state=\"checked\"", html)
        end

        @testset "Thumb animation class" begin
            html = render(Switch())
            # Thumb should have translate class for animation
            @test occursin("translate", html)
        end

        @testset "Disabled" begin
            html = render(Switch(disabled=true))
            @test occursin("disabled", html)
        end

        @testset "Island wrapping" begin
            html = render(Switch())
            @test occursin("therapy-island", html)
        end

        @testset "Wasm structure" begin
            @test wasm_valid("Switch")
            @test has_handler("Switch")
        end
    end

    # =========================================================================
    # ThemeToggle
    # Thaw ref: N/A (Suite-specific) — click toggles dark mode
    # =========================================================================
    @testset "ThemeToggle" begin
        @testset "SSR structure" begin
            html = render(ThemeToggle())
            @test occursin("<button", html)
            @test occursin("type=\"button\"", html)
            # Should have sun/moon icons (SVG)
            @test occursin("<svg", html)
        end

        @testset "ARIA" begin
            html = render(ThemeToggle())
            # Should have accessible label
            @test occursin("aria-label", html) || occursin("Toggle", html)
        end

        @testset "Dark mode CSS classes" begin
            html = render(ThemeToggle())
            # Icons should toggle via dark: CSS
            @test occursin("dark:", html)
        end

        @testset "Island wrapping" begin
            html = render(ThemeToggle())
            @test occursin("therapy-island", html)
        end

        @testset "Wasm structure" begin
            @test wasm_valid("ThemeToggle")
            @test has_handler("ThemeToggle")
        end
    end
end
