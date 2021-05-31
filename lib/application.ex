defmodule IdGenerator.Application do
  @moduledoc false

  use Application

  alias IdGenerator.EpochCounter

  @impl true
  def start(_type, _args) do
    node_id = GlobalId.node_id()
    children = [
      EpochCounter.child_spec([]),
      {IdGenerator.Worker, [node_id]}
    ]

    opts = [strategy: :one_for_one, name: EtcdClient.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
