defmodule CardGames.DeckTest do
  use ExUnit.Case
  alias CardGames.Deck

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
end
