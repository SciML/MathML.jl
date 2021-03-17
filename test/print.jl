xml = readxml("data/math.xml").root

open("tree.txt", "w") do io
    print_tree(io, xml)
end;

str = """
math
└─ apply
   ├─ times
   ├─ ci
   ├─ ci
   └─ ci
"""
@test read("tree.txt", String) == str

rm("tree.txt")
