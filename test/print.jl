xml = readxml("data/math.xml").root

io = IOBuffer()
print_tree(io, xml)
set = String(take!(io))
str = """
math
└─ apply
   ├─ times
   ├─ ci
   ├─ ci
   └─ ci
"""
@test strip(set) == strip(str)
