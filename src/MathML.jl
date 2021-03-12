module MathML

using EzXML, Symbolics, Statistics, IfElse

include("parse.jl")
include("utils.jl")

export extract_mathml, mathml_to_nums, @xml_str, @MathML_str
export parse_node, parse_apply

end
