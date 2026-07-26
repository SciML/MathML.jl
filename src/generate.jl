"""
    to_MathML(expression)

Convert a Julia algebraic expression to an `EzXML` MathML element.

# Arguments

- `expression`: An `Expr` or `Symbolics.Num` containing calls, numbers, and symbols.
  Supported operators are `+`, `-`, `*`, `^`, `sin`, and `cos`.

# Returns

An `EzXML` element representing the expression. Nested calls are represented with
MathML `<apply>` elements, numbers with `<cn>`, and variables with `<ci>`.

# Errors

Throws an `ArgumentError` when an expression contains an unsupported argument type.

# Examples

```jldoctest
julia> print(to_MathML(:(x + 2)))
<apply><ci>x</ci><cn>2</cn></apply>
```

!!! note

    This converter supports a deliberately small algebraic subset of Julia syntax.
"""
function to_MathML(e::Expr)
    return link!(ElementNode("math"), _symbol_to_MathML(e::Expr))
end

to_MathML(e::Num) = to_MathML(Meta.parse(string(e)))

const OP_TO_NODE = Dict(
    :+ => ElementNode("plus"),
    :* => ElementNode("times"),
    :- => ElementNode("minus"),
    :^ => ElementNode("power"),
    :sin => ElementNode("sin"),
    :cos => ElementNode("cos")
)

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
        else
            throw(ArgumentError("unsupported expression argument $(arg) of type $(typeof(arg))"))
        end
        link!(elm, node)
    end
    return elm
end
