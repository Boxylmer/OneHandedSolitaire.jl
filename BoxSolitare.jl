include("Card.jl")

struct BoxSolitareGame
    deck::Vector{Card}
    hand::Vector{Card}
    discard::Vector{Card}
    current_cycle::Vector{Int32}
    n_cycles::Int32
    state_history::Set{UInt64}
    shuffle_deck_on_cycle::Bool
end

BoxSolitareGame(deck, hand, discard; n_cycles=1, shuffle_deck_on_cycle=false) = BoxSolitareGame(deck, hand, discard, Int32[1], n_cycles, Set{UInt64}(), shuffle_deck_on_cycle)

"Get a copy of the game with no state history and a reset cycle counter."
copy_card_state(game::BoxSolitareGame) = BoxSolitareGame(game.deck, game.hand, game.discard, n_cycles=game.n_cycles, shuffle_deck_on_cycle = game.shuffle_deck_on_cycle)

function BoxSolitareGame(; kwargs...)
    deck = shuffleddeck()
    hand = Vector{Card}()
    discard = Vector{Card}()
    return BoxSolitareGame(deck, hand, discard; kwargs...)
end


function recordstate!(game::BoxSolitareGame)
    push!(game.state_history, deckhash(game.discard, game.hand))
end

"Checks if the game is in a permanent state cycle without winning."
function cyclicstate(game::BoxSolitareGame)
    if (deckhash(game.discard, game.hand) in game.state_history) && !isgamewon(game) && !isgameexhausted(game)
        return true
    else
        return false
    end
end

function determine_cycle_period!(game::BoxSolitareGame; maxcheck=100)

    if game.shuffle_deck_on_cycle
        throw(ErrorException("States not recorded when shuffling on cycle"))
    end

    cycle_period = 0
    gameresult(game) # force a resolution to the game
    if cyclicstate(game)
        game_copy = BoxSolitareGame(game.deck, game.hand, game.discard, n_cycles=maxcheck + 1, shuffle_deck_on_cycle = game.shuffle_deck_on_cycle)
        onecycle!(game_copy) # make sure at least one state is loaded
        cycle_period = 1
        for _ in 1:maxcheck
            onecycle!(game_copy)
            cycle_period = cycle_period + 1
            if isgamecycling(game_copy)
                break
            end
        end
    end
    return cycle_period
end

"Checks if the game was won."
function isgamewon(game::BoxSolitareGame)
    if length(game.deck) == 0 && length(game.hand) == 0
        return true
    else
        return false
    end
end

# checks for game end conditions
"Checks if the game has completed the last possible cycle without winning."
ismaxcycleshit(game::BoxSolitareGame) = length(game.deck) == 0 && length(game.hand) > 0 && game.current_cycle[1] == game.n_cycles
"Checks if the hand contains all cards in the game."
isgameexhausted(game::BoxSolitareGame) = length(game.deck) == 0 && length(game.discard) == 0 
"Checks if the game reached a previously seen state."
isgamecycling(game::BoxSolitareGame) = cyclicstate(game)

handsize(game::BoxSolitareGame) = length(game.hand)

"Checks if the game was lost. "
function isgamelost(game::BoxSolitareGame)
    if ismaxcycleshit(game)
        # println("MAX CYCLES HIT (", game.current_cycle[1], ")")
        return true
    # check for an early kill conditions
    elseif isgameexhausted(game)
        # println("EARLY CUTOFF POSSIBLE ON CYCLE ", game.current_cycle[1])
        return true 
    elseif isgamecycling(game)  # has this state been seen before?
        # println("GAME ENTERED A CYCLIC STATE STARTING ON CYCLE ", game.current_cycle[1])
        return true
    else
        return false
    end
end


"Progresses the game to completion. Returns false if the game was lost, returns true if the game was won."
function gameresult(game::BoxSolitareGame)
    while !(isgamewon(game) || isgamelost(game))
        onecycle!(game)
    end
    return isgamewon(game)
end

"Returns true if drawing succeeded, returns false if the deck is empty."
function draw!(game::BoxSolitareGame)
    if length(game.deck) == 0
        return false
    else
        card = popfirst!(game.deck)
        pushfirst!(game.hand, card)
        return true
    end
end

"Returns true if cards were removed from the hand, otherwise returns false."
function checkhand!(game::BoxSolitareGame)
    if length(game.hand) < 4
        return false
    elseif samesuit(game.hand[1], game.hand[4])
        # println("Same suit found! ", game.hand[1], " & ", game.hand[4])
        push!(game.discard, popat!(game.hand, 2))
        push!(game.discard, popat!(game.hand, 2)) # since we just deleted the second card down, the third one is now the second card down
        return true
    elseif samevalue(game.hand[1], game.hand[4])
        # println("Same value found! ", game.hand[1], " & ", game.hand[4])
        for _ in 1:4
            push!(game.discard, popfirst!(game.hand))
        end
        return true
    else
        return false
    end
end

"Completes one turn of the game, returns true if the game progressed. Returns false if the deck was empty."
function oneturn!(game::BoxSolitareGame)
    if draw!(game)
        # println("Drew: ", game.hand[1])
        while checkhand!(game)
            # println(game.hand)
        end
        return true

    else
        return false
    end
end

"Progresses the game to the end of a cycle."
function onecycle!(game::BoxSolitareGame)  
    if length(game.deck) == 0 && game.current_cycle[1] < game.n_cycles && !isgamewon(game)
        if !game.shuffle_deck_on_cycle
            recordstate!(game)
        end    
        game.current_cycle[1] += 1
        while length(game.discard) > 0
            push!(game.deck, popfirst!(game.discard))
        end
        if game.shuffle_deck_on_cycle
            shuffledeck!(game.deck)
        end
        # empty!(game.discard)
    end
    while oneturn!(game) 
    end
end

"Returns true if the game won, false if it lost."
playonegame(; kwargs...) = gameresult(BoxSolitareGame(; kwargs...))

"Returns a completed game."
function completedgame(; kwargs...)
    game = BoxSolitareGame(; kwargs...)
    gameresult(game)
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



