using MathML, EzXML, Symbolics, Test

@testset "MathML.jl" begin
    @testset "parsing" begin include("parse.jl") end
    @testset "utils" begin include("parse.jl") end
end
