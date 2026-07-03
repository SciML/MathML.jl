"""
$(DocStringExtensions.README)
"""
module MathML
using DocStringExtensions: DocStringExtensions

using EzXML: EzXML, ElementNode, TextNode, eachnode, elements, firstelement,
    istext, link!, nodename, parsexml, readxml, setnodename!
using Symbolics: Symbolics, @variables, Differential, Num, build_function
using Statistics: Statistics
using IfElse: IfElse
using AbstractTrees: AbstractTrees
import SpecialFunctions

include("generate.jl")
include("utils.jl")
include("parse.jl")
include("maps.jl")

export extract_mathml, mathml_to_nums, @xml_str, @MathML_str
export parse_node, parse_apply, parse_file, parse_str, to_MathML

export parse_cn, parse_ci, parse_bvar, parse_lambda, parse_piecewise

include("precompilation.jl")

end
