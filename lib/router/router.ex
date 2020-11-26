defmodule KbrwFormation.Router do
  import Plug.Conn
  use Plug.Router
  alias KbrwFormation.Database

  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)

  require EEx
  EEx.function_from_file :defp, :layout, "web/layout.html.eex", [:render]
  plug Plug.Static, at: "/public", from: :kbrw_formation

  plug(:match)
  plug(:dispatch)

  def start(_, _) do
    Application.put_env(
      :reaxt,
      :global_config,
      Map.merge(
        Application.get_env(:reaxt, :global_config),
        %{localhost: "http://localhost:4001"}
      )
    )

    Reaxt.reload() 
  end

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

  post "/api/order/pay" do
    FSM.Pay.start_link(conn.body_params)
    payment = FSM.Pay.proceed_payment(true)
    object = KbrwFormation.Riak.getObject(payment["_yz_rb"],payment["_yz_rk"])
    newStatus = %{object["status"] | "state" => payment["status.state"]}
    updatedObject = %{object | "status" => newStatus}
    KbrwFormation.Riak.addToBucket(payment["_yz_rb"], payment["_yz_rk"], Poison.encode!(updatedObject))
    send_resp(conn, 200, Poison.encode!(updatedObject))
  end

  get _ do
    conn = fetch_query_params(conn)
    render = Reaxt.render!(:app, %{path: conn.request_path, cookies: conn.cookies, query: conn.params},30_000)
    send_resp(put_resp_header(conn,"content-type","text/html;charset=utf-8"), render.param || 200,layout(render))
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

end
