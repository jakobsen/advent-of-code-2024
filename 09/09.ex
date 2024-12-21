defmodule FileBlock do
  defstruct value: nil, size: nil, id: nil
end

defmodule OkayFile do
  defstruct blocks: []

  def new!(file) when is_list(file) do
    file
    |> Stream.with_index()
    |> Enum.map(fn {number, index} ->
      case rem(index, 2) do
        0 -> %FileBlock{value: div(index, 2), size: number, id: make_ref()}
        1 -> %FileBlock{value: nil, size: number, id: make_ref()}
      end
    end)
    |> then(fn blocks -> %__MODULE__{blocks: blocks} end)
  end

  def checksum(%__MODULE__{} = file) do
    Enum.flat_map(file.blocks, fn block ->
      Stream.repeatedly(fn -> if is_nil(block.value), do: 0, else: block.value end)
      |> Enum.take(block.size)
    end)
    |> Enum.with_index()
    |> Enum.reduce(0, fn {value, idx}, acc -> acc + value * idx end)
  end

  def defrag(%__MODULE__{} = file) do
    # Process the files in reverse order
    blocks_to_process =
      file.blocks
      |> Enum.reject(fn %FileBlock{} = block -> is_nil(block.value) end)
      |> Enum.reverse()

    do_defrag(file, blocks_to_process)
  end

  defp do_defrag(%__MODULE__{} = file, []), do: file

  defp do_defrag(%__MODULE__{} = file, [block_to_process | rest]) do
    # Take the given file block and see if it fits anywhere, i.e. find the first FileBlock with value nil and size
    # >= the fileblock to replace.
    # If there is such a block: Put it in front of the nil block, and deduct the size of the file from the size of the nil block.
    # If the size goes to 0, remove it. Replace the file block with a nil block.
    old_block_idx = Enum.find_index(file.blocks, &(&1 == block_to_process))

    case Enum.find_index(file.blocks, fn %FileBlock{} = block ->
           is_nil(block.value) and block.size >= block_to_process.size
         end) do
      idx when not is_nil(idx) and idx < old_block_idx ->
        null_block = Enum.at(file.blocks, idx)

        updated_blocks =
          List.insert_at(file.blocks, idx, block_to_process)
          |> List.replace_at(old_block_idx + 1, %{block_to_process | value: nil})

        updated_blocks =
          case null_block.size - block_to_process.size do
            0 ->
              List.delete_at(updated_blocks, idx + 1)

            x ->
              List.replace_at(updated_blocks, idx + 1, %{null_block | size: x})
          end

        do_defrag(%__MODULE__{file | blocks: updated_blocks}, rest)

      _ ->
        # Nowhere to move the block, continue processing without taking any action
        do_defrag(file, rest)
    end
  end
end

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
    path = "input.txt"

    digits =
      path
      |> File.read!()
      |> String.trim()
      |> String.to_integer()
      |> Integer.digits()

    digits
    |> StupidFile.new!()
    |> StupidFile.defrag()
    |> StupidFile.checksum()
    |> IO.inspect(label: "Part 1")

    digits
    |> OkayFile.new!()
    |> OkayFile.defrag()
    |> OkayFile.checksum()
    |> IO.inspect(label: "Part 2")
  end
end

Day9.solve()
