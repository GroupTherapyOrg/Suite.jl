# Extraction System — Suite.extract(), Suite.list(), Suite.info()
# Reference: shadcn CLI (shadcn-extraction-comparison.md)

@testset "Extraction System" begin
    # Smoke test — detailed specs in SUITE-2004
    @testset "Suite.list() smoke" begin
        output = let pipe = Pipe()
            redirect_stdout(pipe) do
                Suite.list()
            end
            close(pipe.in)
            read(pipe.out, String)
        end
        @test occursin("Button", output)
        @test occursin("Dialog", output)
    end
end
