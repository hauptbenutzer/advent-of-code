defmodule AoC2017.Day11.Hex do
  use AoC, year: 2017, day: 11

  @start {0, 0, 0}

  @doc """
  All you ever wanted to know about hex grids https://www.redblobgames.com/grids/hexagons/
  """
  def part_one(file \\ "default.txt") do
    read(file)
    |> String.split(",")
    |> Enum.reduce(@start, &move/2)
    |> distance(@start)
  end

  def part_two(file \\ "default.txt") do
    read(file)
    |> String.split(",")
    |> Enum.reduce({@start, 0}, fn direction, {coord, distance} ->
      new_coord = move(direction, coord)
      {new_coord, max(distance(new_coord, @start), distance)}
    end)
  end

  defp move("n", {x, y, z}), do: {x, y + 1, z - 1}
  defp move("ne", {x, y, z}), do: {x + 1, y, z - 1}
  defp move("se", {x, y, z}), do: {x + 1, y - 1, z}
  defp move("s", {x, y, z}), do: {x, y - 1, z + 1}
  defp move("sw", {x, y, z}), do: {x - 1, y, z + 1}
  defp move("nw", {x, y, z}), do: {x - 1, y + 1, z}

  defp distance({x1, y1, z1}, {x2, y2, z2}), do: div(abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2), 2)
end
