defmodule AoC2017.Day06.Realloc do
  use AoC, year: 2017, day: 6

  @doc """
  iex>part_one("0\\t2\\t7\\t0")
  5
  iex>part_one(read())
  7864
  """
  def part_one(input) do
    input
    |> find_loop()
    |> Keyword.get(:step)
  end

  @doc """
  iex>part_two("0\\t2\\t7\\t0")
  4
  iex>part_two(read())
  1695
  """
  def part_two(input) do
    input
    |> find_loop()
    |> Keyword.get(:diff)
  end

  defp find_loop(input) do
    banks =
      input
      |> String.split("\t", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()

    banks_count = Enum.count(banks)

    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while({banks, %{banks => 0}}, fn step, {banks, configs} ->
      reallocated = reallocate(banks, banks_count)

      last_seen = configs[reallocated]

      if last_seen do
        {:halt, [step: step, last_seen: last_seen, diff: step - last_seen]}
      else
        {:cont, {reallocated, Map.put(configs, reallocated, step)}}
      end
    end)
  end

  defp reallocate(banks, banks_count) do
    {max, max_idx} = Enum.max_by(banks, fn {bank, idx} -> {bank, -1 * idx} end)

    max_offset = banks_count - (max_idx + 1)

    Enum.map(banks, fn
      {bank, idx} ->
        current = if idx == max_idx, do: 0, else: bank
        base = current + div(max, banks_count)

        if rem(idx + max_offset, banks_count) < rem(max, banks_count) do
          {base + 1, idx}
        else
          {base, idx}
        end
    end)
  end
end
