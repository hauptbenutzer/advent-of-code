defmodule AoC2017.Day08.YoDawg do
  use AoC, year: 2017, day: 8

  defmodule InstructionParser do
    import NimbleParsec

    register = utf8_string([?a..?z], min: 1) |> unwrap_and_tag(:register)
    instruction = utf8_string([?a..?z], min: 1) |> unwrap_and_tag(:instruction)

    value = optional(string("-")) |> integer(min: 1) |> reduce(:parse_value) |> unwrap_and_tag(:value)

    operator =
      choice([string(">="), string("<="), string("=="), string("!="), string(">"), string("<")])
      |> unwrap_and_tag(:op)

    condition =
      ignore(string("if "))
      |> concat(register)
      |> ignore(string(" "))
      |> concat(operator)
      |> ignore(string(" "))
      |> concat(value)
      |> tag(:condition)

    defparsec(
      :instruction,
      register
      |> ignore(string(" "))
      |> concat(instruction)
      |> ignore(string(" "))
      |> concat(value)
      |> ignore(string(" "))
      |> concat(condition),
      debug: true
    )

    def parse_value(["-", val]), do: -1 * val
    def parse_value([val]), do: val
  end

  def part_one(file \\ "test.txt") do
    file
    |> run()
    |> elem(1)
    |> Enum.max_by(&elem(&1, 1))
  end

  def part_two(file \\ "test.txt") do
    file
    |> run()
    |> elem(0)
  end

  defp run(file) do
    file
    |> stream()
    |> Stream.map(&InstructionParser.instruction/1)
    |> Stream.map(&elem(&1, 1))
    |> Enum.reduce({0, %{}}, fn line, {max, registers} ->
      [register: reg_a, op: op, value: val] = Keyword.get(line, :condition)

      if condition(op, registers[reg_a] || 0, val) do
        register = Keyword.get(line, :register)
        instruction = Keyword.get(line, :instruction)
        value = Keyword.get(line, :value)
        new_val = run_instruction(instruction, registers[register] || 0, value)
        max = max(new_val, max)

        {max, Map.put(registers, register, new_val)}
      else
        {max, registers}
      end
    end)
  end

  defp run_instruction("inc", current, by), do: current + by
  defp run_instruction("dec", current, by), do: current - by

  defp condition(op, a, b) do
    lookup_op(op).(a, b)
  end

  defp lookup_op(">"), do: &Kernel.>/2
  defp lookup_op("<"), do: &Kernel.</2
  defp lookup_op(">="), do: &Kernel.>=/2
  defp lookup_op("<="), do: &Kernel.<=/2
  defp lookup_op("=="), do: &Kernel.==/2
  defp lookup_op("!="), do: &Kernel.!=/2
end
