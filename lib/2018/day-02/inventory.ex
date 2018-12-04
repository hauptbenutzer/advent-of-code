defmodule AoC2018.Day02.Inventory do
  use AoC, year: 2018, day: 2

  @doc """
  iex>part_one()
  7410
  """
  def part_one() do
    stream()
    |> Task.async_stream(&histogram/1)
    |> Stream.map(fn {:ok, result} -> result end)
    |> Enum.to_list()
    |> List.flatten()
    |> Enum.reduce(%{}, fn {count, true}, acc ->
      Map.update(acc, count, 1, &(&1 + 1))
    end)
    |> (fn results -> results[2] * results[3] end).()
  end

  def part_two() do
    stream = stream()

    stream
    |> Stream.flat_map(fn boxa ->
      Stream.map(stream, fn boxb -> {boxa, boxb} end)
    end)
    # |> Task.async_stream(fn {boxa, boxb} -> String.myers_difference(boxa, boxb) end)
    |> Task.async_stream(fn {boxa, boxb} ->
      case diff_chars(boxa, boxb) do
        {common, [<<_char::utf8>>]} -> [common |> Enum.join()]
        _ -> []
      end
    end)
    |> Stream.flat_map(fn {:ok, val} -> val end)
    |> Enum.to_list()
  end

  def diff_chars(worda, wordb), do: _diff_chars(worda, wordb, {[], []})

  defp _diff_chars(worda, wordb, acc) when worda == "" or wordb == "",
    do: acc

  defp _diff_chars(<<char::utf8>> <> resta, <<char::utf8>> <> restb, {common, diff}),
    do: _diff_chars(resta, restb, {[<<char::utf8>> | common], diff})

  defp _diff_chars(<<chara::utf8>> <> resta, <<_charb::utf8>> <> restb, {common, diff}),
    do: _diff_chars(resta, restb, {common, [<<chara::utf8>> | diff]})

  def histogram(word) do
    word
    |> String.codepoints()
    |> Enum.reduce(%{}, fn char, acc ->
      Map.update(acc, char, 1, &(&1 + 1))
    end)
    |> (fn map ->
          for {_char, count} <- map, count in [2, 3], into: %{} do
            {count, true}
          end
        end).()
    |> Enum.to_list()
  end
end
