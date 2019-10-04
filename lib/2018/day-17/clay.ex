defmodule AoC2018.Day17.Clay do
  use AoC, year: 2018, day: 17

  defmodule ScanParser do
    import NimbleParsec

    value = integer(min: 1)
    range = value |> ignore(string("..")) |> concat(value)
    coord = choice([ignore(string("x")) |> replace(:x), ignore(string("y")) |> replace(:y)])

    value_assign = coord |> ignore(string("=")) |> concat(value) |> reduce(:value_assign) |> tag(:value_assign)
    range_assign = coord |> ignore(string("=")) |> concat(range) |> reduce(:range_assign) |> tag(:range_assign)

    defparsec(
      :scan_line,
      value_assign |> ignore(string(", ")) |> concat(range_assign)
    )

    def value_assign([coord, val]), do: {coord, val}
    def range_assign([coord, from, to]), do: {coord, from..to}
  end

  def part_one(scan_lines) do
    scan_lines
    |> Stream.map(&ScanParser.scan_line/1)
    |> Stream.map(&elem(&1, 1))
    |> Stream.flat_map(fn scan ->
      case scan do
        [value_assign: [x: value], range_assign: [y: range]] ->
          Stream.map(range, fn y -> {value, y} end)

        [value_assign: [y: value], range_assign: [x: range]] ->
          Stream.map(range, fn x -> {x, value} end)
      end
    end)
    |> Enum.into(%{}, fn coord -> {coord, "#"} end)
    |> print_grid
  end

  defp flow(x, y, direction, grid) do
    case grid[{x, y}] do
      blocked when blocked in ~w(# ~) ->
        {:settled, grid}

      nil ->
        grid = Map.put(grid, {x, y}, "|")

        case flow(x, y + 1, :down, grid) do
          {:settled, grid} ->
            settled? =
              case direction do
                :left ->
                  flow(x - 1, y, :left, grid)

                :right ->
                  flow(x + 1, y, :right, grid)

                :down ->
                  flow(x + 1, y, :right, grid)
              end
        end
    end
  end

  @colors %{
    "." => IO.ANSI.yellow(),
    "#" => IO.ANSI.red(),
    "|" => IO.ANSI.cyan(),
    "~" => IO.ANSI.blue()
  }
  def print_grid(map) do
    {{{min_x, _}, _}, {{max_x, _}, _}} = Enum.min_max_by(map, fn {{x, _}, _} -> x end)
    {{{_, min_y}, _}, {{_, max_y}, _}} = Enum.min_max_by(map, fn {{_, y}, _} -> y end)

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        print_color(Map.get(map, {x, y}, "."))
      end

      IO.write("\n")
    end
  end

  defp print_color(thing), do: IO.write(@colors[thing] <> thing <> IO.ANSI.default_color())
end
