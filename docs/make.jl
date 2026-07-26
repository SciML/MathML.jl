using Documenter, MathML

DocMeta.setdocmeta!(MathML, :DocTestSetup, :(using MathML, EzXML); recursive = true)

makedocs(
    sitename = "MathML.jl",
    modules = [MathML],
    checkdocs = :exports,
    doctest = true,
    pages = ["Home" => "index.md", "API" => "api.md"],
)

deploydocs(
    repo = "github.com/SciML/MathML.jl.git",
    devbranch = "main"
)
