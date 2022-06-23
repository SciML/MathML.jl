using MathML, EzXML, Symbolics, SpecialFunctions, IfElse, AbstractTrees, Test
using Symbolics: variable
# these tests mimic the README examples 
fn = "data/math.xml"
doc = readxml(fn)
num = MathML.parse_node(doc.root)
@variables compartment k1 S1
true_num = prod([compartment, k1, S1])
@test isequal(num, [true_num])

fn = "data/eq.xml"
doc = readxml(fn)
eqs = MathML.parse_node(doc.root)
@variables T I Par_94 Par_90
true_eqs = [
    T ~ Par_94,
    I ~ Par_90,
]
@test isequal(eqs, true_eqs)

@variables w x y z a b t

str = "<apply><compose/><ci>x</ci><ci>y</ci><ci>z</ci></apply>"
@test isequal(MathML.parse_str(str), x ∘ y ∘ z)

str = """<cn type="rational">22<sep/>7</cn>"""
@test isequal(MathML.parse_str(str), 22 // 7)

str = """<cn type="e-notation">5<sep/>2</cn>"""
@test isequal(MathML.parse_str(str), 500)

str = """<cn type="complex-polar"> 2 <sep/> 3.1415 </cn>"""
@test isapprox(MathML.parse_str(str), Complex(-2, 0), atol = 1e-3)

str = """<cn type="complex-cartesian"> 12.3 <sep/> 5 </cn>"""
@test isequal(MathML.parse_str(str), Complex(12.3, 5))

# heaviside and nesting test
str = """
<piecewise>
  <piece>
    <apply><minus/><ci>x</ci></apply>
    <apply><lt/><ci>x</ci><cn>0</cn></apply>
  </piece>
  <piece>
    <cn>0</cn>
    <apply><eq/><ci>x</ci><cn>0</cn></apply>
  </piece>
  <piece>
    <ci>x</ci>
    <apply><gt/><ci>x</ci><cn>0</cn></apply>
  </piece>
</piecewise>
"""
# MathML.parse_str(str) # no <otherwise>

str = """
<piecewise>
<piece>
  <apply>
      <divide/>
      <apply>
        <times/>
        <ci>x</ci>
        <apply>
            <plus/>
            <ci>y</ci>
            <apply>
              <times/>
              <ci>z</ci>
              <ci>a</ci>
            </apply>
        </apply>
      </apply>
      <apply>
        <minus/>
        <cn>1</cn>
        <apply>
            <times/>
            <ci>z</ci>
            <ci>b</ci>
        </apply>
      </apply>
  </apply>
  <apply>
      <leq/>
      <ci>t</ci>
      <cn>1</cn>
  </apply>
</piece>
<otherwise>
  <apply>
      <times/>
      <ci>x</ci>
      <ci>y</ci>
  </apply>
</otherwise>
</piecewise>
"""
@test isequal(MathML.parse_str(str),
              IfElse.ifelse(IfElse.ifelse(1.0 - t >= 0, 1, 0) > 0.5,
                            x * (y + a * z) * ((1.0 - (b * z))^-1),
                            x * y))

# factorial
str = "<apply><factorial/><ci>x</ci></apply>"
@test isequal(MathML.parse_str(str), SpecialFunctions.gamma(1 + x))

str = "<apply><factorial/><cn>5</cn></apply>"
@test MathML.parse_str(str) == 120

# root
str = """
<apply><root/>
  <degree><ci type="integer">y</ci></degree>
  <ci>x</ci>
</apply>
"""
@test isequal(MathML.parse_str(str), x^y)

str = "<apply><root/><ci>x</ci></apply>"
@test isequal(MathML.parse_str(str), sqrt(x))

#  
str = """
<apply><divide/>
<ci>x</ci>
<ci>y</ci>
</apply>
"""
@test isequal(MathML.parse_str(str), x / y)

#  
str = "<apply><max/><cn>2</cn><cn>3</cn><cn>5</cn></apply>"
@test isequal(MathML.parse_str(str), 5)

#  
str = "<apply><min/><ci>x</ci><ci>y</ci></apply>"
@test isequal(MathML.parse_str(str), min(x, y))

#  
str = "<apply><minus/><cn>3</cn></apply>"
@test isequal(MathML.parse_str(str), -3)

#  
str = "<apply><minus/><ci>x</ci><ci>y</ci></apply>"
@test isequal(MathML.parse_str(str), x - y)

#  
str = "<apply><plus/><ci>x</ci><ci>y</ci><ci>z</ci></apply>"
@test isequal(MathML.parse_str(str), x + y + z)

#  
str = "<apply><rem/><ci>x</ci><ci>y</ci></apply>"
@test isequal(MathML.parse_str(str), rem(x, y))

#  
# str = "<apply><gcd/><ci>a</ci><ci>b</ci><ci>c</ci></apply>" # gcd is a ways off, gröbner bases
# MathML.parse_str(str)
# @test isequal(MathML.parse_str(str), )

#  
str = "<apply><abs/><ci>x</ci></apply>"
@test isequal(MathML.parse_str(str), abs(x))

#  
# str = """
# <apply><conjugate/>
#   <apply><plus/>
#     <ci>x</ci>
#     <apply><times/><cn>&#x2148;<!--DOUBLE-STRUCK ITALIC SMALL I--></cn><ci>y</ci></apply>
#   </apply>
# </apply>
# """
# MathML.parse_str(str)
# @test isequal(MathML.parse_str(str), )

#  lcm
# str = "<apply><lcm/><ci>a</ci><ci>b</ci><ci>c</ci></apply>"
# MathML.parse_str(str)
# @test isequal(MathML.parse_str(str), )

# floor and ceil - RoundingMode
# str = "<apply><floor/><ci>a</ci></apply>"
# MathML.parse_str(str)
# @test isequal(MathML.parse_str(str), )

#  do we actually want it to evaluate, or maybe just return expr
str = "<apply><gt/><cn>3</cn><cn>2</cn></apply>"
@test isequal(MathML.parse_str(str), true)

#  
str = "<apply><lt/><cn>2</cn><cn>3</cn><cn>4</cn></apply>"
@test isequal(MathML.parse_str(str), true)

#  
str = "<apply><exp/><ci>x</ci></apply>"
@test isequal(MathML.parse_str(str), exp(x))

#  
str = "<apply><ln/><ci>x</ci></apply>"
@test isequal(MathML.parse_str(str), log(x))

#  dopee
str = """
<vector>
  <apply><plus/><ci>x</ci><ci>y</ci></apply>
  <cn>3</cn>
  <cn>7</cn>
</vector>
"""
@test isequal(MathML.parse_str(str), [x + y, 3, 7])

str = "<bvar><ci>x</ci></bvar>"
@test isequal(MathML.parse_str(str), (Num(variable(:x)), 1))

str = "<bvar><ci>x</ci><degree><cn>2</cn></degree></bvar>"
@test isequal(MathML.parse_str(str), (Num(variable(:x)), 2))

str = """
<apply><diff/>
  <bvar><ci>x</ci></bvar>
  <apply><sin/><ci>x</ci></apply>
</apply>
"""
@test isequal(expand_derivatives(MathML.parse_str(str)), cos(Num(variable(:x))))

str = """
<apply><diff/>
  <bvar><ci>x</ci><degree><cn>2</cn></degree></bvar>
  <apply><power/><ci>x</ci><cn>4</cn></apply>
</apply>
"""
@test isequal(expand_derivatives(MathML.parse_str(str)), 12 * Num(variable(:x))^2)

# macro test
ml = MathML"""
<apply><diff/>
  <bvar><ci>x</ci><degree><cn>2</cn></degree></bvar>
  <apply><power/><ci>x</ci><cn>4</cn></apply>
</apply>
"""
@test isequal(expand_derivatives(ml), 12 * Num(variable(:x))^2)

str = """
  <lambda>
    <bvar>
      <ci> x </ci>
    </bvar>
    <bvar>
      <ci> y </ci>
    </bvar>
    <apply>
      <power/>
      <ci> x </ci>
      <ci> y </ci>
    </apply>
  </lambda>
"""
f = parse_str(str)
xml = parsexml(str).root
g = parse_lambda(xml)
@test g(3, 5) == f(3, 5) == [243]
@test isequal(f(x, y), [x^y])

# parse_apply with <ci> as firstelement problem
@test_throws KeyError parse_file("data/err.xml")
