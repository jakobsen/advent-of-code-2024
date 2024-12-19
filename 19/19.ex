defmodule Day19 do
  def solve do
    path = "input.txt"

    {:ok, {patterns, designs}} =
      path
      |> File.read!()
      |> String.split("\n\n", trim: true)
      |> parse()

    dbg()
    Enum.map(designs, &possible?(patterns, &1)) |> Enum.sum()
  end

  def parse([patterns, designs]) do
    patterns = String.split(patterns, ", ", trim: true)
    designs = String.split(designs)
    {:ok, {patterns, designs}}
  end

  def possible?(_patterns, ""), do: 1

  def possible?(patterns, design) do
    # Greedy search doesn't work, need to search all candidates
    case Enum.filter(patterns, fn pattern -> String.starts_with?(design, pattern) end) do
      nil ->
        0

      candidates ->
        Enum.map(
          candidates,
          fn candidate ->
            possible?(
              patterns,
              String.slice(design, String.length(candidate)..String.length(design))
            )
          end
        )
        |> Enum.sum()
    end
  end
end

IO.puts(Day19.solve())
