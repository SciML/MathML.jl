using ModelingToolkit
fn = "test/data/lorenz.xml"
xml = readxml(fn).root
eqs = parse_node(xml)
ODESystem(eqs)
@test !isnothing() # TODO
