"Returns true if the game won, false if it lost."
playonegame(; kwargs...) = gameresult!(BoxSolitaireGame(; kwargs...))

"Returns a completed game."
function completedgame(; kwargs...)
    game = BoxSolitaireGame(; kwargs...)
    gameresult!(game)
    return game
end

function simulatengames(n=50; kwargs...)
    wins = 0 
    losses = 0
    @Threads.threads for _ in 1:n
        if playonegame(; kwargs...)
            wins+=1
        else
            losses+=1
        end
    end
    # println("winrate: ", wins/(wins + losses) * 100, "%")
    return wins / (wins + losses)
end

"Get the results of some games as a tuple."
function simulatengameswithresults(n=50; kwargs...)
    wins = 0 
    losses_by_maxcycles = 0
    losses_by_exhaustion = 0
    losses_by_cycling = 0

    @Threads.threads for _ in 1:n
        game = completedgame(; kwargs...)
        if isgamewon(game)
            wins+=1
        elseif ismaxcycleshit(game)
            losses_by_maxcycles = losses_by_maxcycles + 1
        elseif isgameexhausted(game)
            losses_by_exhaustion = losses_by_exhaustion + 1
        elseif isgamecycling(game)
            losses_by_cycling = losses_by_cycling + 1
        end
    end
    return wins/n, losses_by_maxcycles/n, losses_by_exhaustion/n, losses_by_cycling/n
end