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
      "2D" -> top_2D(non)
      "torus" -> top_torus(non)
      "3D" -> top_3D(non)
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
    w = round(:math.sqrt(non))
    nodes = generatenodes(w * w)
    s = length(nodes)
    GenServer.cast(Enum.at(nodes,0), {:set_neighbours, [Enum.at(nodes, 1), Enum.at(nodes, w)]})
    IO.puts("0-1,#{w}")
    GenServer.cast(Enum.at(nodes,w-1), {:set_neighbours, [Enum.at(nodes, w-2), Enum.at(nodes, w-1+w)]})
    IO.puts("#{w-1}-#{w-2},#{(w-1+w)}")
    GenServer.cast(Enum.at(nodes,s-w), {:set_neighbours, [Enum.at(nodes, s-w-w), Enum.at(nodes, s-w+1)]})
    IO.puts("#{s-w}-#{s-w-w},#{s-w+1}")
    GenServer.cast(Enum.at(nodes,s-1), {:set_neighbours, [Enum.at(nodes, s-2), Enum.at(nodes, s-w-1)]})
    IO.puts("#{s-1}-#{s-2},#{s-w-1}")

    Enum.each(1..w-2, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-1),Enum.at(nodes, x+w), Enum.at(nodes, x+1)]})
      IO.puts("#{x}-#{x-1},#{x+w},#{x+1}")
    end)

    Enum.map_every(w..s-w-w,w, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-w),Enum.at(nodes, x+1), Enum.at(nodes, x+w)]})
      IO.puts("#{x}-#{x-w},#{x+1},#{x+w}")
    end)

    Enum.map_every(w+w-1..s-w-1,w, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-w),Enum.at(nodes, x-1), Enum.at(nodes, x+w)]})
      IO.puts("#{x}-#{x-w},#{x-1},#{x+w}")
    end)

    Enum.each(s-w+1..s-2, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-1),Enum.at(nodes, x-w), Enum.at(nodes, x+1)]})
      IO.puts("#{x}-#{x-1},#{x-w},#{x+1}")
    end)

    Enum.map_every(w+1..s-w-w+1,w,fn x ->
      Enum.each(x..x+w-3,fn z->
        GenServer.cast(Enum.at(nodes,z), {:set_neighbours, [Enum.at(nodes, z-1),Enum.at(nodes, z+1), Enum.at(nodes, z-w),Enum.at(nodes, z+w)]})
        IO.puts("#{z}-#{z-1},#{z+1},#{z-w},#{z+w}")
      end)
    end)

    System.halt(0)

  end


  def top_torus(non) do
    w = round(:math.sqrt(non))
    nodes = generatenodes(w * w)
    s = length(nodes)
    GenServer.cast(Enum.at(nodes,0), {:set_neighbours, [Enum.at(nodes, 1), Enum.at(nodes, w),Enum.at(nodes, s-w),Enum.at(nodes, w-1)]})
    IO.puts("0-1,#{w},#{s-w},#{w-1}")
    GenServer.cast(Enum.at(nodes,w-1), {:set_neighbours, [Enum.at(nodes, w-2), Enum.at(nodes, w-1+w), Enum.at(nodes, 0), Enum.at(nodes, s-1)]})
    IO.puts("#{w-1}-#{w-2},#{(w-1+w)},#{0},#{s-1}")
    GenServer.cast(Enum.at(nodes,s-w), {:set_neighbours, [Enum.at(nodes, s-w-w), Enum.at(nodes, s-w+1), Enum.at(nodes, 0), Enum.at(nodes, s-1)]})
    IO.puts("#{s-w}-#{s-w-w},#{s-w+1},#{0},#{s-1}")
    GenServer.cast(Enum.at(nodes,s-1), {:set_neighbours, [Enum.at(nodes, s-2), Enum.at(nodes, s-w-1),Enum.at(nodes,w-1),Enum.at(nodes,s-w)]})
    IO.puts("#{s-1}-#{s-2},#{s-w-1},,#{w-1},#{s-w}")

    Enum.each(1..w-2, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-1),Enum.at(nodes, x+w), Enum.at(nodes, x+1),Enum.at(nodes, x+s-w)]})
      IO.puts("#{x}-#{x-1},#{x+w},#{x+1},#{x+s-w}")
    end)

    Enum.map_every(w..s-w-w,w, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-w),Enum.at(nodes, x+1), Enum.at(nodes, x+w),Enum.at(nodes, x+w-1)]})
      IO.puts("#{x}-#{x-w},#{x+1},#{x+w},#{x+w-1}")
    end)

    Enum.map_every(w+w-1..s-w-1,w, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-w),Enum.at(nodes, x-1), Enum.at(nodes, x+w),Enum.at(nodes, x-w+1)]})
      IO.puts("#{x}-#{x-w},#{x-1},#{x+w},#{x-w+1}")
    end)

    Enum.each(s-w+1..s-2, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-1),Enum.at(nodes, x-w), Enum.at(nodes, x+1),Enum.at(nodes, x-s+w)]})
      IO.puts("#{x}-#{x-1},#{x-w},#{x+1},#{x-s+w}")
    end)

    Enum.map_every(w+1..s-w-w+1,w,fn x ->
      Enum.each(x..x+w-3,fn z->
        GenServer.cast(Enum.at(nodes,z), {:set_neighbours, [Enum.at(nodes, z-1),Enum.at(nodes, z+1), Enum.at(nodes, z-w),Enum.at(nodes, z+w)]})
        IO.puts("#{z}-#{z-1},#{z+1},#{z-w},#{z+w}")
      end)
    end)

    System.halt(0)

  end

  def top_3D(non) do
    w = round(:math.pow(non,1/3))
    nodes = generatenodes(w * w * w)
    s = length(nodes)
    ud = w*w

    GenServer.cast(Enum.at(nodes,0), {:set_neighbours, [Enum.at(nodes, 1), Enum.at(nodes, w)]})
    IO.puts("0-1,#{w}")
    GenServer.cast(Enum.at(nodes,w-1), {:set_neighbours, [Enum.at(nodes, w-2), Enum.at(nodes, w-1+w)]})
    IO.puts("#{w-1}-#{w-2},#{(w-1+w)}")
    GenServer.cast(Enum.at(nodes,ud-w), {:set_neighbours, [Enum.at(nodes, s-w-w), Enum.at(nodes, s-w+1)]})
    GenServer.cast(Enum.at(nodes,ud-1), {:set_neighbours, [Enum.at(nodes, s-w-w), Enum.at(nodes, s-w+1)]})

    GenServer.cast(Enum.at(nodes,s-ud), {:set_neighbours, [Enum.at(nodes, s-w-w), Enum.at(nodes, s-w+1)]})
    GenServer.cast(Enum.at(nodes,s-w), {:set_neighbours, [Enum.at(nodes, s-w-w), Enum.at(nodes, s-w+1)]})
    GenServer.cast(Enum.at(nodes,s-w), {:set_neighbours, [Enum.at(nodes, s-w-w), Enum.at(nodes, s-w+1)]})
    IO.puts("#{s-w}-#{s-w-w},#{s-w+1}")
    GenServer.cast(Enum.at(nodes,s-1), {:set_neighbours, [Enum.at(nodes, s-2), Enum.at(nodes, s-w-1)]})
    IO.puts("#{s-1}-#{s-2},#{s-w-1}")

    System.halt(0)

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
