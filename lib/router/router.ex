defmodule KbrwFormation.Router do
  use Plug.Router
  alias KbrwFormation.Database

  plug :match
  plug :dispatch

  get "/getOne" do
    conn = fetch_query_params(conn)
    get_resp = Database.get("test")
    IO.inspect(get_resp)
    send_resp(conn, 200, "its okay")
  end

  match _ , do: send_resp(conn, 404, "ooops route not defined")
end
