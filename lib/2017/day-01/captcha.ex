defmodule AoC2017.Day01.Captcha do
  use AoC, year: 2017, day: 1

  @doc """
  iex>part_one()
  1141
  """
  def part_one() do
    seq = read_sequence()
    offset = 1

    solve_for_offset(seq, offset)
  end

  @doc """
  iex>part_two()
  950
  """
  def part_two() do
    seq = read_sequence()
    offset = seq |> Enum.count() |> div(2)

    solve_for_offset(seq, offset)
  end

  defp solve_for_offset(seq, offset) do
    seq
    |> Stream.zip(seq |> Stream.cycle() |> Stream.drop(offset))
    |> Stream.filter(fn {a, b} -> a == b end)
    |> Stream.map(fn {a, a} -> a end)
    |> Enum.sum()
  end

  defp read_sequence() do
    read()
    |> String.codepoints()
    |> Enum.map(&String.to_integer/1)
  end
end
