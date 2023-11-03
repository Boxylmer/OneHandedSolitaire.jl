using OneHandedSolitaire
using Documenter

DocMeta.setdocmeta!(OneHandedSolitaire, :DocTestSetup, :(using OneHandedSolitaire); recursive=true)

makedocs(;
    modules=[OneHandedSolitaire],
    authors="Will <william.joseph.box@gmail.com> and contributors",
    repo="https://github.com/Boxylmer/OneHandedSolitaire.jl/blob/{commit}{path}#{line}",
    sitename="OneHandedSolitaire.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Boxylmer.github.io/OneHandedSolitaire.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Boxylmer/OneHandedSolitaire.jl",
    devbranch="master",
)
