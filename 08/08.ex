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

  def find_antinode_lines(%__MODULE__{} = grid) do
    Enum.reduce(grid.antennas, MapSet.new(), fn {_freq, antennas}, found_antinodes ->
      antinode_lines(antennas, grid.bounds)
      |> Enum.reduce(found_antinodes, fn antinodes, seen -> MapSet.union(antinodes, seen) end)
    end)
  end

  defp antinodes(coords) when is_list(coords) do
    for a <- coords, b <- coords, a != b, do: antinode_coords(a, b)
  end

  defp antinode_lines(coords, bounds) when is_list(coords) and is_tuple(bounds) do
    for a <- coords, b <- coords, a != b, do: antinode_line_coords(a, b, bounds)
  end

  defp antinode_coords({i1, j1}, {i2, j2}) do
    dy = i1 - i2
    dx = j1 - j2
    {i1 + dy, j1 + dx}
  end

  defp antinode_line_coords({i1, j1}, {i2, j2}, {i_min, j_min, i_max, j_max}) do
    dy = i2 - i1
    dx = j2 - j1
    # To find the smallest possible integer step, we need to find the gcd of dy and dx
    divisor = gcd(dy, dx)
    dy = div(dy, divisor)
    dx = div(dx, divisor)
    line = MapSet.new()

    line =
      Stream.iterate({i1, j1}, fn {i, j} -> {i + dy, j + dx} end)
      |> Stream.take_while(fn {i, j} ->
        i >= i_min and i <= i_max and j >= j_min and j <= j_max
      end)
      |> Enum.reduce(line, fn point, line -> MapSet.put(line, point) end)

    Stream.iterate({i1, j1}, fn {i, j} -> {i - dy, j - dx} end)
    |> Stream.take_while(fn {i, j} ->
      i >= i_min and i <= i_max and j >= j_min and j <= j_max
    end)
    |> Enum.reduce(line, fn point, line -> MapSet.put(line, point) end)
  end

  defp gcd(d, 0), do: d
  defp gcd(a, b), do: gcd(b, rem(a, b))

  defp inside_map?(%__MODULE__{bounds: {i_min, j_min, i_max, j_max}}, {i, j}) do
    i >= i_min and i <= i_max and j >= j_min and j <= j_max
  end
end

defmodule Day8 do
  def solve() do
    path = "input.txt"

    path |> parse() |> AntennaMap.find_antinodes() |> MapSet.size() |> IO.inspect(label: "Part 1")

    path
    |> parse()
    |> AntennaMap.find_antinode_lines()
    |> MapSet.size()
    |> IO.inspect(label: "Part 1")
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
