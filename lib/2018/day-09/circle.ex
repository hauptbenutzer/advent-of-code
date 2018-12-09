defmodule AoC2018.Day08.Circle do
  use AoC, year: 2018, day: 8


  @doc """
  iex>part_one(425, 70848)
  413188
  iex>part_one(425, 7084800)
  3377272893
  """

  def part_one(players, last_marble) do
    circle = :digraph.new()
    :digraph.add_vertex(circle, 0)
    :digraph.add_edge(circle, 0, 0)

    1..last_marble
    |> Stream.zip(1..players |> Enum.to_list() |> Stream.cycle())
    |> Enum.reduce({%{}, 0}, &place_marble(&1, &2, circle))
    |> elem(0)
    |> Enum.into(%{}, fn {player, score} -> {player, Enum.sum(score)} end)
    |> Enum.max_by(fn {_player, score} -> score end)
  end

  defp place_marble({marble, player}, {acc, current}, circle) when rem(marble, 23) == 0 do
    :digraph.add_vertex(circle, marble)

    {removed, next_current} = remove_nth_predecessor(circle, current, 7)

    total_score = removed + marble
    {Map.update(acc, player, [total_score], fn score -> [total_score | score] end), next_current}
  end

  defp place_marble({marble, _player}, {acc, current}, circle) do
    :digraph.add_vertex(circle, marble)
    [next] = :digraph.out_neighbours(circle, current)
    [after_next] = :digraph.out_neighbours(circle, next)

    :digraph.del_path(circle, next, after_next)
    :digraph.add_edge(circle, next, marble)
    :digraph.add_edge(circle, marble, after_next)

    {acc, marble}
  end

  defp remove_nth_predecessor(circle, current, n) do
    pred = nth_predecessor(circle, current, n - 1)
    target = nth_predecessor(circle, pred, 1)
    prev_pred = nth_predecessor(circle, target, 1)

    :digraph.del_vertex(circle, target)
    :digraph.add_edge(circle, prev_pred, pred)

    {target, pred}
  end

  defp nth_predecessor(_circle, current, 0) do
    current
  end

  defp nth_predecessor(circle, current, n) do
    [prev] = :digraph.in_neighbours(circle, current)
    nth_predecessor(circle, prev, n - 1)
  end
end
