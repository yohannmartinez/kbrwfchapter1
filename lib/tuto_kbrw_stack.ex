defmodule KbrwFormation do
  use Application

  def start(_type, _args) do

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, KbrwFormation.Router, [], port: 4001),
      # Plug.Adapters.Cowboy.child_spec(:http, KbrwFormation.RouterNew, [], port: 4001),
    ]

    Application.put_env(
      :reaxt,:global_config,
      Map.merge(
        Application.get_env(:reaxt,:global_config), %{localhost: "http://localhost:4001"}
      )
    )
    Reaxt.reload

    Supervisor.start_link(children, strategy: :one_for_one)
    KbrwFormation.Supervisor.start_link()
  end
end
