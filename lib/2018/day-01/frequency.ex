defmodule AoC2018.Day01.Frequency do
  use AoC, year: 2018, day: 1

  @doc """
  iex>part_one()
  442
  """
  def part_one() do
    int_stream()
    |> Enum.sum()
  end

  @doc """
  iex>part_two()
  59908
  """
  def part_two() do
    int_stream()
    |> Stream.cycle()
    |> Stream.scan(0, &+/2)
    |> Enum.reduce_while(MapSet.new([0]), fn frequency, set ->
      if MapSet.member?(set, frequency) do
        {:halt, frequency}
      else
        {:cont, MapSet.put(set, frequency)}
      end
    end)
  end

  defp int_stream() do
    stream()
    |> Stream.map(&Integer.parse/1)
    |> Stream.map(&elem(&1, 0))
  end
end
