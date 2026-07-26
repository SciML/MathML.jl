"""
    parse_node(node)

Parse one supported MathML XML element into its Symbolics representation.

# Arguments

- `node`: An XML element whose tag is one of the MathML tags implemented by MathML.jl,
  including `apply`, `cn`, `ci`, `piecewise`, `math`, and `lambda`.

# Returns

A scalar symbolic value, symbolic expression, callable generated from `<lambda>`, or
vector, depending on the MathML tag.

# Errors

Throws a `KeyError` for unsupported element names.

# Examples

```jldoctest
julia> parse_node(xml\"<apply><plus/><cn>2</cn><cn>3</cn></apply>\")
5.0
```
"""
function parse_node(node)
    return tagmap[node.name](node)
end

"""
    parse_str(str::AbstractString)

Parse a MathML XML string into a Symbolics expression.

# Arguments

- `str`: A well-formed XML string whose root is a supported MathML element.

# Returns

The value returned by [`parse_node`](@ref) for the document root.

# Examples

```jldoctest
julia> parse_str("<apply><plus/><cn>2</cn><cn>3</cn></apply>")
5.0
```
"""
function parse_str(str::AbstractString)
    doc = parsexml(str)
    return parse_doc(doc)
end

function parse_doc(doc)
    node = doc.root
    return parse_node(node)
end

"""
    parse_file(filename)

Read a MathML XML file and parse the document root into a Symbolics expression.

# Arguments

- `filename`: Path to a readable XML file whose root is a supported MathML element.

# Returns

The value returned by [`parse_node`](@ref) for the document root.

# Examples

```jldoctest
julia> filename = tempname(); write(filename, "<apply><times/><cn>3</cn><cn>2</cn></apply>"); parse_file(filename)
6.0
```
"""
function parse_file(fn::AbstractString)
    node = readxml(fn).root
    return parse_node(node)
end

"""
    parse_cn(node)

Parse a MathML `<cn>` numeric-constant element.

# Arguments

- `node`: A `<cn>` element. Plain text is parsed as `Float64`; a `type` attribute with
  a `<sep/>` child supports `e-notation`, `rational`, `complex-cartesian`, and
  `complex-polar` constants.

# Returns

A numeric value represented by the element.

# Examples

```jldoctest
julia> parse_cn(xml\"<cn>2.5</cn>\")
2.5
```
"""
function parse_cn(node)
    return if haskey(node, "type") && !isempty(elements(node))
        parse_cn_w_sep(node)
    else
        # Float64(Meta.parse(node.content))
        parse(Float64, node.content) # convert to Float64 for CellML compatibility
    end
end

"""
    parse_cn_w_sep(node)

parse a <cn type=".."> node

where type ∈ ["e-notation", "rational", "complex-cartesian", "complex-polar"]
"""
function parse_cn_w_sep(node)
    # node = clean_attributes(node)
    # txts = findall("text()", node)
    txts = [n for n in eachnode(node) if istext(n)]
    length(txts) != 2 && error("stop, collaborate, and listen!, problem with <cn>")
    x1, x2 = map(x -> Meta.parse(x.content), txts)
    t = node["type"]
    return if t == "e-notation"
        x1 * exp10(x2)
    elseif t == "rational"
        Rational(x1, x2)
    elseif t == "complex-cartesian"
        Complex(x1, x2)
    elseif t == "complex-polar"
        x1 * exp(x2 * im)
    else
        error("$t in parse_cn_w_sep, somethings wrong")
    end
end

"""
    parse_ci(node)

Parse a MathML `<ci>` identifier element as a Symbolics variable.

# Arguments

- `node`: A `<ci>` element whose text content is the identifier name. Surrounding
  whitespace is ignored.

# Returns

A `Symbolics.Num` variable.

# Examples

```jldoctest
julia> string(parse_ci(xml\"<ci> x </ci>\"))
\"x\"
```
"""
function parse_ci(node)
    # c = Symbol(Meta.parse(strip(node.content)))
    c = Symbol(string(strip(node.content)))
    return (@variables $c)[1]
end

########## Parse piecewise ###################################################

