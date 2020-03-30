defmodule War do
  @moduledoc """
  Documentation for `War`.
  """

  require Logger

  @type t :: %__MODULE__{hand1: Deck.cards(), hand2: Deck.cards(), pot: Deck.cards()}
  defstruct hand1: [], hand2: [], pot: []

  @ranks_and_values [
    two: 2,
    three: 3,
    four: 4,
    five: 5,
    six: 6,
    seven: 7,
    eight: 8,
    nine: 9,
    ten: 10,
    jack: 11,
    queen: 12,
    king: 13,
    ace: 14
  ]

  defp value({rank, _suit}), do: Keyword.get(@ranks_and_values, rank, 0)

  @spec war :: :player_1 | :player_2
  def war(decks \\ 1) when is_integer(decks) and decks > 0 do
    {:ok, [hand1, hand2], []} =
      Deck.new(decks)
      |> Deck.shuffle()
      |> Deck.deal(2, 26 * decks)

    state = %__MODULE__{hand1: hand1, hand2: hand2, pot: []}
    tick(state)
  end

  def tick(%__MODULE__{hand2: []}) do
    Logger.info("Player 1 wins")
    :player1_wins
  end

  def tick(%__MODULE__{hand1: []}) do
    Logger.info("Player 2 wins")
    :player2_wins
  end

  def tick(%__MODULE__{hand1: [card1 | _], hand2: [card2 | _]} = state) do
    log(state)

    cond do
      value(card1) > value(card2) ->
        battle_to_p1(state) |> tick()

      value(card2) > value(card1) ->
        battle_to_p2(state) |> tick()

      value(card1) == value(card2) ->
        battle_to_war(state) |> tick()
    end
  end

  def battle_to_p1(%__MODULE__{hand1: [card1 | cards1], hand2: [card2 | cards2], pot: pot}) do
    %__MODULE__{
      hand1: cards1 ++ Enum.shuffle([card1, card2] ++ pot),
      hand2: cards2,
      pot: []
    }
  end

  defp battle_to_p2(%__MODULE__{hand1: [card1 | cards1], hand2: [card2 | cards2], pot: pot}) do
    %__MODULE__{
      hand1: cards1,
      hand2: cards2 ++ Enum.shuffle([card1, card2] ++ pot),
      pot: []
    }
  end

  defp battle_to_war(%__MODULE__{hand1: [card1 | cards1], hand2: [card2 | cards2], pot: pot}) do
    {remaining_hand1, facedown1} = Deck.draw_one(cards1)
    {remaining_hand2, facedown2} = Deck.draw_one(cards2)

    %__MODULE__{
      hand1: remaining_hand1,
      hand2: remaining_hand2,
      pot: [facedown1, facedown2, card1, card2] ++ pot
    }
  end

  defp log(%__MODULE__{hand1: hand1, hand2: hand2}),
    do:
      Logger.info(
        "#{List.first(hand1) |> Deck.to_notation()} (of #{Enum.count(hand1)}) " <>
          "vs #{List.first(hand2) |> Deck.to_notation()} (of #{Enum.count(hand2)})"
      )
end
