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
# re: `first()` this is ignoring degree. not sure if that matters, but it's weird that parse_bvar gives tuples 
# args = Tuple(
    # args -> eval(fex)(args...) 
function parse_lambda(node)
    es = elements(node)
    vars = findall("//x:bvar", node, ["x" => MathML.mathml_ns])
    args = first.(parse_bvar.(vars))
    num = parse_apply(es[end])
    fex = build_function(num, args...)
end

tagmap = Dict{String,Function}(
    "cn" => parse_cn,
    "ci" => parse_ci,

    "degree" => x -> parse_node(x.firstelement), # won't work for all cases
    "bvar" => parse_bvar, # won't work for all cases

    "piecewise" => parse_piecewise,

    "apply" => parse_apply,
    "math" => x -> map(parse_node, elements(x)),
    "vector" => x -> map(parse_node, elements(x)),
    "lambda" => parse_lambda,
)

function custom_root(x)
    length(x) == 1 ? sqrt(x...) : Base.:^(x[2], x[1])
end

"ensure theres only one independent variable, returns false if more than one iv"
function check_ivs(node)
    x = findall("//x:bvar", node, ["x" => MathML.mathml_ns])
    all(y -> y.content == x[1].content, x)
end

H(x) = IfElse.ifelse(x > 0, one(x), zero(x))
const ϵ = eps(Float64)
frac(x) = 0.5 - atan(cot(π * x)) / π
heaviside_or(x) = length(x) == 1 ? x[1] : x[1] + heaviside_or(x[2:end]) - x[1] * heaviside_or(x[2:end])

# need to check the arities
# units handling??
applymap = Dict{String,Function}(
    # eq sometimes needs to be ~ and sometimes needs to be =, not sure what the soln is
    "eq" => x -> Symbolics.:~(x...), # arity 2,
    "times" => Base.prod, # arity 2, but prod fine
    # "prod" => Base.prod,
    "divide" => x -> Base.:/(x...),
    "power" => x -> Base.:^(x...),
    "root" => custom_root,
    "plus" => x -> Base.:+(x...),
    "minus" => x -> Base.:-(x...),

    # comparison functions implemented using the Heaviside function
    "lt" => x -> H(x[2] - x[1] - ϵ),
    "leq" => x -> H(x[2] - x[1]),
    "geq" => x -> H(x[1] - x[2]),
    "gt" => x -> H(x[1] - x[2] - ϵ),

    # "lt" => x -> Base.foldl(Base.:<, x),
    # "leq" => x -> Base.foldl(Base.:≤, x),
    # "geq" => x -> Base.foldl(Base.:≥, x),
    # "gt" => x -> Base.foldl(Base.:>, x),

    # "quotient" => x->Base.:div(x...), # broken, RoundingMode
    "factorial" => x -> Base.factorial(x...),
    "max" => x -> Base.max(x...),
    "min" => x -> Base.min(x...),
    "rem" => x -> Base.:rem(x...),
    "gcd" => x -> Base.:gcd(x...),

    "and" => x -> Base.:*(x...),
    "or" => heaviside_or,
    "xor" => x -> x[1]*(one(x[2])-x[2]) + (one(x[1])-x[1])*x[2],
    "not" => x -> one(x[1]) - x[1],

    # "and" => x -> Base.:&(x...),
    # "or" => Base.:|,
    # "xor" => Base.:⊻,
    # "not" => Base.:!,

    "abs" => x -> Base.abs(x...),
    "conjugate" => Base.conj,
    "arg" => Base.angle,
    "real" => Base.real,
    "imaginary" => Base.imag,
    "lcm" =>  x -> Base.lcm(x...),

    "floor" => x -> x[1] - frac(x[1]),
    "ceiling" => x -> x[1] - frac(x[1]) + one(x[1]),
    "round" => x -> x[1] + 0.5 - frac(x[1] + 0.5),

    # "floor" => x -> Base.floor(x...),
    # "ceiling" => x -> Base.ceil(x...),
    # "round" => x -> Base.round(x...),

    "inverse" => Base.inv,
    "compose" => x -> Base.:∘(x...),
    "ident" => Base.identity,
    "approx" => x -> Base.:≈(x...),

    "sin" => x -> Base.sin(x...),
    "cos" => x -> Base.cos(x...),
    "tan" => x -> Base.tan(x...),
    "sec" => x -> Base.sec(x...),
    "csc" => x -> Base.csc(x...),
    "cot" => x -> Base.cot(x...),
    "arcsin" => x -> Base.asin(x...),
    "arccos" => x -> Base.acos(x...),
    "arctan" => x -> Base.atan(x...),
    "arcsec" => x -> Base.asec(x...),
    "arccsc" => x -> Base.acsc(x...),
    "arccot" => x -> Base.acot(x...),
    "sinh" => x -> Base.sinh(x...),
    "cosh" => x -> Base.cosh(x...),
    "tanh" => x -> Base.tanh(x...),
    "sech" => x -> Base.sech(x...),
    "csch" => x -> Base.csch(x...),
    "coth" => x -> Base.coth(x...),
    "arcsinh" => x -> Base.asinh(x...),
    "arccosh" => x -> Base.acosh(x...),
    "arctanh" => x -> Base.atanh(x...),
    "arcsech" => x -> Base.asech(x...),
    "arccsch" => x -> Base.acsch(x...),
    "arccoth" => x -> Base.acoth(x...),

    "exp" => x -> Base.exp(x...),
    "log" => x -> Base.log10(x...), #  todo handle <logbase>
    "ln" => x -> Base.log(x...),

    "mean" => Statistics.mean,
    "sdev" => Statistics.std,
    "variance" => Statistics.var,
    "median" => Statistics.median,
    # "mode" => Statistics.mode, # crazy mode isn't in Base

    "vector" => Base.identity,
    "diff" => parse_diff,
    # "apply" => x -> parse_apply(x) # this wont work because we pass the name which is string
)
