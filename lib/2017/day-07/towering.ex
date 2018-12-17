defmodule AoC2017.Day07.Towering do
  use AoC, year: 2017, day: 7

  defmodule ScreamParser do
    import NimbleParsec

    program_name = utf8_string([?A..?z], min: 1) |> unwrap_and_tag(:program)

    towering =
      ignore(string(" -> "))
      |> concat(program_name)
      |> optional(repeat(ignore(string(", ")) |> concat(program_name)))
      |> tag(:towering)

    weight = integer(min: 1) |> unwrap_and_tag(:weight)

    defparsec(
      :scream,
      program_name |> ignore(string(" (")) |> concat(weight) |> ignore(string(")")) |> optional(towering),
      debug: true
    )
  end

  def part_one(file \\ "test.txt") do
    file
    |> stream()
    |> Stream.map(&ScreamParser.scream/1)
    |> Stream.map(&elem(&1, 1))
    |> build_graph()
    |> Graph.arborescence_root()
  end

  def part_two(file \\ "test.txt") do
    g =
      file
      |> stream()
      |> Stream.map(&ScreamParser.scream/1)
      |> Stream.map(&elem(&1, 1))
      |> build_graph()

    weights =
      Graph.Reducers.Dfs.reduce(g, [], fn v, acc ->
        reachable = Graph.reachable(g, [v])
        weight = reachable |> Enum.flat_map(&Graph.vertex_labels(g, &1)) |> Enum.sum()
        {:next, [{v, weight} | acc]}
      end)
      |> Enum.into(%{}, fn {v, _weight} = node -> {v, node} end)

    Graph.Reducers.Dfs.reduce(g, [], fn v, acc ->
      Graph.out_neighbors(g, v)
      |> Enum.map(&Map.get(weights, &1))
      |> outlier_by(fn {_v, weight} -> weight end)
      |> case do
        nil ->
          {:next, acc}

        outlier ->
          {:next, [outlier | acc]}
      end
    end)
    |> case do
      nil ->
        :fuck_off

      [{{wrong_v, wrong_weight}, {_, right_weight}} | _] ->
        [single_weight] = Graph.vertex_labels(g, wrong_v)
        [wrong_v: wrong_v, wrong_weight: wrong_weight, needed: single_weight - (wrong_weight - right_weight)]
      hm ->
        IO.inspect(hm)
    end
  end

  defp outlier_by([], _), do: nil
  defp outlier_by([_], _), do: nil
  defp outlier_by([_, _], _), do: nil

  defp outlier_by(list, fun) do
    Enum.reduce(list, %{}, fn item, acc ->
      val = fun.(item)
      Map.update(acc, val, {1, item}, fn {x, item} -> {x + 1, item} end)
    end)
    |> Enum.min_max_by(fn {_, {times, _}} -> times end)
    |> case do
      {{_, {1, min_item}}, {_, {x, max_item}}} when x != 1 ->
        {min_item, max_item}

      _ ->
        nil
    end
  end

  defp build_graph(screams) do
    screams
    |> Enum.reduce(Graph.new(), fn scream, graph ->
      program = Keyword.get(scream, :program)
      weight = Keyword.get(scream, :weight)
      towering = Keyword.get(scream, :towering, []) |> Keyword.get_values(:program)

      graph = Graph.add_vertex(graph, program)
      graph = Graph.label_vertex(graph, program, [weight])
      Enum.reduce(towering, graph, fn other, graph -> Graph.add_edge(graph, program, other) end)
    end)
  end
end
