defmodule WarTest do
  use ExUnit.Case

  test "Player wins when opponent has no cards" do
    {_, card} = Deck.new() |> Deck.draw_one()
    {winner, winning_hand} = Enum.random([{:player1_wins, :hand1}, {:player2_wins, :hand2}])
    s = struct!(War, %{winning_hand => [card]})
    assert War.tick(s) == winner
  end

  test "The player with the higher card wins a round" do
    s = %War{hand1: [{:three, :club}], hand2: [{:two, :club}]}
    assert War.tick(s) == :player1_wins
  end

  test "When the top cards are equal, the player with the higher card second down in their deck wins a round" do
    s = %War{
      hand1: [{:ace, :heart}, {:ace, :spade}, {:three, :club}],
      hand2: [{:ace, :club}, {:ace, :diamond}, {:two, :club}]
    }

    assert War.tick(s) == :player1_wins
  end
end
