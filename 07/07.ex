defmodule Day7 do
  def solve() do
    path = "input.txt"

    tests =
      path
      |> parse()

    tests
    |> Stream.filter(&passes_test?(&1, 2))
    |> Enum.reduce(0, fn {test_value, _factors}, total -> total + test_value end)
    |> IO.inspect(label: "Part 1")

    tests
    |> Stream.filter(&passes_test?(&1, 3))
    |> Enum.reduce(0, fn {test_value, _factors}, total -> total + test_value end)
    |> IO.inspect(label: "Part 2")
  end

  def parse(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Stream.map(fn case ->
      [test_value, factor_list] = String.split(case, ": ")
      test_value = String.to_integer(test_value)
      factors = String.split(factor_list) |> Enum.map(&String.to_integer/1)
      {test_value, factors}
    end)
  end

  defp passes_test?({test_value, factors}, number_of_operators) do
    slots = length(factors) - 1

    0..number_of_combinations(slots, number_of_operators)
    |> Enum.any?(fn op_code ->
      ops = op_code |> Integer.digits(number_of_operators) |> pad_list(slots)
      test_value == calculate_test_case(factors, ops)
    end)
  end

  defp number_of_combinations(slots, ops_base) do
    Integer.pow(ops_base, slots) - 1
  end

  def calculate_test_case([first | rest] = factors, ops)
      when length(factors) - 1 == length(ops) do
    do_calculate_test_case(rest, ops, first)
  end

  defp do_calculate_test_case([], [], acc), do: acc

  defp do_calculate_test_case([next | rest], [op | ops], acc) when op in [0, 1, 2] do
    case op do
      0 -> do_calculate_test_case(rest, ops, next + acc)
      1 -> do_calculate_test_case(rest, ops, next * acc)
      2 -> do_calculate_test_case(rest, ops, concat(acc, next))
    end
  end

  defp concat(left, right) do
    List.flatten([Integer.digits(left), Integer.digits(right)]) |> Integer.undigits()
  end

  defp pad_list(list, min_length, value \\ 0) do
    if length(list) >= min_length do
      list
    else
      pad_list([value | list], min_length, value)
    end
  end
end

Day7.solve()
