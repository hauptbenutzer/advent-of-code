"#{__DIR__}/input.txt"
|> File.stream!()
|> Stream.map(fn line ->
  case Integer.parse(line) do
    {int, _} -> int
  end
end)
|> Enum.sum()
|> IO.inspect
