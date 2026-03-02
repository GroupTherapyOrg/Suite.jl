using Test
using Therapy: Therapy, Div, Span, A
using Suite

include("helpers.jl")

@testset "Suite.jl Behavioral Tests" begin
    include("regression_gate.jl")
    include("pattern_a_toggles.jl")
    include("pattern_b_delegation.jl")
    include("pattern_c_modals.jl")
    include("pattern_d_nav.jl")
    include("extraction.jl")
end
