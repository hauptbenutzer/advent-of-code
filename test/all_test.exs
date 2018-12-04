defmodule AoC.Test.DoctestAll do
  defmacro __before_compile__(_env) do
    {:ok, modules} = :application.get_key(:aoc, :modules)

    for module <- modules, module != AoC do
      quote do
        doctest unquote(module), import: true
      end
    end
  end
end

defmodule AoC.Test.All do
  @before_compile AoC.Test.DoctestAll

  use ExUnit.Case
end
