defmodule GossipSimulator.Converge do

  use GenServer

  @me Converge

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: @me)
  end

  def init(_opts) do
    {:ok, {0,0,0,nil}}
  end

  def done() do
    GenServer.cast(@me, :done)
  end

  def start_it(star_time) do
    GenServer.cast(@me, {:started,star_time})
  end

  def savenon(non) do
    GenServer.cast(@me, {:save_non,non})
  end

  def handle_cast({:save_non,non}, state) do
    {_,count,failed,start_time}=state
    {:noreply, {non,count,failed,start_time}}
  end

  def handle_cast({:started,st_time},{non,count,failed,start_time}) do
    {:noreply, {non,count,failed,st_time}}
  end



  def handle_cast(:done, {non,count,failed,start_time}) do
    if non==count+1 do
    IO.puts "Network Converged time - "
    IO.inspect(start_time)
    IO.inspect(Time.diff(start_time,Time.utc_now(),:millisecond))
       System.halt(0)
    end
    {:noreply, {non,count+1,failed,start_time}}
  end
end