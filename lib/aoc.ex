defmodule AoC do
  @moduledoc """
  Convenience for AoC.
  """

  defmacro __using__(opts) do
    year = Keyword.fetch!(opts, :year)
    day = Keyword.fetch!(opts, :day)

    quote do
      def read(file \\ "default.txt"),
        do: unquote(__MODULE__).read(unquote(year), unquote(day), file)

      def stream(file \\ "default.txt"),
        do: unquote(__MODULE__).stream(unquote(year), unquote(day), file)
    end
  end

  def read(year, day, file) do
    File.read!(resource_path(year, day, file))
  end

  def stream(year, day, file) do
    File.stream!(resource_path(year, day, file))
  end

  defp resource_path(year, day, file),
    do: "./resources/#{year}/day-#{String.pad_leading(to_string(day), 2, ["0"])}/#{file}"
end
