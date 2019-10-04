defmodule AoC2018.Day21.Chronal do
  use AoC, year: 2018, day: 21

  def part_one(input) do
    input =
      input
      |> AoC2018.Day19.Jump.InstructionParser.parse()
      |> elem(1)

    ip_register = Keyword.get(input, :ip)

    instructions =
      Keyword.get_values(input, :instruction)
      |> Enum.with_index()
      |> Enum.into(%{}, fn {ins, idx} -> {idx, ins} end)
      |> IO.inspect()

    # |> IO.inspect()

    # ops = AoC2018.Day16.Op.ops() |> Enum.into(%{})

    registers = Enum.into(0..5, %{}, &{&1, 0})
    # registers = %{registers | 0 => 1}

    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(registers, fn steps, registers ->
      ip = Map.get(registers, ip_register)

      case Map.get(instructions, ip) do
        nil ->
          {:halt, {registers, steps}}

        [op, a, b, c] ->
          {target, result} = op(op, a, b, c, registers)
          registers = %{registers | target => result} |> Map.update!(ip_register, fn x -> x + 1 end)

          print_state(ip_register, ip, instructions, registers, steps)

          {:cont, registers}
      end
    end)
  end

  defp print_state(ip_register, last_ip, instructions, registers, steps) do
    IO.write(IO.ANSI.clear() <> IO.ANSI.home())

    Enum.each(instructions, fn {idx, instruction} ->
      [op, a, b, c] = instruction
      ip = Map.get(registers, ip_register)

      prefix = cond do
        idx == ip -> "▶︎ "
        idx == last_ip -> "> "
        true -> "  "
      end

      IO.write(prefix <> "#{op} #{a} #{b} #{c} \n")
    end)

    IO.puts("Step #{steps}")
    IO.inspect(registers, label: "Registers")
    IO.read(1)
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
