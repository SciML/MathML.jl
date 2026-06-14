using SafeTestsets

@safetestset "Aqua" begin
    using MathML, Aqua, Test
    # deps_compat (extras: Pkg has no [compat] entry) and piracies (children/nodetype/printnode
    # on EzXML.Node) are genuine findings tracked in
    # https://github.com/SciML/MathML.jl/issues/104 — run the rest of Aqua, mark these broken.
    Aqua.test_all(MathML; deps_compat = false, piracies = false)
    @test_broken false  # Aqua deps_compat: [extras] Pkg missing [compat] entry — tracked in https://github.com/SciML/MathML.jl/issues/104
    @test_broken false  # Aqua piracies: children/nodetype/printnode on EzXML.Node (src/utils.jl) — tracked in https://github.com/SciML/MathML.jl/issues/104
end

@safetestset "JET" begin
    using MathML, JET, Test
    # JET reports a genuine error: no matching method `mathml_to_nums(::EzXML.Node)` is
    # ever defined, yet mathml_to_nums(::EzXML.Document) calls it (src/utils.jl:20).
    # Tracked in https://github.com/SciML/MathML.jl/issues/104 — run in report mode and
    # mark broken instead of failing the testset.
    rep = JET.report_package(MathML; target_defined_modules = true)
    @test_broken isempty(JET.get_reports(rep))  # JET: missing method mathml_to_nums(::EzXML.Node) — tracked in https://github.com/SciML/MathML.jl/issues/104
end
