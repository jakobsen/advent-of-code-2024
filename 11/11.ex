defmodule Day11 do
  def solve do
    path = "input.txt"

    stones =
      path
      |> File.read!()
      |> String.split()
      |> Enum.map(&String.to_integer/1)
      |> Enum.reduce(%{}, fn stone, acc -> Map.update(acc, stone, 1, &(&1 + 1)) end)

    stones
    |> iterate(25)
    |> IO.inspect(label: "Part 1")

    stones
    |> iterate(75)
    |> IO.inspect(label: "Part 2")
  end

  def iterate(stones, 0), do: Enum.sum_by(stones, fn {_, x} -> x end)

  def iterate(stones, times) do
    stones
    |> Map.to_list()
    |> blink()
    |> iterate(times - 1)
  end

  def blink(stones, acc \\ %{})
  def blink([], acc), do: acc

  def blink([{0, n} | rest], acc) do
    blink(rest, Map.update(acc, 1, n, &(&1 + n)))
  end

  def blink([{x, n} | rest], acc) do
    if even_number_of_digits?(x) do
      {a, b} = split_in_two(x)
      acc |> Map.update(a, n, &(&1 + n)) |> Map.update(b, n, &(&1 + n)) |> then(&blink(rest, &1))
    else
      blink(rest, Map.update(acc, x * 2024, n, &(&1 + n)))
    end
  end

  defp even_number_of_digits?(integer) do
    integer |> Integer.digits() |> length() |> rem(2) == 0
  end

  defp split_in_two(integer) do
    digits = Integer.digits(integer)
    half = length(digits) |> div(2)
    {a, b} = digits |> Enum.split(half)
    {Integer.undigits(a), Integer.undigits(b)}
  end
end

Day11.solve()
