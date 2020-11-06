defmodule KbrwFormation.Database do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
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
        []

      [{key, value}] ->
        value
    end
  end

  def getAll do
    orders = :ets.tab2list(:wrapper)
    Enum.map(orders, fn {_key, value} -> value end)
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
    orders_toMap = Enum.map(orders_data, fn {key, map} -> %{"id" => key, "order" => map} end)
    IO.inspect(orders_toMap)
    Enum.filter(orders_toMap, fn (order) ->
      checkOrder(filters, order["order"])
    end
    )

  end

  defp checkOrder(filters, map) do
    check =
      Enum.filter(filters, fn filter ->
        Map.has_key?(map, elem(filter, 0)) and map[elem(filter, 0)] == elem(filter, 1)
      end)

    Enum.count(check) == Enum.count(filters)
  end
end
