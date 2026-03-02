# Regression Gate — MUST pass before any commit
# Baseline: 36/36 wasm valid, >= 22 components with handlers

@testset "Regression Gate" begin
    wasm_files = filter(f -> endswith(f, ".wasm"), readdir(DIST_DIR))

    @testset "Wasm files exist" begin
        @test length(wasm_files) >= 36
    end

    @testset "All wasm files validate" begin
        failures = String[]
        for f in wasm_files
            path = joinpath(DIST_DIR, f)
            if !success(pipeline(`wasm-tools validate $path`))
                push!(failures, f)
            end
        end
        if !isempty(failures)
            @warn "Wasm validation failures: $(join(failures, ", "))"
        end
        @test isempty(failures)
    end

    @testset "Handler count >= 22" begin
        n = count_components_with_handlers()
        @test n >= 22
        @info "Components with handlers: $n"
    end
end
