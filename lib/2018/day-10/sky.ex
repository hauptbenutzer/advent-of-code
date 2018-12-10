defmodule AoC2018.Day10.Stars do
  alias AoC2018.Day10.Point

  defstruct frame: 0, points: []

  def min_max_x(%__MODULE__{points: points}) do
    %{x: left} = Enum.min_by(points, & &1.x)
    %{x: right} = Enum.max_by(points, & &1.x)
    {left, right}
  end

  def min_max_y(%__MODULE__{points: points}) do
    %{y: top} = Enum.min_by(points, & &1.y)
    %{y: bottom} = Enum.max_by(points, & &1.y)
    {top, bottom}
  end

  def move(%__MODULE__{points: points, frame: current_frame} = stars, frames \\ 1) do
    %{stars | points: Enum.map(points, &Point.move(&1, frames)), frame: current_frame + frames}
  end
end

defimpl Inspect, for: AoC2018.Day10.Stars do
  def inspect(%AoC2018.Day10.Stars{points: points, frame: frame} = stars, _) do
    {left, right} = AoC2018.Day10.Stars.min_max_x(stars)
    {top, bottom} = AoC2018.Day10.Stars.min_max_y(stars)
    points_map = Enum.into(points, %{}, fn %{x: x, y: y} -> {{x, y}, true} end)

    output =
      for y <- top..bottom do
        [
          "\n"
          | for x <- left..right do
              if Map.has_key?(points_map, {x, y}), do: "#", else: " "
            end
        ]
      end

    IO.iodata_to_binary(["Stars @ Frame #{frame}:\n" | output])
  end
end

defimpl Collectable, for: AoC2018.Day10.Stars do
  def into(%AoC2018.Day10.Stars{}) do
    {
      [],
      fn
        acc, {:cont, line} when is_binary(line) ->
          [AoC2018.Day10.Point.from_string(line) | acc]

        acc, :done ->
          %AoC2018.Day10.Stars{points: acc}

        _, :halt ->
          :ok
      end
    }
  end
end

defmodule AoC2018.Day10.Point do
  defstruct x: 0, y: 0, dx: 0, dy: 0

  def move(%{x: x, y: y, dx: dx, dy: dy} = point, frames) do
    %{point | x: x + dx * frames, y: y + dy * frames}
  end

  @regex ~r{position=<\s*(?<x>-?\d+),\s*(?<y>-?\d+)> velocity=<\s*(?<dx>-?\d+),\s*(?<dy>-?\d+)>}
  def from_string(line) do
    Regex.named_captures(@regex, line)
    |> case do
      %{"x" => x, "y" => y, "dx" => dx, "dy" => dy} ->
        %__MODULE__{
          x: String.to_integer(x),
          y: String.to_integer(y),
          dx: String.to_integer(dx),
          dy: String.to_integer(dy)
        }
    end
  end
end

defmodule AoC2018.Day10.Sky do
  use AoC, year: 2018, day: 10
  alias AoC2018.Day10.Stars

  def align_stars(file \\ "default.txt") do
    file
    |> stream()
    |> Enum.into(%Stars{})
    |> find_message()
  end

  def find_message(stars), do: _find_message(stars, 0, :infinity)

  def _find_message(stars, frame, current_min) do
    stars = Stars.move(stars)
    {top, bottom} = Stars.min_max_y(stars)
    height = bottom - top

    if height > current_min do
      IO.puts("Found local minimum at frame #{frame}")
      Stars.move(stars, -1)
    else
      _find_message(stars, frame + 1, height)
    end
  end
end
