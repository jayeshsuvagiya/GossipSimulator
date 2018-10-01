defmodule GossipSimulator.NetworkSupervisor do
  use DynamicSupervisor
  require Logger

  @me NetworkSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: @me)
  end

  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_node_g() do
    # Logger.debug "New node created"
    {:ok, pid} = DynamicSupervisor.start_child(@me, GossipSimulator.NodeG)
    pid
  end

  def add_node_ps() do
    # Logger.debug "New node created"
    {:ok, pid} = DynamicSupervisor.start_child(@me, GossipSimulator.NodePS)
    pid
  end
end
