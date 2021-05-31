defmodule IdGenerator.EpochCounter do

  def child_spec(_args) do
    children = [Supervisor.child_spec({Redix, name: :redix}, id: Redix)]

    %{
      id: RedixSupervisor,
      type: :supervisor,
      start: {Supervisor, :start_link, [children, [strategy: :one_for_one]]}
    }
  end

  def increment() do
    with {:ok, [counter]} <- Redix.command(:redix, ["INCR", "epoch"]) do
      {:ok, counter}
    end
  end
end
