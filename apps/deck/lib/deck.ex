defmodule Deck do
  @moduledoc """
  Creates decks of cards and provides functions that can be performed on one or more decks.
  """

  @type suit :: atom()
  @type rank :: atom()
  @type card :: {rank, suit}
  @type cards :: list(card)
  @type deck :: cards

  @suits_and_notations [
    club: "♣",
    diamond: "♦",
    heart: "♥",
    spade: "♠"
  ]

  @suits Keyword.keys(@suits_and_notations)

  @ranks_and_notations [
    ace: "A",
    two: "2",
    three: "3",
    four: "4",
    five: "5",
    six: "6",
    seven: "7",
    eight: "8",
    nine: "9",
    ten: "10",
    jack: "J",
    queen: "Q",
    king: "K"
  ]

  @ranks Keyword.keys(@ranks_and_notations)

  @deck for suit <- @suits, rank <- @ranks, do: {rank, suit}

  defmodule Card do
    @moduledoc ""
    alias CardGames.Deck
    @type card :: Deck.card()

    @suits_and_colors club: :black,
                      diamond: :red,
                      heart: :red,
                      spade: :black

    @spec color({atom(), atom()}) :: :black | :red
    def color({_rank, suit}) do
      Keyword.get(@suits_and_colors, suit)
    end
  end

  @spec new() :: deck
  def new(), do: @deck

  @spec new(integer()) :: deck
  def new(multiple) when is_integer(multiple) and multiple > 0 do
    for _ <- 1..multiple, card <- @deck, do: card
  end

  @spec shuffle(deck) :: deck
  def shuffle(deck), do: Enum.shuffle(deck)

  @spec deal(deck, integer, integer) :: {:ok, list(cards), cards}
  def deal(deck, count_hands, count_cards) do
    acc = {for(_hand <- 1..count_hands, do: []), deck}

    {hands, deck_remaining} =
      Enum.reduce(1..count_cards, acc, fn _, {hands, deck} ->
        Enum.reduce(hands, {[], deck}, fn hand, {round, deck} ->
          {deck, card} = draw_one(deck)
          {round ++ [hand ++ [card]], deck}
        end)
      end)

    with false <- Enum.any?(List.flatten(hands), fn card -> is_nil(card) end) do
      {:ok, hands, deck_remaining}
    else
      _ ->
        dealt = Enum.map(hands, fn hand -> Enum.filter(hand, fn card -> not is_nil(card) end) end)
        {:insufficient_deck, dealt, deck}
    end
  end

  @spec to_notation(list(cards)) :: binary()
  def to_notation(cards), do: to_notation(:string, cards)

  @spec to_notation(:string, list(cards)) :: binary()
  def to_notation(:string, cards) do
    Enum.map(cards, fn {rank, suit} ->
      Keyword.get(@suits_and_notations, suit) <> Keyword.get(@ranks_and_notations, rank)
    end)
    |> Enum.join(" ")
  end

  @spec draw_one(cards) :: {cards, card | nil}
  def draw_one([]), do: {[], nil}

  def draw_one([card | cards]) when is_list(cards) do
    {cards, card}
  end
end
