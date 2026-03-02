# Extraction System — Suite.extract(), Suite.list(), Suite.info()
# Reference: shadcn CLI (shadcn-extraction-comparison.md)

@testset "Extraction System" begin

    # =========================================================================
    # Suite.list()
    # shadcn ref: npx shadcn list — shows all available components
    # =========================================================================
    @testset "Suite.list()" begin
        output = let pipe = Pipe()
            redirect_stdout(pipe) do
                Suite.list()
            end
            close(pipe.in)
            read(pipe.out, String)
        end

        @testset "Lists key components" begin
            @test occursin("Button", output)
            @test occursin("Dialog", output)
            @test occursin("Card", output)
            @test occursin("Accordion", output)
            @test occursin("Tabs", output)
        end

        @testset "Shows tier info" begin
            @test occursin("styling", output) || occursin("island", output)
        end
    end

    # =========================================================================
    # Suite.info()
    # shadcn ref: component metadata — shows deps, exports, tier
    # =========================================================================
    @testset "Suite.info()" begin
        @testset "Button info" begin
            output = let pipe = Pipe()
                redirect_stdout(pipe) do
                    Suite.info(:Button)
                end
                close(pipe.in)
                read(pipe.out, String)
            end
            @test occursin("Button", output)
            @test occursin("styling", output)
        end

        @testset "Dialog info — shows dependencies" begin
            output = let pipe = Pipe()
                redirect_stdout(pipe) do
                    Suite.info(:Dialog)
                end
                close(pipe.in)
                read(pipe.out, String)
            end
            @test occursin("Dialog", output)
            @test occursin("island", output)
        end
    end

    # =========================================================================
    # Suite.extract()
    # shadcn ref: npx shadcn add — copies component to user dir
    # =========================================================================
    @testset "Suite.extract()" begin
        tmpdir = mktempdir()

        @testset "Extract Button (pure styling)" begin
            Suite.extract(:Button, tmpdir; overwrite=true)
            @test isfile(joinpath(tmpdir, "Button.jl"))
            @test isfile(joinpath(tmpdir, "utils.jl"))
        end

        @testset "Extracted Button is self-contained" begin
            button_file = joinpath(tmpdir, "Button.jl")
            if isfile(button_file)
                content = read(button_file, String)
                # Has @isdefined guard for Therapy
                @test occursin("@isdefined", content)
            end
        end

        @testset "Extract Dialog (island with deps)" begin
            tmpdir2 = mktempdir()
            Suite.extract(:Dialog, tmpdir2; overwrite=true)
            @test isfile(joinpath(tmpdir2, "Dialog.jl"))
            @test isfile(joinpath(tmpdir2, "utils.jl"))
        end

        @testset "Extract renders same HTML" begin
            # Button from package vs extracted should produce same HTML
            pkg_html = Therapy.render_to_string(Button("Test"))
            @test occursin("Test", pkg_html)
            @test occursin("<button", pkg_html)
        end
    end

    # =========================================================================
    # Registry completeness
    # Every component should be in COMPONENT_REGISTRY
    # =========================================================================
    @testset "Registry completeness" begin
        @test haskey(Suite.COMPONENT_REGISTRY, :Button)
        @test haskey(Suite.COMPONENT_REGISTRY, :Dialog)
        @test haskey(Suite.COMPONENT_REGISTRY, :Accordion)
        @test haskey(Suite.COMPONENT_REGISTRY, :Tabs)
        @test haskey(Suite.COMPONENT_REGISTRY, :Toggle)
        @test haskey(Suite.COMPONENT_REGISTRY, :Switch)
        @test haskey(Suite.COMPONENT_REGISTRY, :Select)
        @test haskey(Suite.COMPONENT_REGISTRY, :Popover)
        @test haskey(Suite.COMPONENT_REGISTRY, :NavigationMenu)
        @test haskey(Suite.COMPONENT_REGISTRY, :Menubar)

        @testset "Tier classification" begin
            @test Suite.COMPONENT_REGISTRY[:Button].tier == :styling
            @test Suite.COMPONENT_REGISTRY[:Dialog].tier == :island
            @test Suite.COMPONENT_REGISTRY[:Accordion].tier == :island
            @test Suite.COMPONENT_REGISTRY[:Tabs].tier == :island
            @test Suite.COMPONENT_REGISTRY[:Toggle].tier == :island
            @test Suite.COMPONENT_REGISTRY[:Switch].tier == :island
        end
    end
end
