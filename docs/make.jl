using Documenter, MathML

makedocs(sitename = "My Documentation")

deploydocs(
    repo = "github.com/anandijain/MathML.jl.git",
    devbranch = "main"
)
