defmodule AoC2018.Day18.Lumber do
  use AoC, year: 2018, day: 18

  def part_one(input, gens \\ 10) do
    map = parse_map(input)

    1..gens
    |> Enum.reduce_while({%{}, map}, fn gen, {seen, gen_map} ->
      # if rem(gen, 10_000) == 0, do: IO.puts("Gen #{gen}")
      next_gen_map = Enum.into(gen_map, %{}, fn {coord, cell} -> {coord, transition(coord, cell, gen_map)} end)

      seen_before = Map.get(seen, next_gen_map)

      if seen_before do
        {:halt, {next_gen_map, last_seen: seen_before, now: gen}}
      else
        {:cont, {Map.put(seen, next_gen_map, gen), next_gen_map |> print_grid(gen)}}
      end
    end)
    |> case do
      {gen_map, last_seen: seen_before, now: gen} ->
        loop_size = gen - seen_before
        extra_rounds = rem(gens - seen_before, loop_size)

        IO.puts("Found loop: #{seen_before} - #{gen}. Doing #{extra_rounds} extra rounds ")

        times(extra_rounds)
        |> Enum.reduce(gen_map, fn gen, gen_map ->
          Enum.into(gen_map, %{}, fn {coord, cell} -> {coord, transition(coord, cell, gen_map)} end)
        end)
        |> print_grid(gens)

      {_seen, gen_map} ->
        print_grid(gen_map, gens)
    end

    # |> print_grid(gens)

    :ok
  end

  def transition(coord, field, map) do
    neighbours = count_adjacent(coord, map)

    cond do
      field == :open and neighbours[:trees] >= 3 -> :trees
      field == :trees and neighbours[:lumber] >= 3 -> :lumber
      field == :lumber and neighbours[:lumber] >= 1 and neighbours[:trees] >= 1 -> :lumber
      field == :lumber -> :open
      true -> field
    end
  end

  def times(0), do: []
  def times(n), do: 1..n

  @adjacent for x <- -1..1, y <- -1..1, !(x == 0 and y == 0), do: {x, y}
  def count_adjacent({x, y}, map) do
    @adjacent
    |> Enum.reduce(%{lumber: 0, trees: 0, open: 0, out: 0}, fn {dx, dy}, acc ->
      field = Map.get(map, {x + dx, y + dy}, :out)
      Map.update(acc, field, 1, fn x -> x + 1 end)
    end)
  end

  defp from_symbol("#"), do: :lumber
  defp from_symbol("|"), do: :trees
  defp from_symbol("."), do: :open

  defp to_symbol(:lumber), do: "#"
  defp to_symbol(:trees), do: "|"
  defp to_symbol(:open), do: "."

  def parse_map(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      String.split(line, "", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {cell, x} -> {{x, y}, cell |> from_symbol()} end)
    end)
    |> Enum.into(%{})
  end

  @colors %{
    :open => IO.ANSI.yellow(),
    :lumber => IO.ANSI.red(),
    :trees => IO.ANSI.green()
  }
  def print_grid(map, gen) do
    Process.sleep(20)

    output = [IO.ANSI.clear() <> IO.ANSI.home(), "Generation #{gen} \n"]

    {{{min_x, _}, _}, {{max_x, _}, _}} = Enum.min_max_by(map, fn {{x, _}, _} -> x end)
    {{{_, min_y}, _}, {{_, max_y}, _}} = Enum.min_max_by(map, fn {{_, y}, _} -> y end)

    grid =
      for y <- min_y..max_y do
        line =
          for x <- min_x..max_x do
            print_color(Map.get(map, {x, y}))
          end

        line ++ ["\n"]
      end

    counted = Enum.reduce(map, %{}, fn {_, cell}, acc -> Map.update(acc, cell, 1, fn x -> x + 1 end) end)

    IO.binwrite(
      IO.iodata_to_binary(output ++ grid) <>
        "#{counted[:trees]} wooded * #{counted[:lumber]} lumberyards = #{counted[:trees] * counted[:lumber]}\n"
    )

    map
  end

  defp print_color(thing), do: @colors[thing] <> to_symbol(thing) <> IO.ANSI.default_color()
end
