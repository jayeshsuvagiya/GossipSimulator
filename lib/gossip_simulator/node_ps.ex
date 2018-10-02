defmodule GossipSimulator.NodePS do
  use GenServer, restart: :temporary
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args)
  end

  def init(:no_args) do
    # Process.send_after(self(), :do_one_itr, 0)
    {:ok, {[], 0, 0, 1}}
  end

  def handle_cast({:set_neighbours, nb}, {_nodes,count,s,w}) do
    {:noreply, {nb,count,s,w}}
  end

  def handle_cast({:set_sum, sum}, {nodes,count,_s,w}) do
    {:noreply, {nodes,count,sum,w}}
  end

  def handle_cast({:rec_message,sn,wn},{nodes,count,s,w}) do
    ns=s+sn
    nw=w+wn

    if count==3 do
      GossipSimulator.Converge.done()
      # Logger.debug("#{inspect(self())} - Ending")
      {:stop, :normal, nil}
    end

    ro = s/w
    rn = ns/nw
    newcount = cond  do
      abs(ro-rn)<=0.00001 -> count+1
      true -> count
    end

    ns=ns/2
    nw=nw/2

    if length(nodes)>0 do
    rand_neigh = Enum.random(nodes)
    #Logger.debug("#{inspect(self())} - Message sent to #{inspect(rand_neigh)}")
    GenServer.cast(rand_neigh, {:rec_message,ns,nw})
    end
    #Logger.debug("#{inspect(self())} - Message Received")
    {:noreply, {nodes,newcount,ns,nw}}
  end


end
