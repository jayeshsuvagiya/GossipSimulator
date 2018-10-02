defmodule GossipSimulator.NodeG do
  use GenServer, restart: :temporary
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args)
  end

  def init(:no_args) do
    # Process.send_after(self(), :do_one_itr, 0)
    {:ok, {[], 0, nil}}
  end

  def handle_cast({:set_neighbours, nb}, state) do
    {:noreply, {nb, 0, nil}}
  end

  def handle_cast({:rec_message,msg},state) do
    {nb,count,_m} = state
    if count==0 do
      GenServer.cast(self(), {:do_one_round,msg})
    end
    if count==10 do
      GossipSimulator.Converge.done()
     # Logger.debug("#{inspect(self())} - Ending")
      {:stop, :normal, nil}
    end
    #Logger.debug("#{inspect(self())} - Message Received")
    {:noreply, {nb,count+1,msg}}
  end

  def handle_cast({:do_one_round,msg},state) do
    {nb,count,msg} = state
    rand_neigh = Enum.random(nb)
    #Logger.debug("#{inspect(self())} - Message sent to #{inspect(rand_neigh)}")
    GenServer.cast(rand_neigh, {:rec_message,msg})

    GenServer.cast(self(), {:do_one_round,msg})
    {:noreply, {nb,count,msg}}
  end
end
