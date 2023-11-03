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
        another_game = OneHandedSolitaire.copy_card_state(game)
        @test !(game.hand === another_game.hand)


        
    end

    @testset "BoxSolitaireActions.jl" begin
        
    end
end
