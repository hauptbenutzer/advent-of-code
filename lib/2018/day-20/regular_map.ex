defmodule AoC2018.Day20.RegularMap do
  use AoC, year: 2018, day: 20

  defmodule RegexParser do
    import NimbleParsec

    direction = choice([string("N"), string("E"), string("W"), string("S")]) |> map({String, :to_atom, []})

    defparsec(
      :group,
      ignore(string("("))
      |> parsec(:rule)
      |> optional(repeat(ignore(string("|")) |> parsec(:rule)))
      |> ignore(string(")"))
      |> tag(:group)
    )

    defparsec(:rule, repeat(choice([parsec(:group), direction])) |> tag(:rule))

    defparsec(
      :map,
      ignore(string("^"))
      |> parsec(:rule)
      |> ignore(string("$"))
    )
  end

  def part_one(input) do
    {graph, _} =
      input
      |> RegexParser.map()
      |> elem(1)
      |> Keyword.get(:rule)
      |> build_graph(Graph.new(), {0, 0})

    # target =
    #   graph
    #   |> Graph.vertices()
    #   |> Enum.max_by(fn vertex ->
    #     (Graph.get_shortest_path(graph, {0, 0}, vertex) || [])
    #     |> Enum.count()
    #   end)
    #
    # (Graph.get_shortest_path(graph, {0, 0}, target) |> Enum.count()) - 1
  end

  def build_graph(input, graph, {x, y}) do
    sane_reduce_while(input, {graph, {x, y}}, fn
      dir, {graph, {x, y}}, _rest when dir in ~w(N E W S)a ->
        coord = coord_for_dir({x, y}, dir)
        graph = Graph.add_edge(graph, {x, y}, coord)
        {:cont, {graph, coord}}

      {:group, rules}, {graph, coord}, rest ->
        {graph, _coord} =
          rules
          |> Keyword.get_values(:rule)
          |> Enum.reduce({graph, coord}, fn rule, {graph, _coord} -> build_graph(rule ++ rest, graph, coord) end)

        {:halt, {graph, coord}}
    end)
  end

  defp sane_reduce_while(list, acc, reducer)
  defp sane_reduce_while([], {op, acc}, _) when op in ~w(halt cont)a, do: acc
  defp sane_reduce_while([], acc, _), do: acc
  defp sane_reduce_while(_list, {:halt, acc}, _reducer), do: acc
  defp sane_reduce_while(list, {:cont, acc}, reducer), do: sane_reduce_while(list, acc, reducer)
  defp sane_reduce_while([head | tail], acc, reducer), do: sane_reduce_while(tail, reducer.(head, acc, tail), reducer)

  defp coord_for_dir({x, y}, :W), do: {x - 1, y}
  defp coord_for_dir({x, y}, :E), do: {x + 1, y}
  defp coord_for_dir({x, y}, :N), do: {x, y + 1}
  defp coord_for_dir({x, y}, :S), do: {x, y - 1}
end
