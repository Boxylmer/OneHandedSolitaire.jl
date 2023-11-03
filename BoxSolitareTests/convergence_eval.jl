include("BoxSolitare.jl")
using Plots

function n_more_games!(total_games::AbstractVector, total_winrates::AbstractVector, n=1; kwargs...)
    new_games_winrate = simulatengames(n; kwargs...)
    # println(new_games_winrate)
    if length(total_games) == 0
        new_cumulative_games_played = n
        new_cumulative_winrate = new_games_winrate
        # println(new_cumulative_winrate, ", ", new_cumulative_games_played)
    else
        previous_games_played = total_games[end]
        previous_winrate = total_winrates[end]

        new_cumulative_games_played = n + previous_games_played

        # @show previous_winrate
        new_cumulative_winrate = (previous_winrate * previous_games_played + new_games_winrate * n) / new_cumulative_games_played
        println(new_cumulative_winrate, ", ", new_cumulative_games_played)
    end
    push!(total_games, new_cumulative_games_played)
    push!(total_winrates, new_cumulative_winrate)
end

total_games = Vector{Int64}()
total_games_2 = Vector{Int64}()
total_games_5 = Vector{Int64}()
total_winrates_1_cycle = Vector{Float64}()
total_winrates_2_cycle = Vector{Float64}()
total_winrates_5_cycle = Vector{Float64}()
for i in 1:100
        n_more_games!(total_games, total_winrates_1_cycle, 1000; n_cycles=1)
        n_more_games!(total_games_2, total_winrates_2_cycle, 1000; n_cycles=2)
        n_more_games!(total_games_5, total_winrates_5_cycle, 1000; n_cycles=5)
end
myplot = plot()
plot!(myplot, total_games, total_winrates_1_cycle.*100)
plot!(myplot, total_games_2, total_winrates_2_cycle.*100)

plot!(myplot, total_games_5, total_winrates_5_cycle.*100)

# total_winrates_5_cycle[end] / total_winrates_1_cycle[end]



