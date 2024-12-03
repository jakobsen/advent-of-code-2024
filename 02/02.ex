defmodule Day2 do
  def part1() do
    stream_input()
    |> Enum.count(&safe_report_variant?/1)
  end

  def part2() do
    stream_input()
    |> Enum.count(&safe_report?/1)
  end

  defp stream_input() do
    File.stream!("input.txt")
    |> Stream.map(fn line ->
      line
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp safe_report?(levels) do
    variations = for n <- 0..(length(levels) - 1), do: List.delete_at(levels, n)
    variations = [levels | variations]
    Enum.any?(variations, &safe_report_variant?/1)
  end

  defp safe_report_variant?(levels) do
    with {:ok, op} <- get_operator(levels) do
      all_acceptable_diffs?(levels, op)
    else
      _ -> false
    end
  end

  defp get_operator([first, second | _rest]) do
    cond do
      first < second ->
        {:ok, :lt}

      first > second ->
        {:ok, :gt}

      true ->
        :error
    end
  end

  defp all_acceptable_diffs?(levels, op) do
    levels
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(fn [first, second] ->
      diff =
        if op == :lt do
          second - first
        else
          first - second
        end

      diff in 1..3
    end)
  end
end

IO.inspect(Day2.part1(), label: "Part 1")
IO.inspect(Day2.part2(), label: "Part 2")
