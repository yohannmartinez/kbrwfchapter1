defmodule KbrwFormation.Database do
  use GenServer

  def init do
    {:ok, []}
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
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

  def search(filter_elements) do
    orders_data = :ets.tab2list(:wrapper)

    orders_list = Enum.map(orders_data, fn(order)->
      elem(order,0)
    end)

    #goal is to filter orders_list with filter_elements
  end

end
