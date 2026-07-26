using MathML, Symbolics, Test

ex = :(1 + 2 + x + y * z * num^4)
io = IOBuffer()
print(io, to_MathML(ex))
str = String(take!(io))
@test str ==
    "<apply><cn>1</cn><cn>2</cn><ci>x</ci><apply><ci>y</ci><ci>z</ci><apply><ci>num</ci><cn>4</cn></apply></apply></apply>"

@variables x
io = IOBuffer()
print(io, to_MathML(x + 2))
@test String(take!(io)) == "<apply><cn>2</cn><ci>x</ci></apply>"
