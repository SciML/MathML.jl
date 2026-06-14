using Pkg
using SafeTestsets
using MathML, EzXML, Symbolics, SpecialFunctions, IfElse, AbstractTrees, Test

const GROUP = get(ENV, "GROUP", "All")

if GROUP == "QA"
    Pkg.activate("qa")
    Pkg.develop(PackageSpec(path = dirname(@__DIR__)))
    Pkg.instantiate()
    include("qa/qa.jl")
else
    @testset "MathML.jl" begin
        @safetestset "parsing" begin
            include("parse.jl")
        end
        @safetestset "utils" begin
            include("utils.jl")
        end
        @safetestset "print" begin
            include("print.jl")
        end
        @safetestset "generate" begin
            include("generate.jl")
        end
        # @safetestset "systems" begin include("sys.jl") end
    end
end
