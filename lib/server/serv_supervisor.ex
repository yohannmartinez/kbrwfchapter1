defmodule KbrwFormation.Supervisor do
    use Supervisor
    alias KbrwFormation.Database

    def start_link do
        Supervisor.start_link(__MODULE__, [])
    end

    def init(_) do
        children = [
            worker(Database, [])
        ]

        supervise(children, strategy: :one_for_one)
    end
end