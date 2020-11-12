defmodule KbrwFormation.Riak do
  use GenServer


  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(arg) do
    IO.inspect(arg)
    {:ok, arg}
  end

  #chapter 6 step 1 and two

  def getBuckets do
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} = :httpc.request(:get, {'http://127.0.0.1:8098/buckets?buckets=true', []}, [], [])
    Poison.decode!(body)
  end

  def getKeys(bucket) do
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} = :httpc.request(:get, {'http://127.0.0.1:8098/buckets/#{bucket}/keys?keys=true', []}, [], [])
    Poison.decode!(body)
  end

  def getObject(bucket, key) do
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} = :httpc.request(:get, {'http://127.0.0.1:8098/buckets/#{bucket}/keys/#{key}', []}, [], [])
    Poison.decode!(body)
  end
  def deleteObject(bucket, key) do
    {:ok, {{'HTTP/1.1', 204, 'No Content'}, _headers, body}} = :httpc.request(:delete, {'http://127.0.0.1:8098/buckets/#{bucket}/keys/#{key}', []}, [], [])
    Poison.decode!(body)
  end

  def addToBucket(bucket, key, data) do
    {:ok, {_status, _headers, body}} = :httpc.request(:post, {'http://127.0.0.1:8098/buckets/#{bucket}/keys/#{key}', [], 'application/json', data}, [], [])
    body
  end

  #chapter 6 step 1 and two


  def uploadSchema(schemaName, schemaLink) do
    schema = File.read!(schemaLink)
    :httpc.request(:put, {'http://127.0.0.1:8098/search/schema/#{schemaName}', [], 'application/xml', schema}, [], [])
  end

  def createIndex(indexName, schemaName) do
    :httpc.request(:put, {'http://127.0.0.1:8098//search/index/#{indexName}', [], 'application/xml', '{"schema": "#{schemaName}"}'}, [], [])
  end

  def deleteBucket(bucket) do
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} = :httpc.request(:get, {'http://127.0.0.1:8098/buckets/#{bucket}/keys?keys=true', []}, [], [])
    keys = Poison.decode!(body)
    case keys["keys"] do
      [] -> []

      _ -> Enum.map(keys["keys"], fn(key) ->
        {:ok, {{'HTTP/1.1', 204, 'No Content'}, _headers, body}} = :httpc.request(:delete, {'http://127.0.0.1:8098/buckets/#{bucket}/keys/#{key}', []}, [], [])
        body
      end)
    end
  end


end
