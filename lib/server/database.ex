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
    search_results = []
    case Enum.count(filter_elements) do
      #checking number of search filters and if 0 reply nil
      0 ->
        []
      _ ->
        #if search filters length > 0
        Enum.map(filter_elements, fn(filter_element) ->
          #key and value filters
          search_filter_key = elem(filter_element, 0)
          search_filter_value = elem(filter_element, 1)
          #retrieve all elements of ets table
          datas = :ets.tab2list(:wrapper)

          #check in each element of ets table if search filter exist
          Enum.map(datas, fn(data) ->
            new_data = Enum.at(Tuple.to_list(data), 1);
            case Map.has_key?(new_data, search_filter_key) and search_filter_value == new_data[search_filter_key] do
            #if filter match add order to search_results list
            true ->
              order_id = Enum.at(Tuple.to_list(data), 0)

            #last check to see if order doesn't already exist in search_results list
              case Enum.filter(search_results, fn(item) -> item["id"] == order_id end) do
                [] ->
                  IO.inspect(search_results)
                  List.insert_at(search_results, 0, data)
                _ ->
                  nil
              end
            false ->
              nil
            end
          end)
        end)
    end
    search_results
  end

end
