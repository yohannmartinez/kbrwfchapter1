defmodule JsonLoader do
    def load_to_database(_database, json_file) do 

        datas = File.read!(json_file) |> Poison.decode!
        Enum.map(datas, fn(data) -> KbrwFormation.Database.put(data["id"], data) end)
        
    end
end