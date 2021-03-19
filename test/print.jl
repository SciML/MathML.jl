xml = readxml("data/math.xml").root

io = IOBuffer()
print_tree(io, xml)
ser = String(take!(io))
str = """
math
└─ apply
   ├─ times
   ├─ ci
   ├─ ci
   └─ ci
"""
@test strip(ser) == strip(str)
