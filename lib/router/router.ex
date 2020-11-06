defmodule KbrwFormation.Router do
  import Plug.Conn
  use Plug.Router
  alias KbrwFormation.Database

  plug(Plug.Static, from: "priv/static", at: "/static")
  plug(:match)
  plug(:dispatch)

  get "/api/orders" do
    result = Database.getAll()
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
