"""
    parse_node(node)

take a node and parse into Symbolics form
"""
function parse_node(node)
    tagmap[node.name](node)
end

function parse_str(str)
    doc = parsexml(str)
    parse_doc(doc)
end

function parse_doc(doc)
    node = doc.root
    parse_node(node)
end

function parse_file(fn)
    node = readxml(fn).root
    parse_node(node)
end

"""
    parse_cn(node)

parse a <cn> node
"""
function parse_cn(node)
    # elements(node) != EzXML.Node[] && error("node cant have elements rn, check if </sep> is in the node")
    # this isnt great might want to check that `sep` actually shows up
    if haskey(node, "type") && elements(node) != EzXML.Node[]
        parse_cn_w_sep(node)
    else
        Meta.parse(node.content)
    end
end

"""
    parse_cn_w_sep(node)

parse a <cn type=".."> node

where type ∈ ["e-notation", "rational", "complex-cartesian", "complex-polar"]
"""
function parse_cn_w_sep(node)
    # node = clean_attributes(node)
    txts = findall("text()", node)
    length(txts) != 2 && error("stop, collaborate, and listen!, problem with <cn>")
    x1, x2 = map(x -> Meta.parse(x.content), txts)
    t = node["type"]
    if t == "e-notation"
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

parse a <ci> node
"""
function parse_ci(node)
    c = Meta.parse(strip(node.content))
    Num(Variable(c))
end

########## Parse piecewise ###################################################

function parse_piecewise(node)
    return process_pieces(elements(node))
end

function process_pieces(pieces)
    if length(pieces) == 1
        return process_piece(pieces[1])
    else
        return process_piece(pieces[1], process_pieces(pieces[2:end]))
    end
end

function process_piece(node)
    if nodename(node) != "otherwise"
        error("expect an otherwise")
    else
        return parse_node(firstelement(node))
    end
end

function process_piece(node, otherwise)
    if nodename(node) == "otherwise"
        return parse_node(firstelement(node))
    elseif nodename(node) == "piece"
        c = parse_node.(elements(node))
        return IfElse.ifelse(c[2] > 0.5, c[1], otherwise)
    end
end

"""
    parse_apply(node)

parse an <apply> node into Symbolics form

how to deal w apply within apply, need to ensure we've hit bottom
"""
function parse_apply(node)
    node.name != "apply" && error("calling parse_apply requires the name of the element to be `apply`")
    elms = elements(node)
    cs = parse_node.(elms[2:end])
    applymap[elms[1].name](cs)
end

"""
    parse_bvar(node)

parse a <bvar> node
"""
function parse_bvar(node)
    es = elements(node)
    length(es) == 1 ? (parse_node(es[1]), 1) : Tuple(parse_node.(es))
end

"""
    parse_diff(x)

parse a <diff>

"""
function parse_diff(a)
    (iv, deg), x = a
    # num = Num(Symbolics.Sym{Symbolics.FnType{Tuple{Real},Real}}(Symbol(x))(iv))
    D = Differential(iv)^deg
    D(x)
end

"""
    parse_lambda(node)

parse a <lambda> node

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
    eval(build_function([num], args...)[1])
end
