defmodule KbrwFormation do
  use Application

  def start(_type, _args) do

    children = [
        Plug.Adapters.Cowboy.child_spec(:http, KbrwFormation.Router, [], port: 8080)
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
    KbrwFormation.Supervisor.start_link()
  end
end
