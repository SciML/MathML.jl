"""
    parse_node(node)

take a node and parse into Symbolics form
"""
function parse_node(node)
    tagmap[node.name](node)
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

tagmap = Dict{String,Function}(
    "ci" => parse_ci,
    "cn" => parse_cn,
    "apply" => parse_apply, # will this work???
    "math" => x-> map(parse_apply, elements(x))
)

# need to check the arities 
# units handling??
applymap = Dict{String,Function}(
    "eq" => x -> Symbolics.:~(x...), # arity 2
    "times" => Base.prod, # arity 2, but prod fine
    # "prod" => Base.prod, 
    "divide" => Base.:/,
    "power" => Base.literal_pow,
    "root" => Base.sqrt, # TODO: need to check if there is a degree element
    "plus" => Base.:+,
    "minus" => Base.:-,
    "leq" => x -> Base.:≤(x...),
    "lt" => x -> Base.:<(x...),
    "geq" => x -> Base.:≥(x...),
    "gt" => x -> Base.:>(x...),
    "quotient" => Base.div,
    "factorial" => Base.factorial,
    "max" => Base.max,
    "min" => Base.min,
    "rem" => Base.rem,
    "gcd" => Base.gcd,
    "and" => Base.:&,
    "or" => Base.:|,
    "xor" => Base.:⊻,
    "not" => Base.:!,
    "abs" => Base.abs,
    "conjugate" => Base.conj,
    "arg" => Base.angle,
    "real" => Base.real,
    "imaginary" => Base.imag,
    "lcm" => Base.lcm,
    "floor" => Base.floor,
    "ceiling" => Base.ceil,
    # "apply" => x -> parse_apply(x) # this wont work because we pass the name which is string
)
