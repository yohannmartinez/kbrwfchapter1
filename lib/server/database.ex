defmodule KbrwFormation.Database do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok , name: __MODULE__)
  end
  def init(arg) do
    :ets.new(:wrapper, [
      :set,
      :public,
      :named_table,
      {:read_concurrency, true},
      {:write_concurrency, true}
    ])
    {:ok, arg}
  end



  def get(key) do
    case :ets.lookup(:wrapper, key) do
      [] ->
        nil

      [{key, value}] ->
        {key, value}
    end
  end

  def put(key, value) do
    :ets.insert(:wrapper, {key, value})
  end

  def delete(key) do
    :ets.delete(:wrapper, key)
  end

  def update(key, value) do
    :ets.update_element(:wrapper, key, {2, value})
  end

  def search(filters) do
    orders_data = :ets.tab2list(:wrapper)

    Enum.filter(orders_data, fn {_key, map} ->
      checkOrder(filters, map)
    end)
  end

  defp checkOrder(filters, map) do
    check =
      Enum.filter(filters, fn filter ->
        Map.has_key?(map, elem(filter, 0)) and map[elem(filter, 0)] == elem(filter, 1)
      end)

    Enum.count(check) == Enum.count(filters)
  end
end
