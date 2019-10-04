defmodule AoC2017.Day09.Garbage do
  use AoC, year: 2017, day: 9

  defmodule StreamParser do
    import NimbleParsec

    defparsec(
      :garbage,
      ignore(string("<"))
      |> repeat(choice([ignore(string("!!")), ignore(string("!") |> utf8_char([])), utf8_char([{:not, ?>}])]))
      |> ignore(string(">"))
      |> reduce({Enum, :count, []})
      |> unwrap_and_tag(:garbage)
    )

    defparsec(
      :inner_group,
      choice([parsec(:garbage), parsec(:group)])
      |> repeat(ignore(string(",")) |> choice([parsec(:garbage), parsec(:group)]))
    )

    defparsec(
      :group,
      ignore(string("{")) |> optional(parsec(:inner_group)) |> ignore(string("}")) |> tag(:group)
    )

    defparsec(
      :stream,
      parsec(:group)
    )
  end

  def part_one(input) do
    input
    |> StreamParser.stream()
    |> elem(1)
    |> Keyword.get(:group)
    |> score_stream(0)
  end

  def part_two(input) do
    input
    |> StreamParser.stream()
    |> elem(1)
    |> Keyword.get(:group)
    |> count_garbage()
  end

  def count_garbage(stream) do
    local_garbage = Enum.sum(Keyword.get_values(stream, :garbage))

    Keyword.get_values(stream, :group)
    |> case do
      [] -> local_garbage
      more -> local_garbage + Enum.sum(Enum.map(more, &count_garbage/1))
    end
  end

  defp score_stream(stream, open_groups) do
    Keyword.get_values(stream, :group)
    |> case do
      [] ->
        open_groups + 1

      more ->
        open_groups + 1 + Enum.sum(Enum.map(more, &score_stream(&1, open_groups + 1)))
    end
  end
end
