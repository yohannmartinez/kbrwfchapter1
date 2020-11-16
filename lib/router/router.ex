defmodule KbrwFormation.Router do
  import Plug.Conn
  use Plug.Router
  alias KbrwFormation.Database

  plug(Plug.Static, from: "priv/static", at: "/static")
  plug(:match)
  plug(:dispatch)

  get "/api/orders" do
    # request should look like this localhost:4001/api/orders?sort=creation_date_index&page=3&rows=30&type=nat_order
    conn = fetch_query_params(conn)
    result = Database.getAll(conn.params)
    send_resp(conn, 200, Poison.encode!(result))
  end

  get "/api/order/:id" do
    result = Database.get(conn.params["id"])
    send_resp(conn, 200, Poison.encode!(result))
  end

  delete "/api/order/delete/:id" do
    result = Database.delete(conn.params["id"])
    send_resp(conn, 200, Poison.encode!(result))
  end

  get(_, do: send_file(conn, 200, "priv/static/index.html"))



end
