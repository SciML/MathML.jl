module MathML

using EzXML, Symbolics, Statistics, IfElse, AbstractTrees

include("parse.jl")
include("utils.jl")

export extract_mathml, mathml_to_nums, @xml_str, @MathML_str
export parse_node, parse_apply, parse_file, parse_str

export parse_cn, parse_ci, parse_bvar, parse_lambda, parse_piecewise
end
