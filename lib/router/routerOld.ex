# defmodule KbrwFormation.Router do
#   use Plug.Router
#   alias KbrwFormation.Database


#   plug(:match)

#   plug(Plug.Parsers,
#     parsers: [:json],
#     pass: ["application/json"],
#     json_decoder: Poison
#   )

#   plug(:dispatch)

#   get "/" do
#     conn
#     |> put_resp_content_type("application/json")
#     |> send_resp(200, Poison.encode!(%{}))
#   end

#   get "/getOne" do
#     conn = fetch_query_params(conn)
#     IO.inspect(conn)
#     result = Tuple.to_list(Database.get(conn.params["id"]))
#     send_resp(conn, 200, Poison.encode!(result))
#   end

#   get "/search" do
#     conn = fetch_query_params(conn)
#     params = Map.to_list(conn.params)
#     results = Database.search(params)
#     IO.inspect(results)
#     send_resp(conn, 200, Poison.encode!(results))
#   end

#   delete "/deleteOne" do
#     result = Database.delete(conn.body_params["id"])
#     send_resp(conn, 200, Poison.encode!(result))
#   end

#   post "/addToTable" do
#     result = Database.delete(conn.body_params["id"])
#     send_resp(conn, 200, Poison.encode!(result))
#   end

#   match _ , do: send_resp(conn, 404, "ooops route not defined")
# end
