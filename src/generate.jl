"""
    to_MathML(e::Union{Expr, Symbolics.Num})

take an expression and turn it into MathML

!!! note

    The current support is limited to simple algebraic expressions.
"""
function to_MathML(e::Expr)
    link!(ElementNode("math"), _symbol_to_MathML(e::Expr))
end

to_MathML(e::Num) = to_MathML(Symbolcis.toexpr(e))

const OP_TO_NODE = Dict(:+ => ElementNode("plus"),
    :* => ElementNode("times"),
    :- => ElementNode("minus"),
    :^ => ElementNode("power"),
    :sin => ElementNode("sin"),
    :cos => ElementNode("cos"))

function _symbol_to_MathML(e::Expr)
    @assert e.head in (:call, :invoke)
    elm = ElementNode("apply")
    for arg in @views e.args[2:end]
        if arg isa Expr
            node = _symbol_to_MathML(arg)
        elseif arg isa Number
            node = ElementNode("cn")
            link!(node, TextNode(string(arg)))
        elseif arg isa Symbol
            if arg in keys(OP_TO_NODE)
                node = OP_TO_NODE[arg]
            else
                node = ElementNode("ci")
                link!(node, TextNode(string(arg)))
            end
        end
        link!(elm, node)
    end
    return elm
end
