defmodule KbrwFormation.Supervisor do
    use Supervisor
    alias KbrwFormation.Database
    alias KbrwFormation.Riak

    def start_link do
        Supervisor.start_link(__MODULE__, [])
    end

    def init(_) do
        children = [
            worker(Database, []),
            worker(Riak, []),
        ]

        supervise(children, strategy: :one_for_one)
    end
end
