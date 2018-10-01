defmodule GossipSimulator.NodeG do
  use GenServer, restart: :temporary
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args)
  end

  def init(:no_args) do
    # Process.send_after(self(), :do_one_itr, 0)
    {:ok, {[], nil}}
  end

  def handle_cast({:set_neighbours, nb}, state) do
    {:noreply, {nb, nil}}
  end
end
