using EzXML, Symbolics

const mathml_ns = "http://www.w3.org/1998/Math/MathML"

"""
    mathml_to_nums()

given a filename or (not yet) an `EzXML.Document`, 
finds all of the <ci>s and defines them as Symbolics.jl Nums
returns a Vector
"""
function mathml_to_nums end 

function mathml_to_nums(fn::AbstractString)
    xml = readxml(fn)
    root = EzXML.root(xml)
    ns = namespace(root)
    cs = findall("//x:ci/text()", root, ["x"=>ns])
    vars = @. Symbol(strip(string(cs)))
    @. Num(Variable{Symbolics.FnType{Tuple{Any},Real}}(vars))
end


"""
    extract_mathml()

given a filename or (not yet) an `EzXML.Document`, 
returns all of the MathML nodes. 
"""
function extract_mathml end

function extract_mathml(fn::AbstractString)
    xml = readxml(fn)
    root = EzXML.root(xml)
    ns = namespace(root)
    findall("//x:math", root, ["x"=>mathml_ns])
end