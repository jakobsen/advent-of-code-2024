defmodule AntennaMap do
  defstruct bounds: {0, 0, 0, 0}, antennas: Map.new()

  def new!(antennas) do
    antennas
    |> Enum.reduce(%AntennaMap{}, fn {freq, {i, j}},
                                     %__MODULE__{
                                       antennas: antennas,
                                       bounds: {i_min, j_min, i_max, j_max}
                                     } = map ->
      antennas =
        case freq do
          "." -> antennas
          x -> Map.update(antennas, x, [{i, j}], fn coords -> [{i, j} | coords] end)
        end

      bounds = {min(i, i_min), min(j, j_min), max(i, i_max), max(j, j_max)}
      %__MODULE__{map | bounds: bounds, antennas: antennas}
    end)
  end

  def find_antinodes(%__MODULE__{} = grid) do
    Enum.reduce(grid.antennas, MapSet.new(), fn {_freq, antennas}, found_antinodes ->
      antinodes(antennas)
      |> Enum.filter(&inside_map?(grid, &1))
      |> Enum.reduce(found_antinodes, fn antinodes, seen -> MapSet.put(seen, antinodes) end)
    end)
  end

  defp antinodes(coords) when is_list(coords) do
    for a <- coords, b <- coords, a != b, do: antinode_coords(a, b)
  end

  defp antinode_coords({i1, j1}, {i2, j2}) do
    dy = i1 - i2
    dx = j1 - j2
    {i1 + dy, j1 + dx}
  end

  defp inside_map?(%__MODULE__{bounds: {i_min, j_min, i_max, j_max}}, {i, j}) do
    i >= i_min and i <= i_max and j >= j_min and j <= j_max
  end
end

defmodule Day8 do
  def solve() do
    path = "input.txt"

    path |> parse() |> AntennaMap.find_antinodes() |> MapSet.size() |> IO.inspect()
  end

  defp parse(path) do
    File.read!(path)
    |> String.split("\n", trim: true)
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, i} ->
      line
      |> String.graphemes()
      |> Stream.with_index()
      |> Stream.map(fn
        {x, j} -> {x, {i, j}}
      end)
    end)
    |> AntennaMap.new!()
  end
end

Day8.solve()
