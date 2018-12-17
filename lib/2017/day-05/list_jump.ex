defmodule AoC2017.Day05.ListJump do
  use AoC, year: 2017, day: 5


  @doc """
  iex>part_one("0\\n3\\n0\\n1\\n-3")
  5

  iex>part_one(read())
  326618
  """
  def part_one(input), do: jump(input, fn entry -> entry + 1 end)

  @doc """
  iex>part_two("0\\n3\\n0\\n1\\n-3")
  10

  # iex>part_two(read())
  # 21841249
  """
  def part_two(input), do: jump(input, fn entry -> if entry > 2, do: entry - 1, else: entry + 1 end)

  defp jump(input, offset_fun) do
    list =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)

    array = Enum.into(Enum.with_index(list), %{}, fn {val, key} -> {key, val} end)
    array_length = Enum.count(list)

    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while({0, array}, fn step, {offset, array} ->
      if offset > array_length - 1 do
        {:halt, step - 1}
      else
        entry = array[offset]
        array = Map.put(array, offset, offset_fun.(entry))
        {:cont, {entry + offset, array}}
      end
    end)
  end
end
