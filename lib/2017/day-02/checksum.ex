defmodule AoC2017.Day02.Checksum do
  use AoC, year: 2017, day: 2

  @doc """
  iex>part_one()
  44887
  """
  def part_one() do
    read_spreadsheet()
    |> checksum(&max_min_diff/1)
  end

  @doc """
  iex>part_two()
  242
  """
  def part_two() do
    read_spreadsheet()
    |> checksum(&evenly_divisible/1)
  end

  defp read_spreadsheet() do
    stream()
    |> Stream.map(&reduce_line/1)
  end

  defp reduce_line(line) do
    Stream.resource(
      fn -> {String.codepoints(line), ""} end,
      fn
        {[char | rest], acc} when char in ["\n", "\t"] -> {[String.to_integer(acc)], {rest, ""}}
        {[char | rest], acc} -> {[], {rest, acc <> char}}
        {[], _acc} -> {:halt, []}
      end,
      fn _ -> nil end
    )
  end

  def checksum(spreadsheet, row_fun) do
    spreadsheet
    |> Enum.map(row_fun)
    |> Enum.sum()
  end

  def max_min_diff(row) do
    row
    |> Enum.reduce({:infinity, 0}, fn num, {min, max} ->
      {if(num < min, do: num, else: min), if(num > max, do: num, else: max)}
    end)
    |> (fn {min, max} -> max - min end).()
  end

  defp evenly_divisible(row) do
    length = Enum.count(row) - 1

    row
    |> Enum.with_index()
    |> Enum.flat_map(fn {num, idx} ->
      row
      |> cycle(idx + 1, length)
      |> Enum.map(fn b -> [num, b] end)
    end)
    |> Enum.find(fn [a, b] -> rem(a, b) == 0 end)
    |> (fn [a, b] -> div(a, b) end).()
  end

  defp cycle(row, offset, length) do
    row
    |> Stream.cycle()
    |> Stream.drop(offset)
    |> Enum.take(length)
  end
end
