using OneHandedSolitaire
using Test

@testset "OneHandedSolitaire.jl" begin
    @testset "Card.jl" begin
        all_strings = Vector{String}(undef, 52)
        for i in eachindex(all_strings)
            all_strings[i] = string(makecard(i))
        end

        @test all_strings[3] == "Three of Hearts"

        four_of_hearts = makecard(4)
        four_of_clubs = makecard(17)
        @test !isblack(four_of_hearts)
        @test isred(four_of_hearts)
        @test isblack(four_of_clubs)

        @test !samesuit(four_of_clubs, four_of_hearts)
        @test samevalue(four_of_clubs, four_of_hearts)

        jokercard = OneHandedSolitaire.Card(OneHandedSolitaire.SUIT(0), 0)
        @test string(jokercard) == "Joker"

        mydeck = shuffleddeck()
        anotherdeck = shuffleddeck()
        @test deckhash(mydeck) != deckhash(anotherdeck)

        shuffled = shuffledeck!(copy(mydeck))
        @test shuffled != mydeck


        @test_throws ErrorException makecard(3; hasjokers=true)
    end

    @testset "BoxSolitaireGame.jl" begin
        game = BoxSolitaireGame()
        @test !isgamelost(game)
        @test !isgamewon(game)

        another_game = OneHandedSolitaire.copy_card_state(game)
        @test !(game.hand === another_game.hand)

        @test !cyclicstate(game)
        
        @test determine_cycle_period!(game) == 0

        games_with_cycles = [BoxSolitaireGame(n_cycles=100) for _ in 1:10000]
        determine_cycle_period!.(games_with_cycles)
        n_cyclic_games = sum(isgamecycling.(games_with_cycles))
        n_exhausted_games = sum(isgameexhausted.(games_with_cycles))
        n_cycled_out_games = sum(ismaxcycleshit.(games_with_cycles))
        n_games_won = sum(isgamewon.(games_with_cycles))
        n_games_lost = sum(isgamelost.(games_with_cycles))
        @test n_cyclic_games > 0

        @test n_games_lost + n_games_won == length(games_with_cycles)

        n_both = 0
        for game in games_with_cycles
            if ismaxcycleshit(game) && isgamecycling(game)
                n_both += 1
            end
            if isgameexhausted(game) && ismaxcycleshit(game)
                n_both += 1
            end
        end
        @test n_cyclic_games + n_exhausted_games + n_cycled_out_games - n_both == n_games_lost 
    
    end

    @testset "BoxSolitaireActions.jl" begin
        
    end
end
