defmodule JsonLoader do
    def load_to_database(bucket, json_file) do

        datas = File.read!(json_file) |> Poison.decode!
        Enum.map(datas, fn(data) -> KbrwFormation.Riak.addToBucket(bucket, data["remoteid"] , Poison.encode!(data)) end)

    end
end
