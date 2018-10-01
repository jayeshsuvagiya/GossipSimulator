defmodule GossipSimulator.NodePS do
  use GenServer, restart: :temporary
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args)
  end

  def init(:no_args) do
    # Process.send_after(self(), :do_one_itr, 0)
    {:ok, nil}
  end
end
