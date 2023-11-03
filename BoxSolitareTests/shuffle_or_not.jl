include("../BoxSolitaire.jl")
using Plots

cycles = collect(1:1:20)
ngames = 50000

winrates_after_n = []
for nci in cycles
    push!(winrates_after_n, simulatengames(ngames; n_cycles = nci))
    println(winrates_after_n[end])
end

winrates_after_n_shuffled = []
for nci in cycles
    push!(winrates_after_n_shuffled, simulatengames(ngames; n_cycles = nci, shuffle_deck_on_cycle=true))
    println(winrates_after_n_shuffled[end])
end

myplot = plot(cycles, winrates_after_n)
plot!(myplot, cycles, winrates_after_n_shuffled)