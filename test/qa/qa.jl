using MathML, Aqua, JET, Test

@testset "Aqua" begin
    Aqua.test_all(MathML)
end

@testset "JET" begin
    JET.test_package(MathML; target_defined_modules = true)
end
