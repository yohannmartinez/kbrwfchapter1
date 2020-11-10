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
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, _body}} = :httpc.request(:get, {'http://127.0.0.1:8098/buckets?buckets=true', []}, [], [])
  end

  def getKeys(bucket) do
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, _body}} = :httpc.request(:get, {'http://127.0.0.1:8098/buckets/#{bucket}/keys?keys=true', []}, [], [])
  end

  def getObject do
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, _body}} = :httpc.request(:get, {'http://127.0.0.1:8098/buckets/test/keys/TM1lx4sFqr7BYVGUmwkivdDqDIW', []}, [], [])
  end
  def deleteObject do
    {:ok, {{'HTTP/1.1', 204, 'No Content'}, _headers, _body}} = :httpc.request(:delete, {'http://127.0.0.1:8098/buckets/test/keys/GTgzrcvpj6lE0VHbA6sOgSjiF5X', []}, [], [])
  end

  def addToBucket(data) do
    {:ok, {{'HTTP/1.1', 201, 'Created'}, _headers, _body}} = :httpc.request(:post, {'http://127.0.0.1:8098/buckets/test/keys', [], 'application/json', data}, [], [])
  end

  #chapter 6 step 1 and two


  # def uploadSchema(schemaLink) do
  #   schema = File.read!(schemaLink)
  #   IO.inspect(schema)
  #   schema = String.to_charlist(schema)
  #   :httpc.request(:put, {'http://127.0.0.1:8098/search/schema/test', [], 'application/xml', schema}, [], [])
  # end
end
