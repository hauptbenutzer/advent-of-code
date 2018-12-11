defmodule AoC2018.Day11.Charge do
  use AoC, year: 2018, day: 11

  @grid_size 300

  def max_power(square_size, cells) do
    range = 1..(@grid_size - (square_size - 1))

    range
    |> Stream.flat_map(fn x -> range |> Stream.map(&{x, &1}) end)
    |> Stream.map(fn coord -> {coord, square_power(coord, cells, square_size)} end)
    |> Enum.max_by(fn {_, power} -> power end)
  end

  @doc """
  iex>best_square(5468)
  {:ok, {15, {{90, 101}, 119.0}}}
  """
  def best_square(serial_number) do
    cells =
      Matrex.new(@grid_size, @grid_size, fn row, col ->
        power_for_cell(col, row, serial_number)
      end)

    1..@grid_size
    |> Task.async_stream(fn size -> {size, max_power(size, cells)} end)
    |> Enum.max_by(fn {:ok, {_, {_coord, power}}} -> power end)
  end

  def square_power({x, y}, cells, square_size) do
    cells
    |> Matrex.submatrix(y..(y + square_size - 1), x..(x + square_size - 1))
    |> Matrex.sum()
  end

  @doc """
  iex>power_for_cell(122, 79, 57)
  -5
  iex>power_for_cell(217, 196, 39)
  0
  iex>power_for_cell(101, 153, 71)
  4
  """
  def power_for_cell(x, y, serial) do
    rack_id = x + 10
    rem(div((rack_id * y + serial) * rack_id, 100), 10) - 5
  end
end
