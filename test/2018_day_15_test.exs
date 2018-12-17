defmodule AoC2018.Test.Day15 do
  use ExUnit.Case

  test "example 1" do
    input = """
    #######
    #.G...#
    #...EG#
    #.#.#G#
    #..G#E#
    #.....#
    #######
    """

    assert AoC2018.Day15.Fight.combat(input) == 27730
  end

  test "example 2" do
    input = """
    #######
    #G..#E#
    #E#E.E#
    #G.##.#
    #...#E#
    #...E.#
    #######
    """

    assert AoC2018.Day15.Fight.combat(input) == 36334
  end

  test "ex 3" do
    input = """
    #######
    #E..EG#
    #.#G.E#
    #E.##E#
    #G..#.#
    #..E#.#
    #######
    """

    assert AoC2018.Day15.Fight.combat(input) == 39514
  end

  test "ex 4" do
    input = """
    #######
    #E.G#.#
    #.#G..#
    #G.#.G#
    #G..#.#
    #...E.#
    #######
    """

    assert AoC2018.Day15.Fight.combat(input) == 27755
  end

  test "ex 5" do
    input = """
    #######
    #.E...#
    #.#..G#
    #.###.#
    #E#G#G#
    #...#G#
    #######
    """

    assert AoC2018.Day15.Fight.combat(input) == 28944
  end

  test "ex 6" do
    input = """
    #########
    #G......#
    #.E.#...#
    #..##..G#
    #...##..#
    #...#...#
    #.G...G.#
    #.....G.#
    #########
    """

    assert AoC2018.Day15.Fight.combat(input) == 18740
  end
end
