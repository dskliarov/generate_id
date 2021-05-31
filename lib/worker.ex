defmodule IdGenerator.Worker do
  use GenServer

  @max_counter :math.pow(2, 18)

  alias IdGenerator.EpochCounter

  @retry_timeout 500

  #########################################################
  #
  #   API
  #
  #########################################################

  def start_link(node_id),
    do: GenServer.start(__MODULE__, node_id, name: __MODULE__)

  def get_id(resource_name), do: GenServer.call(__MODULE__, {:get_id, resource_name})

  def is_ready? do
    case GenServer.call(__MODULE__, :is_ready) do
      {:ok, :ready} ->
        true
      {:error, :not_ready} ->
        false
    end
  end

  #########################################################
  #
  #   Callbacks
  #
  #########################################################

  @impl true
  def init(node_id) do
    state = initial_state(node_id)
    {:ok, state, {:continue, :new_epoch}}
  end

  @impl true
  def handle_continue(:new_epoch, state) do
    case EpochCounter.increment() do
      {:ok, epoch} ->
        {:noreply, %{state | counter: %{}, epoch: epoch, ready: true}}
      {:error, _} ->
        {:noreply, %{state | ready: false}, @retry_timeout}
    end
  end

  @impl true
  def handle_call(_any_command, _from, %{ready: false} = state),
    do: {:reply, {:error, :not_ready}, state}

  def handle_call(:is_ready, _from, state),
    do: {:reply, {:ok, :ready}, state}

  def handle_call({:get_id, resource_name}, _from, %{counters: counters, epoch: epoch} = state) do
    counter = Map.get(counters, resource_name, 0)
    updated_counters = Map.put(counters, resource_name, counter + 1)
    new_state = %{state | counter: updated_counters}
    id = id(epoch, counter)
    if counter < @max_counter do
      {:reply, {:ok, id}, new_state, {:continue, :new_epoch}}
    else
      {:reply, {:ok, id}, new_state}
    end
  end

  @impl true
  def handle_info(:timeout, state),
    do: {:noreply, state, {:continue, :new_epoch}}

  #########################################################
  #
  #   Private function
  #
  #########################################################

  defp initial_state(node_id),
    do: %{node_id: node_id,
          counters: %{},
          epoch: 0,
          ready: false}

  defp id(epoch, counter) do
    combined_id = <<epoch::unsigned-integer-size(47), counter::unsigned-integer-size(17)>>
    <<id::unsigned-integer-64>> = combined_id
    id
  end

end
