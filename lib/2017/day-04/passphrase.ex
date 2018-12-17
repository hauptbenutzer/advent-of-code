defmodule AoC201AoC2017.Day04.Passphrase do
  use AoC, year: 2017, day: 4

  @doc """
  iex>part_one()
  337
  """
  def part_one(), do: count_valid(&no_duplicates?/1)

  @doc """
  iex>part_two()
  231
  """
  def part_two(), do: count_valid(&no_anagrams?/1)

  defp count_valid(fun) do
    stream()
    |> Task.async_stream(fun)
    |> Stream.filter(fn {:ok, val} -> val end)
    |> Enum.count()
  end

  defp no_anagrams?(line) do
    line
    |> String.split([" ", "\n"], trim: true)
    |> Enum.map(fn word ->
      word
      |> String.split("", trim: true)
      |> Enum.into(MapSet.new)
    end)
    |> duplicates?()
  end

  defp no_duplicates?(line) do
    line
    |> String.split([" ", "\n"], trim: true)
    |> duplicates?()
  end

  defp duplicates?(list) do
    list
    |> Enum.reduce_while(MapSet.new, fn word, set ->
      if MapSet.member?(set, word), do: {:halt, false}, else: {:cont, MapSet.put(set, word)}
    end)
    |> Kernel.!=(false)
  end
end
