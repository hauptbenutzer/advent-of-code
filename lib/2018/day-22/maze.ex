defmodule AoC2018.Day22.Maze do
  use AoC, year: 2018, day: 22

  def part_one(depth, {x, y} = target) do
    0..y
    |> Stream.flat_map(fn y -> 0..x |> Stream.map(fn x -> {x, y} end) end)
    |> Enum.reduce(%{}, fn coord, grid ->
      {_, grid} = mark_field(coord, depth, target, grid)

      grid
    end)
    |> Enum.reduce(0, fn {_coord, val}, acc ->
      acc + rem(val, 3)
    end)
  end

  @tools ~w(torch gear neither)a
  @tool_pairs for a <- @tools, b <- @tools, a != b, do: {a, b}

  @adjacent [{0, -1}, {1, 0}, {0, 1}, {-1, 0}]
  def part_two(depth, {x, y} = target) do
    coords =
      0..(y + 50)
      |> Stream.flat_map(fn y -> 0..(x + 50) |> Stream.map(fn x -> {x, y} end) end)

    grid =
      coords
      |> Enum.reduce(%{}, fn coord, grid ->
        {_, grid} = mark_field(coord, depth, target, grid)

        grid
      end)

    graph =
      coords
      |> Enum.reduce(Graph.new(), fn {x, y} = coord, graph ->
        val = rem(Map.get(grid, coord), 3)

        Enum.reduce(@adjacent, graph, fn {dx, dy}, graph ->
          adjacent_coord = {x + dx, y + dy}

          case Map.get(grid, adjacent_coord) do
            nil ->
              graph

            adjacent_val ->
              adjacent_type = rem(adjacent_val, 3)

              Enum.reduce([:torch, :gear, :neither], graph, fn tool, graph ->
                Enum.reduce(edge_weight(val, adjacent_type, tool), graph, fn {new_tool, weight}, graph ->
                  Graph.add_edge(graph, {tool, coord}, {new_tool, adjacent_coord}, weight: weight)
                end)
              end)
          end
        end)
      end)

    Graph.get_shortest_path(graph, {:torch, {0, 0}}, {:gear, target})
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce(0, fn [v1, v2], acc -> Graph.edge(graph, v1, v2) |> Map.get(:weight) |> Kernel.+(acc) end)
  end

  def edge_weight(from_type, to_type, equip)
  def edge_weight(a, a, equip), do: [{equip, 1}]

  def edge_weight(0, 1, :torch), do: [{:gear, 8}]
  def edge_weight(0, 1, :gear), do: [{:gear, 1}]

  def edge_weight(0, 2, :torch), do: [{:torch, 1}]
  def edge_weight(0, 2, :gear), do: [{:torch, 8}]

  def edge_weight(1, 0, :gear), do: [{:gear, 1}]
  def edge_weight(1, 0, :neither), do: [{:gear, 8}]

  def edge_weight(1, 2, :gear), do: [{:neither, 8}]
  def edge_weight(1, 2, :neither), do: [{:neither, 1}]

  def edge_weight(2, 0, :torch), do: [{:torch, 1}]
  def edge_weight(2, 0, :neither), do: [{:torch, 8}]

  def edge_weight(2, 1, :torch), do: [{:neither, 8}]
  def edge_weight(2, 1, :neither), do: [{:neither, 1}]
  def edge_weight(_, _, _), do: []

  def mark_field({x, y} = coord, depth, target, grid) do
    case grid do
      %{^coord => val} ->
        {val, grid}

      _ ->
        {geologic_index, grid} =
          case {x, y} do
            {0, 0} ->
              {0, grid}

            ^target ->
              {0, grid}

            {x, 0} ->
              {x * 16807, grid}

            {0, y} ->
              {y * 48271, grid}

            {x, y} ->
              {val_1, grid} = mark_field({x - 1, y}, depth, target, grid)
              {val_2, grid} = mark_field({x, y - 1}, depth, target, grid)
              {val_1 * val_2, grid}
          end

        erosion_level = rem(geologic_index + depth, 20183)
        {erosion_level, Map.put(grid, coord, erosion_level)}
    end
  end
end
