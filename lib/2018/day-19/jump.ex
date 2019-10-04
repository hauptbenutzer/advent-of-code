defmodule AoC2018.Day19.Jump do
  use AoC, year: 2018, day: 19

  defmodule InstructionParser do
    import NimbleParsec

    ip_setting = ignore(string("#ip ")) |> integer(1) |> unwrap_and_tag(:ip)

    instruction_name = utf8_string([{:not, ?\s}], min: 4) |> map({String, :to_atom, []})

    instruction =
      instruction_name
      |> ignore(string(" "))
      |> integer(min: 1)
      |> ignore(string(" "))
      |> integer(min: 1)
      |> ignore(string(" "))
      |> integer(min: 1)
      |> tag(:instruction)

    defparsec(
      :parse,
      ip_setting |> ignore(string("\n")) |> repeat(instruction |> optional(ignore(string("\n"))))
    )
  end

  # for {op, fun} <-

  def part_one(input) do
    input =
      input
      |> InstructionParser.parse()
      |> elem(1)

    ip_register = Keyword.get(input, :ip)

    instructions =
      Keyword.get_values(input, :instruction)
      |> Enum.with_index()
      |> Enum.into(%{}, fn {ins, idx} -> {idx, ins} end)

    # |> IO.inspect()

    # ops = AoC2018.Day16.Op.ops() |> Enum.into(%{})

    # registers = Enum.into(0..5, %{}, &{&1, 0})
    # registers = %{registers | 0 => 1}

    registers = %{0 => 0, 1 => 1, 2 => 10_551_361, 3 => 4, 4 => 10_551_361, 5 => 10_551_361}
    registers = %{0 => 1, 1 => 2, 2 => 10_551_361, 3 => 4, 4 => 10_551_361, 5 => 10_551_361}
    registers = %{0 => 3, 1 => 3, 2 => 10_551_361, 3 => 4, 4 => 10_551_361, 5 => 10_551_361}
    registers = %{0 => 6, 1 => 4, 2 => 10_551_361, 3 => 4, 4 => 10_551_361, 5 => 10_551_361}
    registers = %{0 => 10, 1 => 5, 2 => 10_551_361, 3 => 4, 4 => 10_551_361, 5 => 10_551_361}

    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(registers, fn steps, registers ->
      ip = Map.get(registers, ip_register)

      case Map.get(instructions, ip) do
        nil ->
          {:halt, {registers, steps}}

        [op, a, b, c] ->
          {target, result} = op(op, a, b, c, registers)
          registers = %{registers | target => result} |> Map.update!(ip_register, fn x -> x + 1 end) |> IO.inspect()

          if target == 0 do
            IO.inspect(registers)
          end

          {:cont, registers}
      end
    end)
  end

  use Bitwise

  def op(:addr, a, b, c, r), do: {c, Map.get(r, a) + Map.get(r, b)}
  def op(:addi, a, b, c, r), do: {c, Map.get(r, a) + b}
  def op(:mulr, a, b, c, r), do: {c, Map.get(r, a) * Map.get(r, b)}
  def op(:muli, a, b, c, r), do: {c, Map.get(r, a) * b}
  def op(:banr, a, b, c, r), do: {c, Map.get(r, a) &&& Map.get(r, b)}
  def op(:bani, a, b, c, r), do: {c, Map.get(r, a) &&& b}
  def op(:borr, a, b, c, r), do: {c, Map.get(r, a) ||| Map.get(r, b)}
  def op(:bori, a, b, c, r), do: {c, Map.get(r, a) ||| b}
  def op(:setr, a, _b, c, r), do: {c, Map.get(r, a)}
  def op(:seti, a, _b, c, _), do: {c, a}
  def op(:gtir, a, b, c, r), do: {c, a ~> Map.get(r, b)}
  def op(:gtri, a, b, c, r), do: {c, Map.get(r, a) ~> b}
  def op(:gtrr, a, b, c, r), do: {c, Map.get(r, a) ~> Map.get(r, b)}
  def op(:eqir, a, b, c, r), do: {c, a <~> Map.get(r, b)}
  def op(:eqri, a, b, c, r), do: {c, Map.get(r, a) <~> b}
  def op(:eqrr, a, b, c, r), do: {c, Map.get(r, a) <~> Map.get(r, b)}

  def a ~> b, do: if(a > b, do: 1, else: 0)

  def a <~> b, do: if(a == b, do: 1, else: 0)
end
