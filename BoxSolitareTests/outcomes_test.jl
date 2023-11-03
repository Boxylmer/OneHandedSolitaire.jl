include("../BoxSolitaire.jl")
using Plots


function generate_outcome_figure(ngames = 100, cycles = collect(1:5); simulation_kwargs...)
    winrate_after_ncycles = []
    lossrate_by_maxcycles_after_ncycles = []
    lossrate_by_exhaustion_after_ncycles = []
    lossrate_by_cycling_after_ncycles = []
    for nci in cycles
        res = simulatengameswithresults(ngames; n_cycles = nci, simulation_kwargs...)
        push!(winrate_after_ncycles, res[1])
        push!(lossrate_by_maxcycles_after_ncycles, res[2])
        push!(lossrate_by_exhaustion_after_ncycles, res[3])
        push!(lossrate_by_cycling_after_ncycles, res[4])
        
        println(
            winrate_after_ncycles[end], ", ", 
            lossrate_by_maxcycles_after_ncycles[end], ", ", 
            lossrate_by_exhaustion_after_ncycles[end], ", ", 
            lossrate_by_cycling_after_ncycles[end], ", ",
        sum(res))
    end
    myplot = plot(cycles, winrate_after_ncycles, label="Win")
    plot!(myplot, cycles, lossrate_by_maxcycles_after_ncycles, label="Loss by maxcycles")
    plot!(myplot, cycles, lossrate_by_exhaustion_after_ncycles, label="Loss by exhaustion")
    plot!(myplot, cycles, lossrate_by_cycling_after_ncycles, label="Loss by cycling")
    return myplot
end

function generate_outcome_comparison_figure()
    ngames = 20000
    cycles = collect(1:1:200)
    fig_no_shuffle = generate_outcome_figure(ngames, cycles;)
    fig_with_shuffle = generate_outcome_figure(ngames, cycles; shuffle_deck_on_cycle=true)
    plot!(fig_no_shuffle, title="No shuffling")
    plot!(fig_with_shuffle, title="With shuffling")
    final_plot = plot(fig_no_shuffle, fig_with_shuffle)
    savefig(final_plot, "outcomes_test.png")
end


function generate_hand_state_tracking_figure(maxcycles=100; cyclestep=1, ngames=10, shuffle=false, return_games=false)
    resplot = plot(xlabel="Cycle", ylabel="Hand size", legend=nothing)
    cycles = collect(1:cyclestep:maxcycles)
    hand_sizes = zeros(Int32, length(cycles))
    games = [BoxSolitaireGame(; shuffle_deck_on_cycle=shuffle, n_cycles=maxcycles) for _ in 1:ngames]

    for gameidx in eachindex(games)
        for cycle_i in eachindex(cycles)
            if !(handsize(games[gameidx]) == 52)
                for _ in 1:cyclestep
                    onecycle!(games[gameidx])
                end
            end
            hand_sizes[cycle_i] = handsize(games[gameidx])
        end
        plot!(resplot, cycles, hand_sizes, size=(4000, 1000))
    end

    if return_games
        return resplot, games
    else
        return resplot
    end
end

plt, games = generate_hand_state_tracking_figure(100; cyclestep=1, ngames=100, return_games=true)
for (gameidx, game) in enumerate(games)
    if isgamecycling(game)
        period = determine_cycle_period!(game)
        println(gameidx, " is cycling! (", period, ")")
    end
end
plt


function games_won_by_cycle(samplesize=300000, maxcycles=25)
    wincyclecounter = Vector{Union{Int64, Missing}}(undef, samplesize)
    @Threads.threads for i in eachindex(wincyclecounter)
        game = BoxSolitaireGame(; n_cycles=maxcycles)
        ncycles = 0
        while !isgamewon(game) && !isgamelost(game)
            onecycle!(game)
            ncycles = ncycles + 1
        end
        if isgamewon(game)
            wincyclecounter[i] = ncycles
        else
            wincyclecounter[i] = missing
        end
    end
    return wincyclecounter
end

hist = games_won_by_cycle()
histogram(hist, bins=25)


