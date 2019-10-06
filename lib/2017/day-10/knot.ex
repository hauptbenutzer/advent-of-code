defmodule AoC2017.Day10.Knot do
  use AoC, year: 2017, day: 10
  use Bitwise

  @doc """
  iex>part_one("94,84,0,79,2,27,81,1,123,93,218,23,103,255,254,243")
  23715
  """
  def part_one(input, length \\ 256) do
    lengths = String.split(input, ",") |> Enum.map(&String.to_integer/1)
    list = 0..(length - 1)

    {list, shifts, _} = run_round(list, lengths, length)

    [a, b] = list |> Enum.slice(length - rem(shifts, length), 2)
    a * b
  end

  @doc """
  iex>part_two("94,84,0,79,2,27,81,1,123,93,218,23,103,255,254,243")
  541dc3180fd4b72881e39cf925a50253
  """
  def part_two(input, length \\ 256) do
    lengths = :erlang.binary_to_list(input) ++ [17, 31, 73, 47, 23]
    list = 0..(length - 1)
    skip = shifts = 0

    {list, nshifts, _skip} =
      Enum.reduce(1..64, {list, shifts, skip}, fn _, {list, shifts, skip} ->
        {list, nshifts, skip} = run_round(list, lengths, length, skip)
        {list, nshifts + shifts, skip}
      end)

    list = shift_rotate_list(list, length - rem(nshifts, length))

    Enum.chunk_every(list, 16)
    |> Enum.map(fn chunk ->
      Enum.reduce(chunk, 0, fn elem, acc -> acc ^^^ elem end)
    end)
    |> :erlang.list_to_binary()
    |> Base.encode16(case: :lower)
  end

  defp run_round(list, lengths, length, skip \\ 0) do
    Enum.reduce(lengths, {list, 0, skip}, fn l, {list, oshift, skip} ->
      shift = rem(l + skip, length)

      list =
        list
        |> Enum.reverse_slice(0, l)
        |> shift_rotate_list(shift)

      {list, shift + oshift, skip + 1}
    end)
  end

  def shift_rotate_list(list, n)
  def shift_rotate_list(list, 0), do: list
  def shift_rotate_list(list, n), do: Enum.drop(list, n) |> Enum.concat(Enum.take(list, n))
end
