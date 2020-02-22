defmodule AoC2017.Day13.Firewall do
  use AoC, year: 2017, day: 13

  defmodule Parser do
    import NimbleParsec

    defparsec(
      :parse_line,
      unwrap_and_tag(integer(min: 1), :depth)
      |> concat(ignore(string(": ")))
      |> unwrap_and_tag(integer(min: 1), :range)
      |> concat(optional(ignore(string("\n"))))
    )
  end

  def part_two(file) do
    layer_config =
      stream(file)
      |> Stream.map(&Parser.parse_line/1)
      |> Stream.map(&elem(&1, 1))

    lcm =
      Enum.reduce(layer_config, 1, fn [_, {:range, range}], acc -> lcm(acc, range * 2 - 2) end)
      |> IO.inspect(label: "lcm")

    Enum.reduce_while(3_966_400..lcm, nil, fn delay, _ ->
      if rem(delay, 100) == 0, do: IO.puts(to_string(delay))

      Enum.reduce_while(layer_config, false, fn [depth: depth, range: range], _ ->
        if gets_caught?(depth, range, delay) do
          {:halt, true}
        else
          {:cont, false}
        end
      end)
      |> case do
        false -> {:halt, {:yeah, delay}}
        true -> {:cont, nil}
      end
    end)
  end

  def gets_caught?(depth, range, delay) do
    rem(delay + depth, range * 2 - 2) == 0
  end

  def gcd(a, 0), do: abs(a)
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(a, b), do: div(abs(a * b), gcd(a, b))
end
