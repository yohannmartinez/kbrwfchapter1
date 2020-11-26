defmodule FSM.Pay do
    use GenServer
    require Logger

    def start_link(order) do
        GenServer.start_link(__MODULE__, order, name: __MODULE__)
    end

    def init(order) do
        IO.inspect("arguments are")
        IO.inspect(order)
        {:ok, order}
    end

    def proceed_payment(status) do
        GenServer.call(FSM.Pay, {:proceed_payment,status})
    end

    def handle_call({:proceed_payment,status}, _from, state) do
        {:next_state, updated_order} = ExFSM.Machine.event(state, {:process_payment, status})
        {old_state, new_order} = updated_order
        IO.inspect(new_order)
        {:reply, new_order, new_order}
    end
end