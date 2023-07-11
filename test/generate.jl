ex = :(1+2+x+y*z*num^4)
str =  print(symbol_to_MathML(ex))
@test str == "<apply><cn>1</cn><cn>2</cn><ci>x</ci><apply><ci>y</ci><ci>z</ci><apply><ci>num</ci><cn>4</cn></apply></apply></apply>"
