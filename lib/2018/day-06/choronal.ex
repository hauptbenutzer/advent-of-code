# defmodule AoC2018.Day06.Chronal do
#   use AoC, year: 2018, day: 6
#
#   def part_one(file \\ "default.txt") do
#     coords =
#       file
#       |> stream()
#       |> Stream.map(&String.split(&1, [", ", "\n"], trim: true))
#       |> Stream.map(fn [a, b] -> {String.to_integer(a), String.to_integer(b)} end)
#       |> Enum.to_list()
#
#     {top, right, bottom, left} = find_edges(coords) |> IO.inspect()
#
#     filled =
#       coords_for_square({left, top}, {right, bottom})
#       |> Stream.map(&find_closest_coord(coords, &1))
#       |> Enum.into(%{})
#       |> print_square(coords)
#
#     # bounded_coords =
#     #   coords
#     #   |> Enum.reject(&is_infinite_coord(&1, filled, {top, right, bottom, left}))
#
#     filled
#     |> Enum.group_by(fn {_x, coord} -> coord end, fn {x, _coord} -> x end)
#     |> Enum.reject(fn
#       {coord, _} when coord != nil ->
#         is_infinite_coord(coord, filled, {top, right, bottom, left})
#
#       _ ->
#         true
#     end)
#     |> Enum.map(fn {coord, coords} -> {coord, Enum.count(coords)} end)
#     |> Enum.max()
#   end
#
#   def coords_for_square({left, top}, {right, bottom}) do
#     top..bottom
#     |> Stream.flat_map(fn y ->
#       left..right
#       |> Stream.map(fn x -> {x, y} end)
#     end)
#   end
#
#   defp is_infinite_coord({x, y} = me, filled, {top, right, bottom, left}) do
#     cond do
#       # top
#       filled[{x, top}] == me -> true
#       # right
#       filled[{right, y}] == me -> true
#       # bottom
#       filled[{x, bottom}] == me -> true
#       # left
#       filled[{left, y}] == me -> true
#       true -> false
#     end
#   end
#
#   defp print_square(filled, coords) do
#     coords
#     |> Enum.reduce(%{}, fn coord, acc ->
#       Map.update(acc, )
#     end)
#
#     filled
#     |> Enum.to_list()
#     |> Enum.sort_by(fn {{x, y}, _} -> x*42 + 10 end)
#     |> Enum.reduce(%{}, fn {{x, y}, coord} ->
#
#     end)
#   end
#
#   def find_closest_coord(coords, {x0, y0} = coord) do
#     closest =
#       Enum.reduce(coords, {[], :infinity}, fn {x1, y1}, {acc, cur_min} ->
#         diff = abs(x0 - x1) + abs(y0 - y1)
#
#         cond do
#           diff == cur_min -> {[{x1, y1} | acc], cur_min}
#           diff < cur_min -> {[{x1, y1}], diff}
#           true -> {acc, cur_min}
#         end
#       end)
#       |> case do
#         {[one], _} -> one
#         {_, _} -> nil
#       end
#
#     {coord, closest}
#   end
#
#   defp find_edges(coords) do
#     {left, _} = Enum.min_by(coords, fn {x, _y} -> x end)
#     {_, top} = Enum.min_by(coords, fn {_x, y} -> y end)
#     {right, _} = Enum.max_by(coords, fn {x, _y} -> x end)
#     {_, bottom} = Enum.max_by(coords, fn {_x, y} -> y end)
#
#     # Damn you, CSS
#     {top, right, bottom, left}
#   end
# end
