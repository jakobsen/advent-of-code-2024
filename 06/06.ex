defmodule Grid do
  defstruct guard_position: nil,
            obstruction_coords: MapSet.new(),
            direction: :up,
            max_row: 0,
            max_col: 0

  def new!(map) when is_list(map) do
    map
    |> Stream.with_index()
    |> Stream.flat_map(fn {row, row_idx} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {symbol, col_idx} -> {symbol, {row_idx, col_idx}} end)
    end)
    |> Enum.reduce(%Grid{}, fn {symbol, {row, col}}, grid ->
      grid = maybe_update_max_coords(grid, {row, col})

      case symbol do
        "#" -> add_obstruction(grid, {row, col})
        "^" -> set_guard_position(grid, {row, col})
        _ -> grid
      end
    end)
  end

  def maybe_update_max_coords(%Grid{max_row: max_row, max_col: max_col} = grid, {row, col}) do
    %Grid{grid | max_row: max(max_row, row), max_col: max(max_col, col)}
  end

  def add_obstruction(%Grid{obstruction_coords: obstruction_coords} = grid, coords) do
    %Grid{grid | obstruction_coords: MapSet.put(obstruction_coords, coords)}
  end

  def set_guard_position(%Grid{} = grid, guard_position) do
    %Grid{grid | guard_position: guard_position}
  end

  def turn(%Grid{direction: direction} = grid) do
    new_direction =
      case direction do
        :up -> :right
        :right -> :down
        :down -> :left
        :left -> :up
      end

    %Grid{grid | direction: new_direction}
  end

  def loop?(%Grid{obstruction_coords: obstruction_coords} = grid, {new_row, new_col}) do
    grid = %Grid{grid | obstruction_coords: MapSet.put(obstruction_coords, {new_row, new_col})}
    walk(grid) == :loop
  end

  def walk(%Grid{} = grid) do
    # This is stupid, but it works
    do_walk(grid, MapSet.new([grid.guard_position]), 10_000)
  end

  defp do_walk(_grid, _visited, 0 = _steps_left) do
    :loop
  end

  defp do_walk(
         %Grid{guard_position: {row, col}, max_col: max_col, max_row: max_row},
         visited,
         _steps_left
       )
       when row < 0 or col < 0 or row > max_row or col > max_col do
    MapSet.delete(visited, {row, col})
  end

  defp do_walk(%Grid{} = grid, visited, steps_left) do
    {row, col} = grid.guard_position
    {dy, dx} = get_diff(grid.direction)
    maybe_next_position = {row + dy, col + dx}

    if maybe_next_position in grid.obstruction_coords do
      grid = turn(grid)
      do_walk(grid, visited, steps_left - 1)
    else
      grid = %Grid{grid | guard_position: maybe_next_position}
      visited = MapSet.put(visited, maybe_next_position)
      do_walk(grid, visited, steps_left - 1)
    end
  end

  defp get_diff(direction) do
    case direction do
      :up -> {-1, 0}
      :right -> {0, 1}
      :down -> {1, 0}
      :left -> {0, -1}
    end
  end
end

defmodule Day6 do
  def solve do
    path = "input.txt"

    path |> part1() |> IO.inspect(label: "Part 1")
    path |> part2() |> IO.inspect(label: "Part 2")
  end

  defp part1(path) do
    create_grid(path)
    |> Grid.walk()
    |> MapSet.size()
  end

  defp part2(path) do
    grid = create_grid(path)
    start_position = grid.guard_position

    grid |> Grid.walk() |> MapSet.delete(start_position) |> Enum.count(&Grid.loop?(grid, &1))
  end

  defp create_grid(path) do
    File.read!(path)
    |> String.split()
    |> Grid.new!()
  end
end

Day6.solve()
