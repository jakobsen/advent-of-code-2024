defmodule StupidFile do
  # Should probably use a map for the memory with index as keys, but whatever
  defstruct memory: [], file_size: nil

  def new!(file) when is_list(file) do
    memory =
      file
      |> Stream.with_index()
      |> Enum.flat_map(fn {number, index} ->
        case rem(index, 2) do
          0 -> Stream.repeatedly(fn -> div(index, 2) end)
          1 -> Stream.repeatedly(fn -> nil end)
        end
        |> Stream.take(number)
        |> Enum.to_list()
      end)

    file_size = memory |> Enum.reject(&(&1 == nil)) |> length()

    %__MODULE__{memory: memory, file_size: file_size}
  end

  def defrag(%__MODULE__{} = file) do
    first_nil_at = Enum.find_index(file.memory, &(&1 == nil))

    last_element_at =
      file.memory
      |> Enum.reverse()
      |> Enum.find_index(&(&1 != nil))
      |> then(&corresponding_reverse_index(&1, length(file.memory)))

    do_defrag(file, first_nil_at, last_element_at)
  end

  def checksum(%__MODULE__{} = file) do
    file.memory
    |> Stream.with_index()
    |> Stream.reject(&is_nil/1)
    |> Stream.map(fn {val, idx} -> val * idx end)
    |> Enum.sum()
  end

  defp do_defrag(%__MODULE__{} = file, first_nil_at, last_element_at)
       when first_nil_at > last_element_at,
       do: file

  defp do_defrag(%__MODULE__{memory: memory} = file, first_nil_at, last_element_at) do
    {:ok, last_element} = Enum.fetch(memory, last_element_at)

    updated_memory =
      List.replace_at(memory, first_nil_at, last_element) |> List.replace_at(last_element_at, nil)

    first_nil_at = Enum.find_index(updated_memory, &(&1 == nil))

    last_element_at =
      updated_memory
      |> Enum.reverse()
      |> Enum.find_index(&(&1 != nil))
      |> then(&corresponding_reverse_index(&1, length(memory)))

    do_defrag(%__MODULE__{file | memory: updated_memory}, first_nil_at, last_element_at)
  end

  @spec corresponding_reverse_index(non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  defp corresponding_reverse_index(idx, length) when idx >= 0 and idx < length do
    length - idx - 1
  end
end

defmodule Day9 do
  def solve do
    "input.txt"
    |> File.read!()
    |> String.trim()
    |> String.to_integer()
    |> Integer.digits()
    |> StupidFile.new!()
    |> StupidFile.defrag()
    |> StupidFile.checksum()
    |> IO.inspect(label: "Part 1")
  end
end

Day9.solve()
