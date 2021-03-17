using MathML, EzXML, Symbolics, SpecialFunctions, IfElse, AbstractTrees, Test

@testset "MathML.jl" begin
    @testset "parsing" begin include("parse.jl") end
    @testset "utils" begin include("utils.jl") end
    @testset "print" begin include("print.jl") end
    # @testset "systems" begin include("sys.jl") end
end