"""
    parse_piecewise(node)

Parse a MathML `<piecewise>` node into a nested symbolic conditional expression.

# Arguments

- `node`: A `<piecewise>` element containing zero or more `<piece>` children and an
  optional `<otherwise>` child. Each `<piece>` contains a value followed by its
  condition.

# Returns

A nested `ifelse` symbolic expression. When `<otherwise>` is absent, the fallback is
`0.0`.

# Examples

```jldoctest
julia> parse_piecewise(xml\"<piecewise><piece><cn>1</cn><apply><gt/><cn>2</cn><cn>0</cn></apply></piece><otherwise><cn>0</cn></otherwise></piecewise>\")
1.0
```
"""
function parse_piecewise(node)
    ns = elements(node)
    pieces = filter(x -> nodename(x) == "piece", ns)
    others = filter(x -> nodename(x) == "otherwise", ns)

    if length(others) > 0
        otherwise = parse_node(firstelement(others[1]))
    else
        otherwise = 0.0
    end

    return process_pieces(pieces, otherwise)
end

function process_pieces(pieces, otherwise)
    node = pieces[1]
    c = parse_node.(elements(node))
    return ifelse(
        c[2] > 0.5, c[1],
        length(pieces) == 1 ? otherwise :
            process_pieces(pieces[2:end], otherwise)
    )
end

"""
    parse_apply(node)

Parse a MathML `<apply>` element into a Symbolics expression.

# Arguments

- `node`: An `<apply>` element whose first child identifies an operation supported by
  MathML.jl and whose remaining children are its operands.

# Returns

The result of applying the represented operation to recursively parsed operands.

# Errors

Throws an error when `node` is not an `<apply>` element or its operation is unsupported.

# Examples

```jldoctest
julia> parse_apply(xml\"<apply><times/><cn>3</cn><cn>4</cn></apply>\")
12.0
```
"""
function parse_apply(node)
    node.name != "apply" &&
        error("calling parse_apply requires the name of the element to be `apply`")
    elms = elements(node)
    cs = parse_node.(elms[2:end])
    if elms[1].name == "piecewise"
        return parse_piecewise(elms[1])
    end
    return applymap[elms[1].name](cs)
end

"""
    parse_bvar(node)

Parse a MathML `<bvar>` bound-variable element.

# Arguments

- `node`: A `<bvar>` element containing an identifier and, optionally, a `<degree>`.

# Returns

A tuple `(variable, degree)`. The degree defaults to `1`.

# Examples

```jldoctest
julia> parse_bvar(xml\"<bvar><ci>x</ci><degree><cn>2</cn></degree></bvar>\")
(x, 2.0)
```
"""
function parse_bvar(node)
    es = elements(node)
    return length(es) == 1 ? (parse_node(es[1]), 1) : Tuple(parse_node.(es))
end

"""
    parse_diff(x)

parse a <diff>

"""
function parse_diff(a)
    (iv, deg), x = a
    deg = trunc(Int, deg)
    # num = Num(Symbolics.Sym{Symbolics.FnType{Tuple{Real},Real}}(Symbol(x))(iv))
    D = Differential(iv)^deg
    return D(x)
end

"""
    parse_lambda(node)

Parse a MathML `<lambda>` element as a Julia callable.

# Arguments

- `node`: A `<lambda>` element with one or more `<bvar>` children followed by an
  `<apply>` body.

# Returns

A generated function that evaluates the parsed symbolic body for the declared bound
variables.

# Examples

```jldoctest
julia> f = parse_lambda(xml\"<lambda><bvar><ci>x</ci></bvar><apply><plus/><ci>x</ci><cn>1</cn></apply></lambda>\"); f(2)
1-element Vector{Float64}:
 3.0
```

```xml
<lambda>
  <bvar> x1 </bvar><bvar> xn </bvar>
   expression-in-x1-xn
</lambda>
```
"""
function parse_lambda(node)
    es = elements(node)
    vars = findall("//x:bvar | //bvar", node, ["x" => MathML.mathml_ns])
    # vars2 = findall("//bvar", node) # works in tests
    # vars = union(vars, vars2) # FIX

    args = first.(parse_bvar.(vars))
    num = parse_apply(es[end])
    return eval(build_function([num], args...)[1])
end
