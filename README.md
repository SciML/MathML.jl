# MathML

[![Github Action CI](https://github.com/SciML/MathML.jl/workflows/CI/badge.svg)](https://github.com/SciML/MathML.jl/actions)
[![Coverage Status](https://coveralls.io/repos/github/SciML/MathML.jl/badge.svg?branch=main)](https://coveralls.io/github/SciML/MathML.jl?branch=main)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://SciML.github.io/MathML.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://SciML.github.io/MathML.jl/dev)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)

A parset for the [MathML](https://en.wikipedia.org/wiki/MathML) XML standard.

Uses Symbolics.jl under the hood for defining equations and uses EzXML.jl for XML parsing.

MathML Specification: https://www.w3.org/TR/MathML3/

## Examples:
```julia
using MathML, EzXML, Symbolics, AbstractTrees
xml = xml"""<math xmlns="http://www.w3.org/1998/Math/MathML">
   <apply>
      <times />
      <ci>compartment</ci>
      <ci>k1</ci>
      <ci>S1</ci>
   </apply>
</math>"""

num = parse_node(xml)
# 1-element Vector{Num}:
#  S1*compartment*k1

# to pretty print the tree use `print_tree`
print_tree(xml)
# math
# └─ apply
#    ├─ times
#    ├─ ci
#    ├─ ci
#    └─ ci

# you can also just go directly from EzXML.Document or String
str = "<apply><power/><ci>x</ci><cn>3</cn></apply>"
MathML.parse_str(str)
# x^3

# derivatives also work!
str = """
<apply><diff/>
  <bvar><ci>x</ci><degree><cn>2</cn></degree></bvar>
  <apply><power/><ci>x</ci><cn>4</cn></apply>
</apply>
"""
expand_derivatives(MathML.parse_str(str))
# 12(x^2)

# there is also a macro @MathML_str to directly call `parse_str`
ml = MathML"""
<apply><diff/>
  <bvar><ci>x</ci><degree><cn>2</cn></degree></bvar>
  <apply><power/><ci>x</ci><cn>4</cn></apply>
</apply>
"""
expand_derivatives(ml)
# 12(x^2)
```

Check the tests in `test/parse.jl` to see a more exhaustive list of what is covered.

## TODO:
* calculus:
    - ivars fix, make ODESystem(parse_node(readxml("lorenz.xml").root)) work
    - partial derivatives `partialdiff` tags
    - integration `int` tags - needs https://github.com/JuliaSymbolics/Symbolics.jl/issues/58
        - often a var like dPidt is assigned to Differential(time)(Pi) where dPidt is referred to after this \<eq> (I think solution is `Symbolics.diff2term`)
    - `diff`s with no independent variable: like `<apply><diff/><ci>f</ci></apply>`

## DONE:
* nested apply
* fix sep/ tags in cn, take `type` attribute into account
    - rational, e-notation, complex, complex polar
* basic diff handling
* bound variables like bvar, might be lingering issues though
* `eq` nodes sometimes needs to be ~ and sometimes needs to be =
* fix `sep` tags in `ci`s, take `type` attribute into account
* `piecewise` tags: make heaviside test work
* fix undefined namespacing issues https://github.com/JuliaIO/EzXML.jl/issues/156
    - parsets like SBML and CellMLToolkit should be handling
* to_mathml: julia expr -> mathml and Symbolics Num -> mathml. round tripping
