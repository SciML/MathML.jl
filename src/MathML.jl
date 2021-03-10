module MathML

using EzXML, Symbolics

include("parse.jl")
include("utils.jl")

export extract_mathml, mathml_to_nums, @xml_str
export parse_node, parse_apply

end
