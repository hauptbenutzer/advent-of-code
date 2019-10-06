defmodule AoC2017.Day13.Firewall do
  use AoC, year: 2017, day: 13

  defmodule Parser do
    import NimbleParsec

    defparsec(
      :parse_line,
      tag(integer(min: 1), :depth)
      |> concat(ignore(string(": ")))
      |> tag(integer(min: 1), :range)
      |> concat(optional(ignore(string("\n"))))
    )
  end

  defmodule Layer do
    use GenServer

    def init({depth, range}) do
      {:ok, {depth, range, 0}}
    end

    # 0 1 2 3 - 2 1

    # 0 1 2 3 4 - 3 2 1

    def handle_cast({:tick_by, n}, {depth, range, pos}) do
      {:noreply, {depth, range, rem(pos + n, 2 * range - 2)}}
    end

    def handle_cast(:reset, {depth, range, _pos}) do
      {:noreply, {depth, range, 0}}
    end

    def handle_call({:caught?, depth0}, _from, {depth, range, pos} = state) do
      if depth0 == depth && pos == 0 do
        {:reply, {true, depth, range}, state}
      else
        {:reply, false, state}
      end
    end

    def caught?(layer, depth) do
      GenServer.call(layer, {:caught?, depth})
    end

    def tick(layer) do
      GenServer.cast(layer, {:tick_by, 1})
    end

    def tick_by(layer, n) do
      GenServer.cast(layer, {:tick_by, n})
    end

    def reset(layer) do
      GenServer.cast(layer, :reset)
    end
  end

  def part_one(file \\ "default.txt") do
    layers =
      file
      |> stream()
      |> Stream.map(&Parser.parse_line/1)
      |> Stream.map(&elem(&1, 1))
      |> Enum.map(fn [depth: [depth], range: [range]] ->
        GenServer.start(Layer, {depth, range})
        |> elem(1)
      end)

    Enum.reduce(1..100, {-1, []}, fn _, {depth, caughts} ->
      depth = depth + 1

      caughts1 =
        Enum.reduce(layers, [], fn layer, caughts ->
          ret =
            case Layer.caught?(layer, depth) do
              {true, layer_depth, layer_range} -> [[depth: layer_depth, range: layer_range] | caughts]
              _ -> caughts
            end

          Layer.tick(layer)
          ret
        end)

      {depth, caughts ++ caughts1}
    end)
    |> elem(1)
    |> Enum.reduce(0, fn [depth: depth, range: range], acc -> depth * range + acc end)
  end

  def part_two(file \\ "default.txt") do
    layer_config =
      file
      |> stream()
      |> Stream.map(&Parser.parse_line/1)
      |> Stream.map(&elem(&1, 1))

    lcm =
      Enum.reduce(layer_config, 1, fn [_, {:range, [range]}], acc ->
        lcm(acc, range * 2 - 2)
      end)
      |> IO.inspect(label: "lcm")

    layers =
      layer_config
      |> Enum.map(fn [depth: [depth], range: [range]] ->
        GenServer.start(Layer, {depth, range})
        |> elem(1)
      end)

    Enum.reduce_while(1..lcm, layers, fn delay, layers ->
      Enum.each(layers, &Layer.tick_by(&1, delay))

      Enum.reduce_while(1..100, {-1, []}, fn _, {depth, _caughts} ->
        depth = depth + 1

        caughts1 =
          Enum.reduce_while(layers, [], fn layer, caughts ->
            ret =
              case Layer.caught?(layer, depth) do
                {true, layer_depth, layer_range} ->
                  {:halt, [[depth: layer_depth, range: layer_range] | caughts]}

                _ ->
                  {:cont, caughts}
              end

            Layer.tick(layer)
            ret
          end)

        if caughts1 != [] do
          {:halt, caughts1}
        else
          {:cont, {depth, caughts1}}
        end
      end)
      |> case do
        {_, []} ->
          {:halt, {:yeah, delay}}

        _caughts ->
          Enum.each(layers, &Layer.reset/1)
          if rem(delay, 100) == 0, do: IO.puts(to_string(delay))
          {:cont, layers}
      end
    end)
  end

  def gcd(a, 0), do: abs(a)
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(a, b), do: div(abs(a * b), gcd(a, b))
end
