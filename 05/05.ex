defmodule Day5 do
  def part1() do
    {:ok, {rules, manuals}} = parse_input()

    manuals
    |> Enum.filter(&follows_rules?(&1, rules))
    |> Enum.map(&middle_page/1)
    |> Enum.sum()
  end

  def part2() do
    {:ok, {rules, manuals}} = parse_input()

    manuals
    |> Enum.reject(&follows_rules?(&1, rules))
    |> Enum.map(&sort(&1, rules))
    |> Enum.map(&middle_page/1)
    |> Enum.sum()
  end

  defp parse_input() do
    [rules, manuals] = File.read!("input.txt") |> String.split("\n\n", trim: true)

    rules =
      rules
      |> String.split()
      |> Enum.reduce(%{}, fn rule, rules_map ->
        [first, last] = String.split(rule, "|")
        Map.update(rules_map, first, MapSet.new([last]), &MapSet.put(&1, last))
      end)

    manuals = manuals |> String.split() |> Enum.map(&String.split(&1, ","))

    {:ok, {rules, manuals}}
  end

  defp follows_rules?(manual, rules) do
    do_check_manual(manual, rules, MapSet.new())
  end

  defp do_check_manual([], _rules, _seen), do: true

  defp do_check_manual([page | rest], rules, seen) do
    relevant_rules = Map.get(rules, page, MapSet.new())

    if MapSet.disjoint?(relevant_rules, seen) do
      do_check_manual(rest, rules, MapSet.put(seen, page))
    else
      false
    end
  end

  defp sort(manual, rules) do
    Enum.sort(manual, fn a, b -> a in Map.get(rules, b, MapSet.new()) end)
  end

  defp middle_page(manual) when rem(length(manual), 2) == 1 do
    middle_index = div(length(manual), 2)
    manual |> Enum.at(middle_index) |> String.to_integer()
  end
end

Day5.part1() |> IO.inspect(label: "Part 1")
Day5.part2() |> IO.inspect(label: "Part 2")
