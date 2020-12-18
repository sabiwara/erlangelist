defmodule Helper do
  def walk_list(list), do: walk_list(list, 0)

  defp walk_list([], sum), do: sum

  defp walk_list([head | tail], sum), do: walk_list(tail, head + sum)

  def walk_list_foldl(list) do
    List.foldl(list, 0, fn value, sum -> sum + value end)
  end

  def walk_array(array) do
    :array.foldl(
      fn _index, value, sum -> sum + value end,
      0,
      array
    )
  end

  def walk_vector(vector) do
    A.Vector.foldl(vector, 0, fn value, sum -> sum + value end)
  end

  def walk_vector_sum(vector) do
    A.Vector.sum(vector)
  end

  def walk_map(map, size), do: walk_map(map, 0, size, 0)

  defp walk_map(_map, index, index, sum), do: sum

  defp walk_map(map, index, size, sum),
    do: walk_map(map, index + 1, size, sum + Map.fetch!(map, index))

  def walk_tuple(tuple, size), do: walk_tuple(tuple, 0, size, 0)

  defp walk_tuple(_tuple, index, index, sum), do: sum

  defp walk_tuple(tuple, index, size, sum),
    do: walk_tuple(tuple, index + 1, size, sum + elem(tuple, index))
end

data =
  Bench.run(fn size ->
    list = Enum.to_list(0..(size - 1))
    array = :array.from_list(list)
    vector = A.Vector.new(list)
    map = list |> Enum.with_index() |> Enum.into(%{}, fn {val, index} -> {index, val} end)
    tuple = List.to_tuple(list)

    # list doesn't have the overhead of a lambda, adding two extra data points:
    # - `list foldl` to measure the overhead of a lambda for lists
    # - `vector sum` to measure without the overhead of a lambda for a vector
    [
      {"list", fn _ -> Helper.walk_list(list) end},
      {"list foldl", fn _ -> Helper.walk_list_foldl(list) end},
      {"array", fn _ -> Helper.walk_array(array) end},
      {"vector", fn _ -> Helper.walk_vector(vector) end},
      {"vector sum", fn _ -> Helper.walk_vector_sum(vector) end},
      {"map", fn _ -> Helper.walk_map(map, size) end},
      {"tuple", fn _ -> Helper.walk_tuple(tuple, size) end}
    ]
  end)

Chart.build(
  data,
  commands: [
    [:set, :title, "sequential walk"],
    [:set, :xlabel, "sequence size"],
    [:set, :format, :x, "%.0s%c"],
    [:set, :format, :y, "%.0s%cs"],
    [:set, :grid, :ytics]
  ]
)

Chart.build(
  data,
  commands: [
    [:set, :title, "sequential walk"],
    [:set, :xlabel, "sequence size"],
    [:set, :format, :x, "%.0s%c"],
    [:set, :format, :y, "%.0s%cs"],
    [:set, :grid, :xtics],
    [:set, :grid, :ytics],
    [:set, :logscale, :x, 10],
    [:set, :logscale, :y, 10]
  ]
)
