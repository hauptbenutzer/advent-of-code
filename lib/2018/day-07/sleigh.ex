# defmodule AoC2018.Day07.Sleigh do
#   use AoC, year: 2018, day: 7
#
#   defmodule Scheduler do
#     def done() do
#       GenServer.cast(:)
#     end
#
#   end
#
#   defmodule Worker do
#     use GenServer
#
#     def init(step_duration) do
#       {:ok, step_duration}
#     end
#
#     def handle_cast({:work, instr}, step_duration) do
#       instruction_sleep = instruction - ?A + 1
#       IO.puts("Working on #{<<instruction::utf8>>}")
#       Process.sleep((instruction_sleep + step_duration) * 100)
#       {:no_reply, step_duration}
#     end
#   end
#
#   @regex ~r{Step (?<first>.) must be finished before step (?<second>.) can begin.}
#   def part_one(file \\ "default.txt") do
#     file
#     |> instruction_stream()
#     |> Enum.join()
#   end
#
#   def part_two(file \\ "default.txt", opts \\ []) do
#     workers = Keyword.get(opts, :workers, 5)
#     step_duration = Keyword.get(opts, :step_duration, 60)
#
#     starttime = :os.system_time()
#
#     file
#     |> instruction_stream()
#     |> Task.async_stream(
#       fn <<instruction::utf8>> ->
#
#       end,
#       max_concurrency: workers
#     )
#     |> Stream.run()
#
#     IO.inspect(:os.system_time() - starttime)
#   end
#
#   def next_instruction(graph) do
#     next_v =
#       graph
#       |> :digraph.vertices()
#       |> Enum.filter(fn v -> :digraph.in_degree(graph, v) == 0 end)
#       |> Enum.sort()
#       |> List.first()
#
#     :digraph.del_vertex(graph, next_v)
#
#     next_v
#   end
#
#   def instruction_stream(file) do
#     graph =
#       file
#       |> stream()
#       |> Stream.map(fn line ->
#         Regex.named_captures(@regex, line)
#       end)
#       |> Enum.reduce(:digraph.new([:acyclic]), fn %{"first" => first, "second" => second},
#                                                   graph ->
#         :digraph.add_vertex(graph, first, first)
#         :digraph.add_vertex(graph, second, second)
#         :digraph.add_edge(graph, first, second)
#
#         graph
#       end)
#
#     Stream.resource(
#       fn -> nil end,
#       fn _ ->
#         case next_instruction(graph) do
#           nil -> {:halt, nil}
#           x -> {[x], nil}
#         end
#       end,
#       fn _ -> nil end
#     )
#   end
# end
