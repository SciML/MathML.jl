# MathML

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://anandijain.github.io/MathML.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://anandijain.github.io/MathML.jl/dev)

A parser for the [MathML](https://en.wikipedia.org/wiki/MathML) XML standard.

Uses Symbolics.jl under the hood for defining equations and uses EzXML.jl for XML parsing.

MathML Specification: https://www.w3.org/TR/MathML3/

## Examples:
```julia
using MathML, EzXML, Symbolics
xml = xml"""
<math xmlns="http://www.w3.org/1998/Math/MathML">
  <apply>
    <times/>
    <ci> compartment 
    </ci>
    <ci> k1 
    </ci>
    <ci> S1 
    </ci>
  </apply>
</math>"""

num = parse_node(xml.root)
# S1*compartment*k1

typeof(num)
# Num

xml = xml"""
<math xmlns="http://www.w3.org/1998/Math/MathML">
    <apply>
       <eq/>
       <ci>T</ci>
       <ci>Par_94</ci>
    </apply>
    <apply>
       <eq/>
       <ci>I</ci>
       <ci>Par_90</ci>
    </apply>
</math>"""

num = parse_node(xml.root)
# 2-element Vector{Equation}:
#  T ~ Par_94
#  I ~ Par_90
```

## TODO:
* bound variables like <bvar>
* <piecewise>
* nested apply
