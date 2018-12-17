defmodule AoC2018.Day16.Op do
  use AoC, year: 2018, day: 16

  use Bitwise

  def part_one(file \\ "default.txt") do
    # registers = Enum.into(0..3, %{}, &{&1, 0})

    stream(file)
    |> Stream.chunk_every(4)
    |> Stream.map(fn chunk ->
      [before, instruction, thereafter] = Enum.take(chunk, 3)
      before = parse_registers(before)
      thereafter = parse_registers(thereafter)
      [_opcode, a, b, c] = String.split(instruction, [" ", "\n"], trim: true) |> Enum.map(&String.to_integer/1)

      Enum.flat_map(ops(), fn {name, op} ->
        if thereafter == run_op([a, b, c], op, before) do
          [name]
        else
          []
        end
      end)
    end)
    |> Stream.filter(fn ops -> Enum.count(ops) >= 3 end)
    |> Enum.count()
  end

  def part_two(file \\ "default.txt") do
    stream(file)
    |> Stream.chunk_every(4)
    |> Stream.map(fn chunk ->
      [before, instruction, thereafter] = Enum.take(chunk, 3)
      before = parse_registers(before)
      thereafter = parse_registers(thereafter)
      [opcode, a, b, c] = String.split(instruction, [" ", "\n"], trim: true) |> Enum.map(&String.to_integer/1)

      {opcode,
       Enum.flat_map(ops(), fn {name, op} ->
         if thereafter == run_op([a, b, c], op, before) do
           [name]
         else
           []
         end
       end)}
    end)
    |> Enum.group_by(&elem(&1, 0), fn {_, samples} -> Enum.into(samples, MapSet.new()) end)
    |> Enum.map(fn {opcode, sets} ->
      {opcode,
       sets
       |> Enum.reduce(&MapSet.intersection/2)}
    end)
    |> Enum.into(%{})
    |> while(fn acc -> Enum.any?(acc, fn {_, set} -> MapSet.size(set) > 1 end) end, fn acc ->
      found =
        acc
        |> Enum.filter(fn {_, set} -> MapSet.size(set) == 1 end)
        |> Enum.map(&elem(&1, 1))
        |> Enum.reduce(&MapSet.union/2)

      Enum.reduce(acc, acc, fn {opcode, set}, acc ->
        if MapSet.size(set) > 1 do
          Map.put(acc, opcode, MapSet.difference(set, found))
        else
          acc
        end
      end)
    end)
    |> case do
      ops ->
        registers = Enum.into(0..3, %{}, &{&1, 0})

        ops =
          Enum.into(ops, %{}, fn {opcode, set} -> {opcode, Keyword.get(ops(), Enum.take(set, 1) |> List.first())} end)

        stream("default-instructions.txt")
        |> Stream.map(fn line -> String.split(line, [" ", "\n"], trim: true) |> Enum.map(&String.to_integer/1) end)
        |> Enum.reduce(registers, fn instr, registers ->
          [opcode, a, b, c] = instr
          run_op([a, b, c], ops[opcode], registers)
        end)
    end

    # |> Stream.filter(fn ops -> Enum.count(ops) == 1 end)
    # |> Enum.count()
  end

  defp while(acc, condition, fun) do
    if condition.(acc) do
      while(fun.(acc), condition, fun)
    else
      acc
    end
  end

  @regex ~r{\[(?<registers>.+)\]}
  defp parse_registers(string) do
    Regex.named_captures(@regex, string)
    |> case do
      %{"registers" => registers} ->
        String.split(registers, ", ", trim: true)
        |> Enum.map(&String.to_integer/1)
    end
    |> Enum.with_index()
    |> Enum.into(%{}, fn {val, idx} -> {idx, val} end)
  end

  defp run_op([a, b, c], op, registers) do
    {target, result} = op.(a, b, c, registers)
    %{registers | target => result}
  end

  def ops() do
    [
      addr: fn a, b, c, r -> {c, r[a] + r[b]} end,
      addi: fn a, b, c, r -> {c, r[a] + b} end,
      mulr: fn a, b, c, r -> {c, r[a] * r[b]} end,
      muli: fn a, b, c, r -> {c, r[a] * b} end,
      banr: fn a, b, c, r -> {c, r[a] &&& r[b]} end,
      bani: fn a, b, c, r -> {c, r[a] &&& b} end,
      borr: fn a, b, c, r -> {c, r[a] ||| r[b]} end,
      bori: fn a, b, c, r -> {c, r[a] ||| b} end,
      setr: fn a, _b, c, r -> {c, r[a]} end,
      seti: fn a, _b, c, _r -> {c, a} end,
      gtir: fn a, b, c, r -> {c, a ~> r[b]} end,
      gtri: fn a, b, c, r -> {c, r[a] ~> b} end,
      gtrr: fn a, b, c, r -> {c, r[a] ~> r[b]} end,
      eqir: fn a, b, c, r -> {c, a <~> r[b]} end,
      eqri: fn a, b, c, r -> {c, r[a] <~> b} end,
      eqrr: fn a, b, c, r -> {c, r[a] <~> r[b]} end
    ]
  end

  def a ~> b, do: if(a > b, do: 1, else: 0)

  def a <~> b, do: if(a == b, do: 1, else: 0)
end
