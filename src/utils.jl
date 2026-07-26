const mathml_ns = "http://www.w3.org/1998/Math/MathML"

"""
    mathml_to_nums(input)

Return the unique symbolic identifiers declared by MathML `<ci>` elements.

# Arguments

- `input`: A filename as an `AbstractString`, an XML document with a `root` property,
  or an XML element rooted in the MathML namespace.

# Returns

A `Vector{Symbolics.Num}` in first-occurrence order. Repeated `<ci>` values occur once.

# Examples

```jldoctest
julia> mathml_to_nums(parsexml("<math xmlns='http://www.w3.org/1998/Math/MathML'><ci>x</ci><ci>x</ci><ci>y</ci></math>"))
2-element Vector{Symbolics.Num}:
 x
 y
```
"""
function mathml_to_nums(input)
    node = _mathml_root(input)
    cis = findall("//x:ci", node, ["x" => mathml_ns])
    return unique(parse_ci.(cis))
end

"""
    extract_mathml(input)

Extract all MathML `<math>` elements from an XML document or element.

# Arguments

- `input`: A filename as an `AbstractString`, an XML document with a `root` property,
  or an XML element in a document that uses the MathML namespace.

# Returns

A vector of XML elements. Before extraction, `<eq>` nodes below `<piecewise>` are
renamed to `<equal>` so later parsing distinguishes equality predicates from
assignments.

# Examples

```jldoctest
julia> length(extract_mathml(parsexml("<root xmlns='http://www.w3.org/1998/Math/MathML'><math><cn>1</cn></math></root>")))
1
```
"""
function extract_mathml(input)
    node = _mathml_root(input)
    disambiguate_equality!(node)
    return findall("//x:math", node, ["x" => mathml_ns])
end

function _mathml_root(input)
    input isa AbstractString && return getproperty(readxml(input), :root)
    return hasproperty(input, :root) ? getproperty(input, :root) : input
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
    xml\"...\"

Parse an XML string literal into its root element at runtime.

# Arguments

- String literal: Well-formed XML whose root is returned as an `EzXML` element.

# Examples

```jldoctest
julia> xml\"<cn>2</cn>\".name
\"cn\"
```
"""
macro xml_str(s)
    return parsexml(s).root
end

"""
    MathML\"...\"

Parse a MathML string literal into its Symbolics representation.

# Arguments

- String literal: MathML XML supported by [`parse_str`](@ref).

# Examples

```jldoctest
julia> MathML\"<apply><plus/><cn>2</cn><cn>3</cn></apply>\"
5.0
```
"""
macro MathML_str(s)
    return MathML.parse_str(s)
end

function custom_root(x)
    return length(x) == 1 ? sqrt(x...) : Base.:^(x[2], x[1])
end

"ensure theres only one independent variable, returns false if more than one iv"
function check_ivs(node)
    x = findall("//x:bvar", node, ["x" => MathML.mathml_ns])
    return all(y -> y.content == x[1].content, x)
end

# conditional and rounding hacks
H(x) = ifelse(x >= 0, one(x), zero(x))
const ϵ = eps(Float64)
frac(x) = 0.5 - atan(cot(π * x)) / π
function heaviside_or(x)
    return length(x) == 1 ? x[1] : x[1] + heaviside_or(x[2:end]) - x[1] * heaviside_or(x[2:end])
end
