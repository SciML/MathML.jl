using MathML, EzXML, Test

xml = readxml("data/math.xml").root
@test isequal(MathML.parse_node(xml), MathML.parse_file("data/math.xml"))
