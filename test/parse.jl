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

@variables x y z

str = "<apply><compose/><ci>x</ci><ci>y</ci><ci>z</ci></apply>"
@test isequal(MathML.parse_str(str), x ∘ y ∘ z)

# heaviside and nesting test
# str = """
# <piecewise>
#   <piece>
#     <apply><minus/><ci>x</ci></apply>
#     <apply><lt/><ci>x</ci><cn>0</cn></apply>
#   </piece>
#   <piece>
#     <cn>0</cn>
#     <apply><eq/><ci>x</ci><cn>0</cn></apply>
#   </piece>
#   <piece>
#     <ci>x</ci>
#     <apply><gt/><ci>x</ci><cn>0</cn></apply>
#   </piece>
# </piecewise>
# """

# quotient RoundingMode issue
# str = "<apply><quotient/><ci>a</ci><ci>b</ci></apply>"
# MathML.parse_str(str)

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
@test isequal(MathML.parse_str(str), x/y)

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
@test isequal(MathML.parse_str(str), x-y)

#  
str = "<apply><plus/><ci>x</ci><ci>y</ci><ci>z</ci></apply>"
@test isequal(MathML.parse_str(str), x+y+z)

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

