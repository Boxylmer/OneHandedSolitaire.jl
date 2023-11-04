module OneHandedSolitaire

include("Card.jl")
export makecard
export isblack, isred, samesuit, samevalue
export shuffleddeck, shuffledeck!, deckhash

include("BoxSolitaireGame.jl")
export BoxSolitaireGame

export cyclicstate, determine_cycle_period!
export isgamewon, isgamelost, ismaxcycleshit, isgameexhausted, isgamecycling
export handsize, gameresult!
export draw!, checkhand!, oneturn!, onecycle!

include("BoxSolitaireActions.jl")
export playonegame, completedgame, simulatengames, simulatengameswithresults

end