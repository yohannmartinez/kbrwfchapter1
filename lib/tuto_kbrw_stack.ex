defmodule KbrwFormation do
    use Application

    def start(_type, _args) do 

        :ets.new(:wrapper, [
            :set,
            :public,
            :named_table,
            {:read_concurrency, true},
            {:write_concurrency, true}
        ])

        KbrwFormation.Supervisor.start_link

    end
end
