defmodule KbrwFormation.Router do
  use Plug.Router
  alias KbrwFormation.Database

  plug Plug.Static, from: "priv/static", at: "/static"
  plug(:match)
  plug(:dispatch)

  get _, do: send_file(conn, 200, "priv/static/index.html")


  match _ , do: send_resp(conn, 404, "ooops route not defined")
end
