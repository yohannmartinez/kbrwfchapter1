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

end