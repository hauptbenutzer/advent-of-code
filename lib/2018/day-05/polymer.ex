defmodule AoC2018.Day05.Polymer do
  use AoC, year: 2018, day: 5

  @doc """
  iex>part_one()
  9900
  """
  def part_one() do
    chain()
    |> react()
    |> Enum.count()
  end

  @doc """
  iex>part_two()
  4992
  """
  def part_two() do
    input = chain()

    ?A..?Z
    |> Stream.map(fn char -> <<char::utf8>> end)
    |> Task.async_stream(&reacted_length_for_type(input, &1))
    |> Enum.map(&elem(&1, 1))
    |> Enum.min()
  end

  defp chain(), do: read() |> String.codepoints()

  defp reacted_length_for_type(list, type) do
    list
    |> Enum.reject(fn char -> String.upcase(char) == type end)
    |> react()
    |> Enum.count()
  end

  @cap_offset ?a - ?A
  defguard is_type_pair(a, b) when abs(a - b) == @cap_offset

  defp react(list), do: react([], list)

  defp react(acc, []), do: acc
  defp react([], [head | tail]), do: react([head], tail)

  defp react([<<acc_hd::utf8>> | acc_tl], [<<rest_hd::utf8>> | rest_tl])
       when is_type_pair(acc_hd, rest_hd) do
    react(acc_tl, rest_tl)
  end

  defp react([acc_hd | acc_tl], [rest_hd | rest_tl]) do
    react([rest_hd, acc_hd | acc_tl], rest_tl)
  end
end
