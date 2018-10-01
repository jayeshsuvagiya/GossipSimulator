defmodule GossipSimulator.NetworkSimulator do
  use GenServer
  require Logger

  @me NetworkSimulator

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @me)
  end

  def init(args) do
    Process.send_after(self(), :kickoff, 0)
    {:ok, args}
  end

  def handle_info(:kickoff, args) do
    {non, top, _algo, _nodes} = args
    # nodes=generatenodes(non)
    # IO.inspect(nodes);
    # checkstate()
    case top do
      "line" -> top_line(non)
      "imline" -> top_line(non)
      _ -> process(:help)
    end

    {:noreply, args}
  end

  def top_line(non) do
    nodes = generatenodes(non)

    Enum.with_index(nodes)
    |> Enum.each(fn {pid, i} ->
      cond do
        i == 0 ->
          GenServer.cast(pid, {:set_neighbours, [Enum.at(nodes, 1)]})
          IO.puts("0-1")

        i == length(nodes) - 1 ->
          GenServer.cast(pid, {:set_neighbours, [Enum.at(nodes, i - 1)]})
          IO.puts("#{i}-#{i - 1}")

        true ->
          GenServer.cast(pid, {:set_neighbours, [Enum.at(nodes, i - 1), Enum.at(nodes, i + 1)]})
          IO.puts("#{i}-#{i - 1},#{i + 1}")
      end
    end)
  end

  def top_2D(non) do
    IO.inspect(non)
    non = round(:Math.sqrt(non))
    IO.inspect(non * non)
    nodes = generatenodes(non * non)

    Enum.with_index(nodes)
    |> Enum.each(fn {pid, i} ->
      cond do
        i == 0 ->
          GenServer.cast(pid, {:set_neighbours, [Enum.at(nodes, 1)]})
          IO.puts("0-1")

        i == length(nodes) - 1 ->
          GenServer.cast(pid, {:set_neighbours, [Enum.at(nodes, i - 1)]})
          IO.puts("#{i}-#{i - 1}")

        true ->
          GenServer.cast(pid, {:set_neighbours, [Enum.at(nodes, i - 1), Enum.at(nodes, i + 1)]})
          IO.puts("#{i}-#{i - 1},#{i + 1}")
      end
    end)
  end

  def generatenodes(non) do
    nodes = 1..non |> Enum.map(fn _ -> GossipSimulator.NetworkSupervisor.add_node_g() end)
    GenServer.cast(self(), {:addnodes, non, nodes})
    nodes
  end

  def handle_cast({:addnodes, _non, nodes}, state) do
    {non, top, algo, _list} = state
    {:noreply, {non, top, algo, nodes}}
  end

  def process(:help) do
    IO.puts("""
    usage:  mix app.start <n> <topology> <algorithm>
    Where n is number of nodes.
    Topology can be full|3D|rand2D|sphere|line|imp2D.
    Algorithm cab be gossip|push-sum.
    """)

    System.halt(0)
  end

  def checkstate() do
    Process.send_after(self(), :getcstate, 0)
  end

  def handle_info(:getcstate, state) do
    IO.inspect(state)
    System.halt(0)
    {:noreply, state}
  end
end
