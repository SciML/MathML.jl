using MathML, EzXML, Symbolics, SpecialFunctions, Test

@testset "MathML.jl" begin
    @testset "parsing" begin include("parse.jl") end
    @testset "utils" begin include("parse.jl") end
    # @testset "systems" begin include("sys.jl") end
end
