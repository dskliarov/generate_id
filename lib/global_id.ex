defmodule GlobalId do
  @moduledoc """
  GlobalId module contains an implementation of a guaranteed globally unique id system.
  """

  alias IdGenerator.Worker

  @doc """
  Please implement the following function.
  64 bit non negative integer output
  """
  @spec get_id(resource_name :: String.t()) :: non_neg_integer
  def get_id(resource_name),
    do: Worker.get_id(resource_name)

  #
  # You are given the following helper functions
  # Presume they are implemented - there is no need to implement them.
  #

  @doc """
  Returns your node id as an integer.
  It will be greater than or equal to 0 and less than or equal to 1024.
  It is guaranteed to be globally unique.
  """
  @spec node_id() :: non_neg_integer
  def node_id, do: Application.get_env(:id_generator, :node_id)

  @doc """
  Returns timestamp since the epoch in milliseconds.
  """
  @spec timestamp() :: non_neg_integer
  def timestamp, do: :os.system_time(:millisecond)
end
