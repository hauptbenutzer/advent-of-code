defmodule AoC2018.Day04.Record do
  use AoC, year: 2018, day: 4

  def part_one() do
    {id, sleepings} =
      shift_stream()
      |> Enum.max_by(&sum_ranges_for_guard/1)

    {max_minute, _} = calculate_sleepiest_minute({id, sleepings})
    {id, max_minute, id * max_minute}
  end

  def part_two() do
    stream = shift_stream()

    stream
    |> Enum.map(&calculate_sleepiest_minute/1)
    |> Enum.zip(stream |> Enum.map(&elem(&1, 0)))
  end

  defp shift_stream() do
    event_stream()
    |> Enum.sort_by(& &1["datetime"], &is_earlier_date?/2)
    |> Enum.reduce({[], %{}}, fn
      %{"event" => {:guard, guard_id}, "datetime" => date}, {shifts, acc} ->
        {[acc | shifts],
         %{guard_id: guard_id, last_event: :wake, last_event_time: date, sleeping: []}}

      %{"event" => :asleep, "datetime" => date}, {shifts, %{last_event: :wake} = guard} ->
        {shifts, %{guard | last_event: :asleep, last_event_time: date}}

      %{"event" => :wake, "datetime" => date},
      {shifts, %{last_event: :asleep, last_event_time: last_date} = guard} ->
        to_date = date

        {shifts,
         %{
           guard
           | last_event: :wake,
             last_event_time: date,
             sleeping: [{last_date, to_date} | guard.sleeping]
         }}
    end)
    |> elem(0)
    |> Enum.reject(&(&1 == %{}))
    |> Enum.group_by(& &1.guard_id, & &1.sleeping)
  end

  defp calculate_sleepiest_minute({_id, sleepings}) do
    sleepings
    |> List.flatten()
    |> Enum.flat_map(fn {from, to} -> from.minute..(to.minute - 1) end)
    |> Enum.group_by(& &1)
    |> Enum.max_by(fn {_minute, minutes} -> Enum.count(minutes) end, fn -> {nil, []} end)
    |> (fn {minute, minutes} ->
          {minute, Enum.count(minutes)}
        end).()
  end

  defp sum_ranges_for_guard({_, sleepings}) do
    sleepings
    |> List.flatten()
    |> Enum.map(&range_to_time_diff/1)
    |> Enum.sum()
  end

  defp range_to_time_diff({from, to}) do
    NaiveDateTime.diff(from, to, :second) / 60 * -1
  end

  defp event_stream() do
    stream()
    |> Stream.map(&parse_line/1)
  end

  @regex ~r{\[(?<datetime>[^\]]+)\] (?<event>.+)\n?}
  defp parse_line(line) do
    Regex.named_captures(@regex, line)
    |> (fn %{"datetime" => datetime} = event ->
          Map.put(event, "datetime", NaiveDateTime.from_iso8601!(datetime <> ":00"))
        end).()
    |> case do
      %{"event" => "Guard #" <> rest} = event ->
        Map.put(event, "event", {:guard, parse_guard(rest)})

      %{"event" => "falls asleep"} = event ->
        Map.put(event, "event", :asleep)

      %{"event" => "wakes up"} = event ->
        Map.put(event, "event", :wake)
    end
  end

  defp parse_guard(string), do: _parse_guard(string, "")

  defp _parse_guard(<<char::utf8>> <> rest, acc) when char in ?0..?9 do
    _parse_guard(rest, acc <> <<char::utf8>>)
  end

  defp _parse_guard(_, acc) do
    String.to_integer(acc)
  end

  defp is_earlier_date?(a, b) do
    NaiveDateTime.compare(a, b)
    |> case do
      :lt -> true
      :eq -> true
      _ -> false
    end
  end
end
