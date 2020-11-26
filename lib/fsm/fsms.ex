#create fsm machine state with just a handlers(rules) and execute the write fsm corresponding to the state sent in rules
defimpl ExFSM.Machine.State, for: Map do
    def state_name(order) do
    IO.inspect(order)
    [status] = order["status.state"]
    String.to_atom(status) end
    def set_state_name(order, name), do: Kernel.get_and_update_in(order["status.state"], fn state -> {state, Atom.to_string(name)} end)
    def handlers(order) do
        IO.inspect(order, label: "machine handler")
        {fsm, acc} = FSM.Rules.apply_rules(order, []) |> IO.inspect()
        IO.inspect(fsm, label: "fsm handled")
        fsm
    end
  end

defmodule FSM.Paypal do
    use ExFSM


    deftrans init({:process_payment, params}, order) do
        IO.inspect(params, label: "params are")
        case params do
            true -> {:next_state,:success,order}
            _ -> {:next_state,:failure,order}
        end
    end
end

defmodule FSM.Stripe do
    use ExFSM

    deftrans init({:process_payment,params},order) do
        IO.inspect("stripe")
        case params do
            true -> {:next_state,:success,order}
            _ -> {:next_state,:failure,order}
        end
    end
end

defmodule FSM.Delivery do
    use ExFSM

    deftrans init({:process_payment,params},order) do
        IO.inspect("delivery")
        case params do
            true -> {:next_state,:success,order}
            _ -> {:next_state,:failure,order}
        end
    end
end