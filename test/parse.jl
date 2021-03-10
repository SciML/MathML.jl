# these tests mimic the README examples 
fn = "data/math.xml"
doc = readxml(fn)
num = MathML.parse_node(doc.root)
@variables compartment k1 S1
true_num = prod([compartment, k1, S1])
@test isequal(num, true_num)


fn = "data/eq.xml"
doc = readxml(fn)
eqs = MathML.parse_node(doc.root)
@variables T I Par_94 Par_90
true_eqs = [
    T ~ Par_94,
    I ~ Par_90,
]
@test isequal(eqs, true_eqs)