defmodule Day4 do
  def part1 do
    grid = create_grid()
    starts = find_start_coords(grid, "X")

    starts
    |> Enum.map(&count_words(&1, grid))
    |> Enum.sum()
  end

  def part2 do
    grid = create_grid()
    starts = find_start_coords(grid, "A")

    starts
    |> Enum.map(&count_stars(&1, grid))
    |> Enum.sum()
  end

  defp create_grid() do
    File.read!("04.txt")
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, row} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, col} -> {{row, col}, char} end)
    end)
    |> Map.new()
  end

  defp find_start_coords(grid, search_letter) when is_map(grid) and is_binary(search_letter) do
    for {coords, ^search_letter} <- grid, do: coords
  end

  defp count_words({row, col} = _start_coords, grid) when is_map(grid) do
    create_directions(row, col)
    |> Enum.map(&read_words(&1, grid))
    |> Enum.count(fn word -> word == "XMAS" end)
  end

  defp count_stars({row, col}, grid) when is_map(grid) do
    hits =
      create_star_directions(row, col)
      |> Enum.map(&read_words(&1, grid))
      |> Enum.filter(fn word -> word == "MAS" end)

    if length(hits) == 2, do: 1, else: 0
  end

  @spec create_directions(integer(), integer()) :: [{integer(), integer()}, ...]
  defp create_directions(row, col) do
    [
      # up
      for(dy <- 0..3, do: {row - dy, col}),
      #
      # right
      for(dx <- 0..3, do: {row, col + dx}),
      #
      # down
      for(dy <- 0..3, do: {row + dy, col}),
      #
      # left
      for(dx <- 0..3, do: {row, col - dx}),

      # diagonally up right
      for(d <- 0..3, do: {row - d, col + d}),

      # diagonally down right
      for(d <- 0..3, do: {row + d, col + d}),

      # diagonally down left
      for(d <- 0..3, do: {row + d, col - d}),

      # diagonally up left
      for(d <- 0..3, do: {row - d, col - d})
    ]
  end

  defp create_star_directions(row, col) do
    [
      # diagonally up right
      for(d <- -1..1, do: {row - d, col + d}),

      # diagonally down right
      for(d <- -1..1, do: {row + d, col + d}),

      # diagonally down left
      for(d <- -1..1, do: {row + d, col - d}),

      # diagonally up left
      for(d <- -1..1, do: {row - d, col - d})
    ]
  end

  defp read_words(coords, grid) when is_map(grid) do
    coords
    |> Enum.map(fn coord -> Map.get(grid, coord, "?") end)
    |> List.to_string()
  end
end

IO.inspect(Day4.part1(), label: "Part 1")
IO.inspect(Day4.part2(), label: "Part 2")
