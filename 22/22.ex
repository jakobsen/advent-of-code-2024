defmodule Day22 do
  import Bitwise

  def solve do
    path = "input.txt"

    all_secrets =
      path
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.map(fn x -> [String.to_integer(x)] end)
      |> Enum.map(&iterate(&1, 2000))

    p1 =
      all_secrets
      |> Enum.map(&hd/1)
      |> Enum.sum()

    all_diffs_with_prices =
      all_secrets
      |> Enum.map(&diffs_with_prices/1)

    all_sequences =
      for sequences <- all_diffs_with_prices,
          {sequence, _} <- sequences,
          reduce: MapSet.new() do
        acc -> MapSet.put(acc, sequence)
      end

    p2 =
      for sequence <- all_sequences do
        Enum.map(all_diffs_with_prices, fn diff_with_prices ->
          maybe_sell_at_sequence(diff_with_prices, sequence)
        end)
        |> Enum.sum()
      end
      |> Enum.max()

    {p1, p2}
  end

  def iterate(secrets, 1), do: secrets

  def iterate(secrets, times) do
    next_secret = secrets |> hd() |> gen_secret()
    iterate([next_secret | secrets], times - 1)
  end

  def maybe_sell_at_sequence(diff_with_prices, sequence) do
    case Map.fetch(diff_with_prices, sequence) do
      :error -> 0
      {:ok, price} -> price
    end
  end

  def diffs_with_prices(secrets) do
    prices =
      secrets
      |> Enum.reverse()
      |> Enum.map(&get_price/1)

    sequences =
      prices
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [a, b] -> b - a end)
      |> Enum.chunk_every(4, 1, :discard)

    Enum.zip([sequences, Enum.slice(prices, 4, length(prices))])
    |> Enum.reduce(%{}, fn {sequence, price}, acc -> Map.put_new(acc, sequence, price) end)
  end

  def get_price(secret) do
    rem(secret, 10)
  end

  def gen_secret(initial) do
    initial
    |> transform(fn x -> x * 64 end)
    |> transform(fn x -> div(x, 32) end)
    |> transform(fn x -> x * 2048 end)
  end

  def transform(value, callback) do
    callback.(value) |> mix(value) |> prune()
  end

  def mix(new, old), do: bxor(new, old)
  def prune(new), do: rem(new, 16_777_216)
end

{p1, p2} = Day22.solve()
IO.inspect(p1, label: "Part 1")
IO.inspect(p2, label: "Part 2")
