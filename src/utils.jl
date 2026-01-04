const mathml_ns = "http://www.w3.org/1998/Math/MathML"

"""
    mathml_to_nums()

given a filename or an `EzXML.Document` or `EzXML.Node`,
finds all of the <ci>s and defines them as Symbolics.jl Nums
returns a Vector{Num}.
Note, the root namespace needs to be MathML
"""
function mathml_to_nums end

function mathml_to_nums(fn::AbstractString)
    doc = readxml(fn)
    return mathml_to_nums(doc)
end

function mathml_to_nums(xml::EzXML.Document)
    doc_root = EzXML.root(xml)
    return mathml_to_nums(doc_root)
end

"""
    extract_mathml()

given a filename, `EzXML.Document`, or `EzXML.Node`
returns all of the MathML nodes.
"""
function extract_mathml end

function extract_mathml(fn::AbstractString)
    return extract_mathml(readxml(fn))
end

function extract_mathml(doc::EzXML.Document)
    return extract_mathml(EzXML.root(doc))
end

function extract_mathml(node::EzXML.Node)
    disambiguate_equality!(node)
    return findall("//x:math", node, ["x" => mathml_ns])
end

"""
    @disambiguate_equality!

utility function to replace <eq> inside piecewise subtrees to
disambiguate from the assignment <eq>
"""
function disambiguate_equality!(node)
    nodes = findall("//x:piecewise//x:eq", node, ["x" => mathml_ns])
    for n in nodes
        setnodename!(n, "equal")
    end
    return
end

"""
    @xml_str(s)

utility macro for parsing xml strings into node
"""
macro xml_str(s)
    return parsexml(s).root
end

"""
    @MathML_str(s)

utility macro for parsing xml strings into symbolics
"""
macro MathML_str(s)
    return MathML.parse_str(s)
end

# bindings for viewing call tree
AbstractTrees.children(n::EzXML.Node) = elements(n)
AbstractTrees.printnode(io::IO, node::EzXML.Node) = print(io, getproperty(node, :name))
AbstractTrees.nodetype(::EzXML.Node) = EzXML.Node

function custom_root(x)
    return length(x) == 1 ? sqrt(x...) : Base.:^(x[2], x[1])
end

"ensure theres only one independent variable, returns false if more than one iv"
function check_ivs(node)
    x = findall("//x:bvar", node, ["x" => MathML.mathml_ns])
    return all(y -> y.content == x[1].content, x)
end

# conditional and rounding hacks
H(x) = IfElse.ifelse(x >= 0, one(x), zero(x))
const ϵ = eps(Float64)
frac(x) = 0.5 - atan(cot(π * x)) / π
function heaviside_or(x)
    return length(x) == 1 ? x[1] : x[1] + heaviside_or(x[2:end]) - x[1] * heaviside_or(x[2:end])
end
