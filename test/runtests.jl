using Pkg

const GROUP = get(ENV, "GROUP", "All")

if GROUP == "QA"
    Pkg.activate("qa")
    Pkg.develop(PackageSpec(path = dirname(@__DIR__)))
    Pkg.instantiate()
    include("qa/qa.jl")
else
    using MathML, EzXML, Symbolics, SpecialFunctions, IfElse, AbstractTrees, Test

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
end
