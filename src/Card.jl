using Random

@enum SUIT begin 
    Joker = 0
    Hearts = 1 
    Clubs = 2
    Diamonds = 3
    Spades = 4
end 

struct Card
    suit::SUIT
    value::Int32
end

function Base.show(io::IO, c::Card)
    if c.suit == Hearts
        suitstr = "of Hearts"
    elseif c.suit == Clubs
        suitstr = "of Clubs"
    elseif c.suit == Diamonds
        suitstr = "of Diamonds"
    elseif c.suit == Spades
        suitstr = "of Spades"
    else
        suitstr = ""
    end

    if c.value == 1
        valstr = "Ace"
    elseif c.value == 2
        valstr = "Two"
    elseif c.value == 3
        valstr = "Three"
    elseif c.value == 4
        valstr = "Four"
    elseif c.value == 5
        valstr = "Five"
    elseif c.value == 6
        valstr = "Six"
    elseif c.value == 7
        valstr = "Seven"
    elseif c.value == 8
        valstr = "Eight"
    elseif c.value == 9
        valstr = "Nine"
    elseif c.value == 10
        valstr = "Ten"
    elseif c.value == 11
        valstr = "Jack"
    elseif c.value == 12
        valstr = "Queen"
    elseif c.value == 13
        valstr = "King"
    else 
        valstr = "Joker"
    end
    print(io, valstr * " " * suitstr)

end

function isblack(card::Card)
    if card.suit == Clubs || card.suit == Spades 
        return true 
    else 
        return false
    end
end

isred(card::Card) = !isblack(card)

samesuit(card1::Card, card2::Card ) = card1.suit == card2.suit 
samevalue(card1::Card, card2::Card ) = card1.value == card2.value 

function makecard(value::Integer; hasjokers=false)
    if !hasjokers
        cardval = mod(value, 13)
        if cardval == 0 # mod(13, 13) is 0, but mod
            cardval = 13
        end
        suitval = Int32(floor((value - 1) / 13 + 1)) 
        return Card(SUIT(suitval), cardval)
    else
        throw(ErrorException("Not implemented"))
    end
end

function shuffleddeck(hasjokers=false)
    deck = Vector{Card}(undef, 52)
    for i in eachindex(deck)
        deck[i] = makecard(i)
    end
    return shuffle(deck)
end

function shuffledeck!(deck::Vector{Card})
    shuffle!(deck)
end

deckhash(a::Vector{Card}) = hash(a)
deckhash(a...) = hash(diff([hash(ai) for ai in a]))

