defmodule AoC2018.Day15.Fight do
  use AoC, year: 2018, day: 15

  defmodule Unit do
    defstruct coord: {0, 0}, hit: 200, power: 3, race: :elf, id: ""
  end

  defp rand_id(length \\ 5) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end

  def combat(input) do
    cells =
      input
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        String.split(line, "", trim: true)
        |> Enum.with_index()
        |> Enum.map(fn {cell, x} -> {{x, y}, cell} end)
      end)

    graph = Graph.new()

    {units, grid, graph} =
      cells
      |> Enum.reduce({[], [], graph}, fn {coord, cell}, {units, grid, graph} ->
        case cell do
          "#" ->
            {units, grid, graph}

          "." ->
            graph = Graph.add_vertex(graph, coord)
            {units, [{coord, cell} | grid], graph}

          "E" ->
            graph = Graph.add_vertex(graph, coord)
            {[%Unit{coord: coord, race: :elf, id: rand_id()} | units], [{coord, "."} | grid], graph}

          "G" ->
            graph = Graph.add_vertex(graph, coord)
            {[%Unit{coord: coord, race: :goblin, id: rand_id()} | units], [{coord, "."} | grid], graph}
        end
      end)

    grid = Enum.into(grid, %{})

    graph =
      grid
      |> Enum.reduce(graph, fn {{x, y}, _cell}, graph ->
        graph = if grid[{x, y + 1}] == ".", do: add_path(graph, {x, y}, {x, y + 1}), else: graph
        graph = if grid[{x + 1, y}] == ".", do: add_path(graph, {x, y}, {x + 1, y}), else: graph
        graph
      end)

    graph =
      units
      |> Enum.reduce(graph, fn %Unit{coord: coord}, graph ->
        graph
        |> Graph.in_edges(coord)
        |> (&Graph.delete_edges(graph, &1)).()
      end)

    Graph.to_dot(graph) |> elem(1) |> (&File.write!("fight.dot", &1)).()

    rounds = Stream.iterate(1, &(&1 + 1))

    rounds
    |> Enum.reduce_while({units, graph}, fn round, {units, graph} ->
      units = sort_by_reading_order(units)

      # if rem(round, 20), do: IO.inspect(round, label: "round")

      {cont_halt, {units, graph}} =
        Enum.reduce_while(units, {:cont, {units, graph}}, fn unit, {_cont, {units, graph}} ->
          unit_grid = units |> Enum.into(%{}, fn %Unit{coord: coord} = unit -> {coord, unit} end)

          actual_id = unit.id

          case unit_grid[unit.coord] do
            nil ->
              # IO.inspect(unit, label: "Whoops, i am dead")
              {:cont, {:cont, {units, graph}}}

            %{id: ^actual_id} = unit ->
              # IO.inspect(unit, label: "me", syntax_colors: [map: IO.ANSI.blue()])
              targets = Enum.filter(units, &(&1.race != unit.race)) # |> IO.inspect(label: "targets")
              case targets do
                [] ->
                  {:halt, {:halt, {units, graph}}}

                targets ->
                  in_range =
                    Enum.flat_map(targets, &in_range_fields(&1, grid, unit_grid, unit))
                    # |> IO.inspect(label: "in range")

                  reachable =
                    Enum.filter(in_range, &reachable?(&1, unit, graph))
                    # |> IO.inspect(label: "reachable")

                  # TODO: figure out if we could pick the next step using a* heuristic
                  nearest = find_nearest(reachable, unit, graph) # |> IO.inspect(label: "nearest")
                  possible_steppies = Graph.out_neighbors(graph, unit.coord)

                  possible_steps = [unit.coord | possible_steppies]  # |> IO.inspect(label: "possible steps")

                  next_step = find_nearest(possible_steps, nearest, graph) # |> IO.inspect(label: "next step")

                  # if next_step == nil and unit.coord == {5, 2} and round == 24 do
                  #   require IEx
                  #   IEx.pry()
                  # end

                  current_pos = unit.coord
                  # Actually move
                  {moved_unit, graph} =
                    case next_step do
                      step when step == current_pos ->
                        # IO.puts("Not moving.")
                        {unit, graph}

                      nil ->
                        {unit, graph}

                      step ->
                        graph =
                          oh_dear_god(unit, grid)
                          |> Enum.reduce(graph, fn neighbour, graph ->
                            Graph.add_edge(graph, neighbour, unit.coord)
                          end)

                        graph =
                          graph
                          |> Graph.in_edges(step)
                          |> (&Graph.delete_edges(graph, &1)).()

                        # IO.inspect(step, label: "moving to")

                        {%Unit{unit | coord: step}, graph}
                    end

                  possible_attack_target = find_weakest_neighbour(moved_unit.coord, targets)

                  units =
                    if possible_attack_target do
                      # IO.inspect(possible_attack_target, label: "attacking..")
                      attack_unit(units, possible_attack_target)
                    else
                      units
                    end

                  units = update_units(units, unit, moved_unit)
                  {units, dead_units} = Enum.split_with(units, fn %Unit{hit: hit} -> hit > 0 end)

                  graph = Enum.reduce(dead_units, graph, fn unit, graph ->
                      oh_dear_god(unit, grid)
                      |> Enum.reduce(graph, fn neighbour, graph ->
                        Graph.add_edge(graph, neighbour, unit.coord)
                      end)
                  end)

                  {:cont, {:cont, {units, graph}}}
              end
            _ ->
              IO.inspect("This is some bullshit")
              {:cont, {:cont, {units, graph}}}
          end
        end)

      # IO.inspect(round, label: "after round")
      # print_grid(grid, units)

      case cont_halt do
        :cont -> {cont_halt, {units, graph}}
        :halt ->
          # print_grid(grid, units)

          {cont_halt, {units, graph, round}}
      end
    end)
    |> case do
      {units, _graph, round} ->
        # IO.inspect(units)
        # IO.inspect(round, label: "round")
        sum = Enum.map(units, &(&1.hit)) |> Enum.sum()
        sum * (round - 1)
    end
  end

  def print_grid(grid, units) do
    for y <- 0..10 do
      for x <- 0..10 do
        case grid[{x, y}] do
          "." ->
            unit = Enum.find(units, fn %{coord: coord} -> coord == {x, y} end)

            if unit do
              IO.write(String.first(to_string(unit.race)))
            else
              IO.write(".")
            end

          _ ->
            IO.write("#")
        end
      end

      units = sort_by_reading_order(units)

      for %{coord: {_x, y1}} = unit <- units, y == y1 do
        IO.write(" #{String.first(to_string(unit.race))}(#{unit.hit})")
      end

      IO.write("\n")
    end
  end

  def attack_unit(units, %{hit: hit} = victim_unit) do
    update_units(units, victim_unit, %{victim_unit | hit: hit - 3})
  end

  def update_units(units, old_unit, %{hit: new_hit} = new_unit) do
    Enum.map(units, fn
      unit when unit == old_unit ->
        new_unit

      unit ->
        unit
    end)
  end

  def find_weakest_neighbour(source, targets) do
    targets
    |> Enum.filter(&direct_neighbour?(source, &1.coord))
    |> nil_min(fn %{coord: {x, y}, hit: hit} -> {hit, y, x} end)
  end

  def nil_min([], _fun), do: nil
  def nil_min(list, fun), do: Enum.min_by(list, fun)

  def direct_neighbour?({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2) == 1

  def find_nearest(targets, %Unit{coord: source}, graph),
    do: find_nearest(targets, source, graph)

  def find_nearest(_targets, nil, _graph), do: nil

  def find_nearest(targets, source, graph) do
    nil_min(targets, fn {x, y} = target ->
      # The appended y, x makes sure we choose the nearest field in reading order
      case Graph.get_shortest_path(graph, source, target) do
        nil when source == target ->
          {-1, y, x}

        nil ->
          {:infinity, y, x}

        path ->
          {Enum.count(path), y, x}
      end
    end)
  end

  def reachable?(target, %Unit{coord: source}, graph) do
    target in Graph.reachable_neighbors(graph, [source]) or target == source
  end

  @adjacent [{0, -1}, {1, 0}, {0, 1}, {-1, 0}]
  def in_range_fields(%Unit{coord: {x, y}} = _target, grid, unit_grid, unit) do
    for {dx, dy} <- @adjacent,
        field = {x + dx, y + dy},
        grid[field] == "." and (unit_grid[field] == nil or unit_grid[field] == unit),
        do: field
  end

  def oh_dear_god(%Unit{coord: {x, y}} = _target, grid) do
    for {dx, dy} <- @adjacent,
        field = {x + dx, y + dy},
        grid[field] == ".", do: field
  end

  def sort_by_reading_order(units) do
    Enum.sort_by(units, fn %Unit{coord: {x, y}} -> {y, x} end)
  end

  def add_path(graph, v1, v2) do
    graph
    |> Graph.add_edge(v1, v2)
    |> Graph.add_edge(v2, v1)
  end
end
