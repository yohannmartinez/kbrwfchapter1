defmodule JsonLoader do
    def load_to_database(_database, json_file) do

        datas = File.read!(json_file) |> Poison.decode!
        IO.inspect(datas)
        Enum.map(datas, fn(data) -> KbrwFormation.Database.put(data["remoteid"], data) end)

    end
end
