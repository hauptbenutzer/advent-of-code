"#{__DIR__}/input.txt"
|> File.stream!()
|> Stream.map(&Integer.parse/1)
|> Stream.map(&elem(&1, 0))
|> Stream.cycle()
|> Stream.scan(0, &+/2)
|> Enum.reduce_while(MapSet.new([0]), fn frequency, set ->
  if MapSet.member?(set, frequency) do
    {:halt, frequency}
  else
    {:cont, MapSet.put(set, frequency)}
  end
end)
|> IO.inspect()
