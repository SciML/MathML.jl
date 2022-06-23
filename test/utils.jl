fn = "data/vinnakota_kemp_kushmeric_2006_exp45.cellml"
doc = readxml(fn)
docroot = doc.root
maths = extract_mathml(fn)
@test length(maths) == 24
