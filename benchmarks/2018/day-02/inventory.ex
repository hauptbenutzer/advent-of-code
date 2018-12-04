list = AoC.read(2018, 2, "default.txt") |> String.split("\n")

comps = for a <- list, b <- list, a != b, do: {a, b}

Benchee.run(%{
  myers: fn -> for {a, b} <- comps, do: String.myers_difference(a, b) end,
  diff_chars: fn -> for {a, b} <- comps, do: AoC2018.Day02.Inventory.diff_chars(a, b) end
})
