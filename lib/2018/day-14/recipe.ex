defmodule AoC2018.Day14.Recipe do
  def part_one(input \\ 9) do
    1..(input + 10)
    |> Enum.reduce_while({:array.from_list([3, 7]), [0, 1]}, fn _x, {list, elves} ->
      new_recipies =
        Enum.map(elves, &:array.get(&1, list))
        |> Enum.sum()
        |> Integer.digits()
        |> Enum.reduce(list, fn digit, acc -> :array.set(:array.sparse_size(acc), digit, acc) end)

      size = :array.sparse_size(new_recipies)

      new_elves = Enum.map(elves, fn elf -> rem(:array.get(elf, list) + 1 + elf, size) end)

      if size >= input + 10 do
        {:halt, slice(new_recipies, input, 10) |> Enum.into("", &to_string/1)}
      else
        {:cont, {new_recipies, new_elves}}
      end
    end)
  end

  def part_two(input \\ 9) do
    target_list = input |> Integer.digits() |> :array.from_list()
    target_size = :array.sparse_size(target_list)

    1..1_000_000_000
    |> Enum.reduce_while({:array.from_list([3, 7]), [0, 1]}, fn _x, {list, elves} ->
      new_recipies =
        Enum.map(elves, &:array.get(&1, list))
        |> Enum.sum()
        |> Integer.digits()
        |> Enum.reduce(list, fn digit, acc -> :array.set(:array.sparse_size(acc), digit, acc) end)

      size = :array.sparse_size(new_recipies)

      new_elves = Enum.map(elves, fn elf -> rem(:array.get(elf, list) + 1 + elf, size) end)

      if array_matches(new_recipies, target_list, size - target_size) or array_matches(new_recipies, target_list, size + 2 - target_size) do
        {:halt, size - target_size}
      else
        {:cont, {new_recipies, new_elves}}
      end
    end)
    |> case do
      int when is_integer(int) -> int
      _ -> :not_done
    end
  end

  defp array_matches(haystack, needle, haystack_offset) when haystack_offset >= 0 do
    Enum.reduce_while(0..:array.sparse_size(needle), true, fn idx, _ ->
      if :array.get(idx, needle) == :array.get(idx + haystack_offset, haystack) do
        {:cont, true}
      else
        {:halt, false}
      end
    end)
  end

  defp array_matches(_, _, _), do: false

  defp slice(array, from, count) do
    Enum.map(from..(from + count - 1), fn idx -> :array.get(idx, array) end)
  end
end
