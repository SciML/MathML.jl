using MathML, EzXML, Symbolics, SpecialFunctions, IfElse, AbstractTrees, Test
using SciMLTesting

run_tests(;
    core = () -> begin
        @testset "MathML.jl" begin
            @testset "parsing" begin
                include("parse.jl")
            end
            @testset "utils" begin
                include("utils.jl")
            end
            @testset "print" begin
                include("print.jl")
            end
            @testset "generate" begin
                include("generate.jl")
            end
            # @testset "systems" begin include("sys.jl") end
        end
    end,
    groups = Dict(
        "QA" => (; env = joinpath(@__DIR__, "qa"), body = () -> begin
            include(joinpath(@__DIR__, "qa", "qa.jl"))
        end),
    ),
)
