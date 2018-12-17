defmodule AoC2017.Day08.YoDawg do
  use AoC, year: 2017, day: 8

  defmodule InstructionParser do
    import NimbleParsec

    register = utf8_string([?a..?z], min: 1) |> unwrap_and_tag(:register)
    instruction = utf8_string([?a..?z], min: 1) |> unwrap_and_tag(:instruction)

    value = integer(min: 1) |> unwrap_and_tag(:value)
    operator = choice([string(">"), string("<"), string(">="), string("<="), string("=="), string("!=")]) |> unwrap_and_tag(:op)
    condition = string("if ") |> concat(register) |> string(" ") |> concat(operator) |> string(" ") |> concat(value) |> unwrap_and_tag(:condition)

    defparsec(
      :instruction,
      register |> string(" ") |> concat(instruction) |> string(" ") |> concat(value) |> string(" ") |> concat(condition)
      debug: true
    )
  end

  def part_one(file \\ "test.txt") do
    file
    |> stream()
    |> Stream.map(&InstructionParser.instruction/1)
  end
end
