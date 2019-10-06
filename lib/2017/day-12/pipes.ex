defmodule AoC2017.Day12.Pipes do
  use AoC, year: 2017, day: 12

  defmodule Parser do
    import NimbleParsec

    pid = integer(min: 1)

    defparsec(
      :parse_line,
      pid
      |> tag(:from)
      |> concat(ignore(string(" <-> ")))
      |> tag(pid |> repeat(ignore(string(", ")) |> concat(pid)), :to)
      |> concat(optional(ignore(string("\n"))))
    )
  end

  def part_one(file \\ "default.txt") do
    file
    |> build_graph()
    |> Graph.reachable_neighbors([0])
  end

  def part_two(file) do
    file
    |> build_graph()
    |> Graph.strong_components()
  end

  defp build_graph(file) do
    file
    |> stream()
    |> Stream.map(&Parser.parse_line/1)
    |> Stream.map(&elem(&1, 1))
    |> Enum.reduce(Graph.new(), fn [from: [from], to: tos], g ->
      Enum.reduce(tos, g, fn to, g ->
        Graph.add_edge(g, from, to)
      end)
    end)
  end
end
