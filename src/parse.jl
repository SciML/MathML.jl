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

function parse_cn(node)
    elements(node) != EzXML.Node[] && error("node cant have elements rn, check if </sep> is in the node")
    Meta.parse(node.content)
end

function parse_ci(node)
    c = Meta.parse(strip(node.content))
    Num(Variable(c))
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

function custom_root(x)
    length(x) == 1 ? sqrt(x...) : Base.:^(x[2], x[1])
end

tagmap = Dict{String,Function}(
    "ci" => parse_ci,
    "cn" => parse_cn,
    "degree" => x-> parse_node(x.firstelement),
    "apply" => parse_apply, # will this work???
    "math" => x -> map(parse_node, elements(x)),
    "vector" => x -> map(parse_node, elements(x)),
)

# need to check the arities 
# units handling??
applymap = Dict{String,Function}(
    "eq" => x -> Symbolics.:~(x...), # arity 2
    "times" => Base.prod, # arity 2, but prod fine
    # "prod" => Base.prod, 
    "divide" => x -> Base.:/(x...),
    "power" => x -> Base.:^(x...),
    "root" => custom_root, 
    "plus" => x -> Base.:+(x...),
    "minus" => x -> Base.:-(x...),
    "lt" => x -> Base.foldl(Base.:<, x),
    "leq" => x -> Base.foldl(Base.:≤, x),
    "geq" => x -> Base.foldl(Base.:≥, x),
    "gt" => x -> Base.foldl(Base.:>, x),
    # "quotient" => x->Base.:div(x...), # broken, RoundingMode
    "factorial" => x -> Base.factorial(x...),
    "max" => x -> Base.max(x...),
    "min" => x -> Base.min(x...),
    "rem" => x -> Base.:rem(x...),
    "gcd" => x -> Base.:gcd(x...),
    "and" => Base.:&,
    "or" => Base.:|,
    "xor" => Base.:⊻,
    "not" => Base.:!,
    "abs" => x -> Base.abs(x...),
    "conjugate" => Base.conj,
    "arg" => Base.angle,
    "real" => Base.real,
    "imaginary" => Base.imag,
    "lcm" =>  x -> Base.lcm(x...),
    "floor" => x -> Base.floor(x...),
    "ceiling" => x -> Base.ceil(x...),
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


    # "apply" => x -> parse_apply(x) # this wont work because we pass the name which is string
)
