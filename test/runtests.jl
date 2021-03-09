using MathML
using Symbolics
using Test

@testset "MathML.jl" begin
    # Write your tests here.
    fn = "data/math.xml"
    vs = mathml_to_nums(fn)
    @test eltype(vs) == Num
    @test length(vs) == 3

    fn = "data/vinnakota_kemp_kushmeric_2006_exp45.cellml"
    maths = extract_mathml(fn)
    @test length(maths) == 24
end
