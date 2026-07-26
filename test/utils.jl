using MathML, EzXML, Test

fn = "data/vinnakota_kemp_kushmeric_2006_exp45.cellml"
doc = readxml(fn)
docroot = doc.root
maths = extract_mathml(fn)
@test length(maths) == 24

@testset "public XML input interface" begin
    @test length(extract_mathml(doc)) == length(maths)
    @test length(extract_mathml(docroot)) == length(maths)

    xml = xml"<math xmlns=\"http://www.w3.org/1998/Math/MathML\"><ci>x</ci><ci>y</ci></math>"
    @test string.(mathml_to_nums(xml)) == ["x", "y"]
    @test xml.name == "math"
end
