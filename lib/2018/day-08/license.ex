defmodule AoC2018.Day08.License do
  use AoC, year: 2018, day: 8

  defmodule Counter do
    use Agent

    def start_link(_) do
      Agent.start_link(fn -> 0 end, name: __MODULE__)
    end

    def gimme() do
      Agent.get_and_update(__MODULE__, fn count ->
        {count, count + 1}
      end)
    end
  end

  @doc """
  iex>part_one()
  36627
  """
  def part_one(file \\ "default.txt") do
    graph = build_graph(file)

    :digraph.vertices(graph)
    |> Enum.map(&:digraph.vertex(graph, &1))
    |> Enum.flat_map(&elem(&1, 1))
    |> Enum.sum()
  end

  @doc """
  iex>part_two()
  16695
  """
  def part_two(file \\ "default.txt") do
    graph = build_graph(file)

    node_value(0, graph)
  end

  defp node_value(node, graph) do
    :digraph.out_neighbours(graph, node)
    |> Enum.sort()
    |> case do
      [] ->
        :digraph.vertex(graph, node) |> elem(1) |> Enum.sum()

      children ->
        metas = :digraph.vertex(graph, node) |> elem(1)

        metas
        |> Enum.map(fn
          0 ->
            0

          n ->
            case Enum.at(children, n - 1) do
              nil -> 0
              child -> node_value(child, graph)
            end
        end)
        |> Enum.sum()
    end
  end

  defp build_graph(file) do
    Counter.start_link([])

    graph = :digraph.new([:acyclic])

    file
    |> read()
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> parse_node(graph)

    graph
  end

  defp parse_node([children, metas | rest], graph) do
    idx = Counter.gimme()

    {sons, rest} =
      children
      |> range()
      |> Enum.reduce({[], rest}, fn _, {children, acc} ->
        {child_idx, acc} = parse_node(acc, graph)
        {[child_idx | children], acc}
      end)

    {meta, rest} = Enum.split(rest, metas)

    :digraph.add_vertex(graph, idx, meta)

    sons
    |> Enum.each(&:digraph.add_edge(graph, idx, &1))

    {idx, rest}
  end

  defp range(from \\ 0, count)
  defp range(_from, 0), do: []
  defp range(from, count), do: from..(count + from - 1)
end
