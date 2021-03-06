defmodule DeckTest do
  use ExUnit.Case

  test "By default, a deck comes ordered in a predictable way" do
    assert Deck.new() == Deck.new()
  end

  test "A deck can be shuffled in an unpredictable way" do
    # Per https://en.wikipedia.org/wiki/Shuffling#Randomization, this test will shuffle two ordered decks and then verify the resultant decks are not identical.
    refute Deck.shuffle(Deck.new()) == Deck.shuffle(Deck.new())
  end

  test "Creates a deck with 52 unique cards" do
    deck = Deck.new()
    assert Enum.count(Enum.uniq(deck)) == 52
  end

  test "The color of a card is determined by its suit" do
    suits_and_colors = [
      club: :black,
      diamond: :red,
      heart: :red,
      spade: :black
    ]

    deck = Deck.new()

    Enum.each(deck, fn {_rank, suit} = card ->
      assert Deck.Card.color(card) == Keyword.get(suits_and_colors, suit)
    end)
  end

  test "A deck has thirteen unique cards of each of four suits" do
    deck = Deck.new()

    suits = Enum.map(deck, fn {_rank, suit} -> suit end) |> Enum.uniq()
    assert Enum.count(suits) == 4

    Enum.each(suits, fn suit ->
      unique_cards_of_suit =
        Enum.filter(deck, fn {_rank, suit_of_card} -> suit == suit_of_card end) |> Enum.uniq()

      assert Enum.count(unique_cards_of_suit) == 13
    end)
  end

  test "A collection of cards will be notated by suit and rank" do
    cards = Deck.new() |> Enum.take_random(:rand.uniform(52))
    notation_string = Deck.to_notation(cards)
    notation_list = String.split(notation_string)

    assert Enum.count(cards) == Enum.count(notation_list)

    Enum.each(cards, fn card ->
      assert Deck.to_notation([card]) in notation_list
    end)
  end

  test "Creates decks of more than one standard deck" do
    multiples = :rand.uniform(10)
    standard_deck = Deck.new()
    decks = Deck.new(multiples)

    Enum.each(0..(multiples - 1), fn index ->
      {_, d} = Enum.split(decks, index * Enum.count(standard_deck))
      assert Enum.take(d, Enum.count(standard_deck)) == standard_deck
    end)
  end

  test "Deals a given number of hands of a given number of cards from a deck" do
    deck = Deck.new()
    count_hands = :rand.uniform(5)
    count_cards = :rand.uniform(10)
    {:ok, hands, deck} = Deck.deal(deck, count_hands, count_cards)
    assert Enum.count(hands) == count_hands

    Enum.each(hands, fn hand ->
      assert Enum.count(hand) == count_cards
    end)

    assert Enum.count(deck) == 52 - count_hands * count_cards
  end

  test "When asked to deal more cards than available, returns a warning, the hands as dealt, and the original deck" do
    deck = Deck.new()
    count_hands = :rand.uniform(3) + 2
    count_cards = 18
    {:insufficient_deck, hands, returned_deck} = Deck.deal(deck, count_hands, count_cards)
    assert returned_deck == deck

    assert Enum.count(hands) == count_hands

    refute Enum.map(hands, fn hand ->
             Enum.count(hand) == count_cards
           end)
           |> Enum.all?()
  end
end
