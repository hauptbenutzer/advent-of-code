defmodule AoC2017.Day03.Spiral do
  @doc """
  We can simply use our math here.

  17  16  15  14  13
  18   5   4   3  12
  19   6  [1]  2  11
  20   7   8  [9] 10
  21  22  23  24 [25]

  Looking at these numbers, we find that in each ring the largest number (bottom right corner) can be computed by
  (1 + 2*n)^2, where n denotes the ring. For any given number x we can then find our n (and thereby the ring x is on)
  by solving x = (1 + 2*n)^2, which is (sqrt(x) - 1)/2. We'll need to round up that result, as n is always an integer.

  We can further compute the side length of any given ring n with side(n) = 2*n + 1.

  Now, looking again at the numbers, we see that any square with the offset from on of the corners, can be reached in
  the same amount of steps, here for instance 12, 16, 20 and 24:

  17 [16] 15  14  13
  18   5   4   3 [12]
  19   6   1   2  11
  [20] 7   8   9  10
  21  22  23 [24] 25

  This cries modulo! We can see that we really only have 4 different interesting posititons here, as the corners are
  equivalent. All sides could be boiled down the following using modulo 4:

  25 10 11 12 13
  13 14 15 16 17
  17 18 19 20 21
  21 22 23 24 25
  --------------
   1  2  3  0  1  This is almost what we want, but we'll need to shift it in order to be able to go further
  --------------
   0  1  2  3  0  Much better! Now we can simply subtract 2, ignore the sign and be happy.
  --------------
   2  1  0  1  2  No we have 0 steps for the middle square and incremental steps on either side, perfect.

  Taking all of this into, account we can come up with the general formula

    | (x - 1) mod (side(n) - 1) - n | + n
       |       |                 |    |_ adding steps required to get the ring from the middle
       |       |                 |_ subtracting half of side length rounded up, and then ignoring sign (absolute)
       |       |_ modulo side length - 1
       |_ Shifting by one

  iex>part_one(347991)
  480
  """
  def part_one(number) do
    n = trunc(Float.ceil((:math.sqrt(number) - 1) / 2))
    side = trunc(2 * n + 1)

    n + abs(mod(number - 1, side - 1) - n)
  end

  @doc """
  147  142  133  122   59
  304    5    4    2   57
  330   10    1    1   54
  351   11   23   25   26
  362  747  806

  num(n)
  num(0) = 1
  num(1) = 1
  num(2) = 2
  num(3) = 4
  num(4) = 5
  """
  def part_two() do
  end

  defp mod(a, b), do: rem(rem(a, b) + b, b)
end
