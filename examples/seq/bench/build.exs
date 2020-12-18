defmodule Helper do
  def build_list(size), do: build_list(0, size)

  defp build_list(size, size), do: []

  defp build_list(value, size), do: [value | build_list(value + 1, size)]

  def build_array(size), do: build_array(:array.new(), 0, size)

  defp build_array(array, index, index), do: array

  defp build_array(array, index, size),
    do: build_array(:array.set(index, index, array), index + 1, size)

  def build_vector(size), do: build_vector(A.Vector.new(), 0, size)

  defp build_vector(vector, index, index), do: vector

  defp build_vector(vector, index, size),
    do: build_vector(A.Vector.append(vector, index), index + 1, size)

  def build_map(size), do: build_map(%{}, 0, size)

  defp build_map(map, index, index), do: map

  defp build_map(map, index, size),
    do: build_map(Map.put(map, index, index), index + 1, size)
end

incremental? = false

data =
  Bench.run(fn size ->
    benches = if incremental? do
      [
        {"array", fn _ -> Helper.build_array(size) end},
        {"vector", fn _ -> Helper.build_vector(size) end},
        {"map", fn _ -> Helper.build_map(size) end}
      ]
    else
      [
        {"array from list", &:array.from_list/1, init: &Helper.build_list/1},
        {"vector from list", &A.Vector.new/1, init: &Helper.build_list/1},
        {"map from list", &Map.new/1, init: fn size -> Enum.map(0..(size - 1), &{&1, &1}) end},
        {"tuple from list", &List.to_tuple/1, init: &Helper.build_list/1}
      ]
    end

    [{"list", fn _ -> Helper.build_list(size) end} | benches]
  end)

{"list", list_times} = Enum.find(data, &match?({"list", _values}, &1))

data =
  Enum.map(
    data,
    fn {key, values} ->
      if String.ends_with?(key, "from list") do
        values =
          values
          |> Enum.zip(list_times)
          |> Enum.map(fn {{size, value1}, {size, value2}} -> {size, value1 + value2} end)

        {key, values}
      else
        {key, values}
      end
    end
  )

title = if incremental? do "incremental build" else "build from list" end

Chart.build(
  data,
  commands: [
    [:set, :title, title],
    [:set, :xlabel, "sequence size"],
    [:set, :format, :x, "%.0s%c"],
    [:set, :format, :y, "%.0s%cs"],
    [:set, :grid, :ytics]
  ]
)
