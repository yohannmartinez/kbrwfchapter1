defmodule KbrwFormation.Riak do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(arg) do
    IO.inspect(arg)
    {:ok, arg}
  end

  # chapter 6 step 1 and two

  def getBuckets do
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} =
      :httpc.request(:get, {'http://127.0.0.1:8098/buckets?buckets=true', []}, [], [])

    Poison.decode!(body)
  end

  def getKeys(bucket) do
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} =
      :httpc.request(:get, {'http://127.0.0.1:8098/buckets/#{bucket}/keys?keys=true', []}, [], [])
    keys = Poison.decode!(body)
    keys["keys"]
  end

  def getObject(bucket, key) do
    {:ok, {_status, _headers, body}} =
      :httpc.request(:get, {'http://127.0.0.1:8098/buckets/#{bucket}/keys/#{key}', []}, [], [])

    Poison.decode!(body)
  end

  def deleteObject(bucket, key) do
    {:ok, {{'HTTP/1.1', 204, 'No Content'}, _headers, body}} =
      :httpc.request(:delete, {'http://127.0.0.1:8098/buckets/#{bucket}/keys/#{key}', []}, [], [])

    Poison.decode!(body)
  end

  def addToBucket(bucket, key, data) do
    {:ok, {_status, _headers, body}} =
      :httpc.request(
        :post,
        {'http://127.0.0.1:8098/buckets/#{bucket}/keys/#{key}', [], 'application/json', data},
        [],
        []
      )

    body
  end

  def uploadSchema(schemaName, schemaLink) do
    schema = File.read!(schemaLink)
    # :httpc.request(:get, {'http://127.0.0.1:8098/search/schema/orders', []},[],[])

    :httpc.request(
      :put,
      {'http://127.0.0.1:8098/search/schema/#{schemaName}', [], 'application/xml', schema},
      [],
      []
    )
  end

  def createIndex(indexName, schemaName) do
    :httpc.request(
      :put,
      {'http://127.0.0.1:8098//search/index/#{indexName}', [], 'application/json',
       '{"schema": "#{schemaName}"}'},
      [],
      []
    )
  end

  def deleteIndex(indexName) do
    :httpc.request(:delete, {'http://127.0.0.1:8098/search/index/#{indexName}', []}, [], [])
  end

  def linkBucketToIndex(bucket, index) do
    :httpc.request(
      :put,
      {'http://127.0.0.1:8098/buckets/#{bucket}/props', [], 'application/json',
       '{"props":{"search_index":"#{index}"}}'},
      [],
      []
    )
  end

  def deleteBucket(bucket) do
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} =
      :httpc.request(:get, {'http://127.0.0.1:8098/buckets/#{bucket}/keys?keys=true', []}, [], [])

    keys = Poison.decode!(body)

    case keys["keys"] do
      [] ->
        []

      _ ->
        Enum.map(keys["keys"], fn key ->
          {:ok, {{'HTTP/1.1', 204, 'No Content'}, _headers, body}} =
            :httpc.request(
              :delete,
              {'http://127.0.0.1:8098/buckets/#{bucket}/keys/#{key}', []},
              [],
              []
            )

          body
        end)
    end
  end

  def search(index, query, page \\ 0, rows \\ 30 , sort \\ "creation_date_index") do
    #exemple of query with all parameters http://127.0.0.1:8098/search/query/orders/?wt=json&q=type:%22nat_order%22&rows=30&start=90&sort=_yz_rk%20desc
    {:ok, {_status, _headers, body}} = :httpc.request(:get, {'http://127.0.0.1:8098/search/query/#{index}/?wt=json&q=#{query}&rows=#{rows}&start=#{page * rows}&sort=#{sort}%20desc', []}, [], [])
    Poison.decode!(body)
  end

  def reindexObjects(bucket) do 
    KbrwFormation.Riak.getKeys(bucket)
      |> Enum.map(
        fn key ->
          object = KbrwFormation.Riak.getObject("orders", key)
          newStatus = %{object["status"] | "state" => "init"}
          newObject = %{object | "status" => newStatus}
          newObject["status"]["state"]
          KbrwFormation.Riak.addToBucket("orders", key, Poison.encode!(newObject))
        end)
    end 

  def initialize_commands(bucket) do 
    KbrwFormation.Riak.getKeys(bucket)
      |> Enum.map(
        fn key ->
          object = KbrwFormation.Riak.getObject(bucket, key)
          newStatus = %{object["status"] | "state" => "init"}
          newObject = %{object | "status" => newStatus}
          finalObject = Map.put(newObject, "payment_method", "paypal")
          KbrwFormation.Riak.addToBucket(bucket, key, Poison.encode!(finalObject))
        end)
    end 
end
