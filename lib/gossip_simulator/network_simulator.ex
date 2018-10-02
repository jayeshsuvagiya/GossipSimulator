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
    {non, top, algo, _nodes} = args
    nodes = case top do
      "full" -> top_full(non,algo)
      "line" -> top_line(non,algo)
      "imline" -> top_imline(non,algo)
      "2D" -> top_2D(non,algo)
      "torus" -> top_torus(non,algo)
      "3D" -> top_3D(non,algo)
      _ -> process(:help)
    end

    start_time = Time.utc_now()
    GossipSimulator.Converge.start_it(start_time)
    case algo do
      "gossip" -> GenServer.cast(Enum.random(nodes),{:rec_message,"This is a rumor"})
      "push-sum" -> IO.puts "push-sum"
      _ -> process(:help)
    end
    #IO.inspect nodess
    {:noreply, {length(nodes), top, algo,nodes}}
  end

  def top_full(non,algo) do
    nodes = generatenodes(non,algo)
    Enum.each(nodes,fn pid ->
      GenServer.cast(pid, {:set_neighbours, List.delete(nodes, pid)})
                    end)
    nodes
  end

  def top_line(non,algo) do
    nodes = generatenodes(non,algo)

    Enum.with_index(nodes)
    |> Enum.each(fn {pid, i} ->
      cond do
        i == 0 ->
          GenServer.cast(pid, {:set_neighbours, [Enum.at(nodes, 1)]})
          #IO.puts("0-1")

        i == length(nodes) - 1 ->
          GenServer.cast(pid, {:set_neighbours, [Enum.at(nodes, i - 1)]})
          #IO.puts("#{i}-#{i - 1}")

        true ->
          GenServer.cast(pid, {:set_neighbours, [Enum.at(nodes, i - 1), Enum.at(nodes, i + 1)]})
          #IO.puts("#{i}-#{i - 1},#{i + 1}")
      end
    end)
    nodes
  end

  def top_imline(non,algo) do
    nodes = generatenodes(non,algo)

    Enum.with_index(nodes)
    |> Enum.each(fn {pid, i} ->
      cond do
        i == 0 ->
          GenServer.cast(pid, {:set_neighbours, [Enum.at(nodes, 1),Enum.random(nodes)]})
          #IO.puts("0-1")

        i == length(nodes) - 1 ->
          GenServer.cast(pid, {:set_neighbours, [Enum.at(nodes, i - 1),Enum.random(nodes)]})
          #IO.puts("#{i}-#{i - 1}")

        true ->
          GenServer.cast(pid, {:set_neighbours, [Enum.at(nodes, i - 1), Enum.at(nodes, i + 1),Enum.random(nodes)]})
          #IO.puts("#{i}-#{i - 1},#{i + 1}")
      end
    end)
    nodes
  end

  def top_2D(non,algo) do
    w = round(:math.sqrt(non))
    nodes = generatenodes(w * w,algo)
    s = length(nodes)
    GenServer.cast(Enum.at(nodes,0), {:set_neighbours, [Enum.at(nodes, 1), Enum.at(nodes, w)]})
    #IO.puts("0-1,#{w}")
    GenServer.cast(Enum.at(nodes,w-1), {:set_neighbours, [Enum.at(nodes, w-2), Enum.at(nodes, w-1+w)]})
    #IO.puts("#{w-1}-#{w-2},#{(w-1+w)}")
    GenServer.cast(Enum.at(nodes,s-w), {:set_neighbours, [Enum.at(nodes, s-w-w), Enum.at(nodes, s-w+1)]})
    #IO.puts("#{s-w}-#{s-w-w},#{s-w+1}")
    GenServer.cast(Enum.at(nodes,s-1), {:set_neighbours, [Enum.at(nodes, s-2), Enum.at(nodes, s-w-1)]})
    #IO.puts("#{s-1}-#{s-2},#{s-w-1}")

    Enum.each(1..w-2, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-1),Enum.at(nodes, x+w), Enum.at(nodes, x+1)]})
      #IO.puts("#{x}-#{x-1},#{x+w},#{x+1}")
    end)

    Enum.map_every(w..s-w-w,w, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-w),Enum.at(nodes, x+1), Enum.at(nodes, x+w)]})
      #IO.puts("#{x}-#{x-w},#{x+1},#{x+w}")
    end)

    Enum.map_every(w+w-1..s-w-1,w, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-w),Enum.at(nodes, x-1), Enum.at(nodes, x+w)]})
      #IO.puts("#{x}-#{x-w},#{x-1},#{x+w}")
    end)

    Enum.each(s-w+1..s-2, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-1),Enum.at(nodes, x-w), Enum.at(nodes, x+1)]})
      #IO.puts("#{x}-#{x-1},#{x-w},#{x+1}")
    end)

    Enum.map_every(w+1..s-w-w+1,w,fn x ->
      Enum.each(x..x+w-3,fn z->
        GenServer.cast(Enum.at(nodes,z), {:set_neighbours, [Enum.at(nodes, z-1),Enum.at(nodes, z+1), Enum.at(nodes, z-w),Enum.at(nodes, z+w)]})
        #IO.puts("#{z}-#{z-1},#{z+1},#{z-w},#{z+w}")
      end)
    end)

    nodes
  end


  def top_torus(non,algo) do
    w = round(:math.sqrt(non))
    nodes = generatenodes(w * w,algo)
    s = length(nodes)
    GenServer.cast(Enum.at(nodes,0), {:set_neighbours, [Enum.at(nodes, 1), Enum.at(nodes, w),Enum.at(nodes, s-w),Enum.at(nodes, w-1)]})
    #IO.puts("0-1,#{w},#{s-w},#{w-1}")
    GenServer.cast(Enum.at(nodes,w-1), {:set_neighbours, [Enum.at(nodes, w-2), Enum.at(nodes, w-1+w), Enum.at(nodes, 0), Enum.at(nodes, s-1)]})
    #IO.puts("#{w-1}-#{w-2},#{(w-1+w)},#{0},#{s-1}")
    GenServer.cast(Enum.at(nodes,s-w), {:set_neighbours, [Enum.at(nodes, s-w-w), Enum.at(nodes, s-w+1), Enum.at(nodes, 0), Enum.at(nodes, s-1)]})
    #IO.puts("#{s-w}-#{s-w-w},#{s-w+1},#{0},#{s-1}")
    GenServer.cast(Enum.at(nodes,s-1), {:set_neighbours, [Enum.at(nodes, s-2), Enum.at(nodes, s-w-1),Enum.at(nodes,w-1),Enum.at(nodes,s-w)]})
    #IO.puts("#{s-1}-#{s-2},#{s-w-1},,#{w-1},#{s-w}")

    Enum.each(1..w-2, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-1),Enum.at(nodes, x+w), Enum.at(nodes, x+1),Enum.at(nodes, x+s-w)]})
      #IO.puts("#{x}-#{x-1},#{x+w},#{x+1},#{x+s-w}")
    end)

    Enum.map_every(w..s-w-w,w, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-w),Enum.at(nodes, x+1), Enum.at(nodes, x+w),Enum.at(nodes, x+w-1)]})
      #IO.puts("#{x}-#{x-w},#{x+1},#{x+w},#{x+w-1}")
    end)

    Enum.map_every(w+w-1..s-w-1,w, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-w),Enum.at(nodes, x-1), Enum.at(nodes, x+w),Enum.at(nodes, x-w+1)]})
      #IO.puts("#{x}-#{x-w},#{x-1},#{x+w},#{x-w+1}")
    end)

    Enum.each(s-w+1..s-2, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-1),Enum.at(nodes, x-w), Enum.at(nodes, x+1),Enum.at(nodes, x-s+w)]})
      #IO.puts("#{x}-#{x-1},#{x-w},#{x+1},#{x-s+w}")
    end)

    Enum.map_every(w+1..s-w-w+1,w,fn x ->
      Enum.each(x..x+w-3,fn z->
        GenServer.cast(Enum.at(nodes,z), {:set_neighbours, [Enum.at(nodes, z-1),Enum.at(nodes, z+1), Enum.at(nodes, z-w),Enum.at(nodes, z+w)]})
        #IO.puts("#{z}-#{z-1},#{z+1},#{z-w},#{z+w}")
      end)
    end)

    nodes
  end

  def top_3D(non,algo) do
    w = round(:math.pow(non,1/3))
    nodes = generatenodes(w * w * w,algo)
    s = length(nodes)
    ud = w*w

    GenServer.cast(Enum.at(nodes,0), {:set_neighbours, [Enum.at(nodes, 1), Enum.at(nodes, w),Enum.at(nodes, ud)]})
    #IO.puts("0-1,#{w}")
    GenServer.cast(Enum.at(nodes,w-1), {:set_neighbours, [Enum.at(nodes, w-2), Enum.at(nodes, w-1+w),Enum.at(nodes, w-1+ud)]})
    #IO.puts("#{w-1}-#{w-2},#{(w-1+w)}")
    GenServer.cast(Enum.at(nodes,ud-w), {:set_neighbours, [Enum.at(nodes, ud-w-w), Enum.at(nodes, ud-w+1),Enum.at(nodes, ud-w+ud)]})
    GenServer.cast(Enum.at(nodes,ud-1), {:set_neighbours, [Enum.at(nodes, ud-2), Enum.at(nodes, ud-w-1),Enum.at(nodes, ud-1+ud)]})

    GenServer.cast(Enum.at(nodes,s-ud), {:set_neighbours, [Enum.at(nodes, s-ud+1), Enum.at(nodes, s-ud+w),Enum.at(nodes, s-ud-ud)]})
    GenServer.cast(Enum.at(nodes,s-ud+w-1), {:set_neighbours, [Enum.at(nodes, s-ud+w-2), Enum.at(nodes, s-ud+w-1+w),Enum.at(nodes, s-ud+w-1-ud)]})
    GenServer.cast(Enum.at(nodes,s-w), {:set_neighbours, [Enum.at(nodes, s-w-w), Enum.at(nodes, s-w+1),Enum.at(nodes, s-w+1-ud)]})
    #IO.puts("#{s-w}-#{s-w-w},#{s-w+1}")
    GenServer.cast(Enum.at(nodes,s-1), {:set_neighbours, [Enum.at(nodes, s-2), Enum.at(nodes, s-w-1),Enum.at(nodes, s-1-ud)]})
    #IO.puts("#{s-1}-#{s-2},#{s-w-1}")

    #EDGES '' '' '' ''
    Enum.each(1..w-2, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-1),Enum.at(nodes, x+w), Enum.at(nodes, x+1),Enum.at(nodes, x+ud)]})
      #IO.puts("#{x}-#{x-1},#{x+w},#{x+1},#{x+ud}")
    end)

    Enum.each(s-ud+1..s-ud+w-2, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-1),Enum.at(nodes, x+w), Enum.at(nodes, x+1),Enum.at(nodes, x-ud)]})
      #IO.puts("#{x}-#{x-1},#{x-w},#{x+1},#{x-s+w}")
    end)

    Enum.each(ud-w+1..ud-2, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-1),Enum.at(nodes, x-w), Enum.at(nodes, x+1),Enum.at(nodes, x+ud)]})
      #IO.puts("#{x}-#{x-1},#{x-w},#{x+1},#{x-s+w}")
    end)


    Enum.each(s-w+1..s-2, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-1),Enum.at(nodes, x-w), Enum.at(nodes, x+1),Enum.at(nodes, x-ud)]})
      #IO.puts("#{x}-#{x-1},#{x-w},#{x+1},#{x-s+w}")
    end)

    #EDGES | | | |
    Enum.map_every(w..ud-w-w,w, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-w),Enum.at(nodes, x+1), Enum.at(nodes, x+w),Enum.at(nodes, x+ud)]})
      #IO.puts("#{x}-#{x-w},#{x+1},#{x+w},#{x+w-1}")
    end)

    Enum.map_every(w-1+w..ud-1-w,w, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-w),Enum.at(nodes, x-1), Enum.at(nodes, x+w),Enum.at(nodes, x+ud)]})
      #IO.puts("#{x}-#{x-w},#{x-1},#{x+w},#{x-w+1}")
    end)

    Enum.map_every(s-ud+w..s-w-w,w, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-w),Enum.at(nodes, x+1), Enum.at(nodes, x+w),Enum.at(nodes, x-ud)]})
      #IO.puts("#{x}-#{x-w},#{x+1},#{x+w},#{x+w-1}")
    end)

    Enum.map_every(s-ud+w-1+w..s-1-w,w, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-w),Enum.at(nodes, x-1), Enum.at(nodes, x+w),Enum.at(nodes, x-ud)]})
      #IO.puts("#{x}-#{x-w},#{x-1},#{x+w},#{x-w+1}")
    end)


    #EDGES \ \ \ \
    Enum.map_every(ud..s-ud-ud,ud, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-ud),Enum.at(nodes, x+1), Enum.at(nodes, x+w),Enum.at(nodes, x+ud)]})
      #IO.puts("#{x}-#{x-w},#{x+1},#{x+w},#{x+w-1}")
    end)

    Enum.map_every(w-1+ud..s-ud+w-1-ud,ud, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-ud),Enum.at(nodes, x-1), Enum.at(nodes, x+w),Enum.at(nodes, x+ud)]})
      #IO.puts("#{x}-#{x-w},#{x-1},#{x+w},#{x-w+1}")
    end)

    Enum.map_every(ud-w+ud..s-w-ud,ud, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-ud),Enum.at(nodes, x+1), Enum.at(nodes, x-w),Enum.at(nodes, x+ud)]})
      #IO.puts("#{x}-#{x-w},#{x+1},#{x+w},#{x+w-1}")
    end)

    Enum.map_every(ud-1+ud..s-1-ud,ud, fn x ->
      GenServer.cast(Enum.at(nodes,x), {:set_neighbours, [Enum.at(nodes, x-ud),Enum.at(nodes, x-1), Enum.at(nodes, x-w),Enum.at(nodes, x+ud)]})
      #IO.puts("#{x}-#{x-w},#{x-1},#{x+w},#{x-w+1}")
    end)

    #FACES |_| |_| ......
    #back
    Enum.map_every(w+1..ud-w-w+1,w,fn x ->
      Enum.each(x..x+w-3,fn z->
        GenServer.cast(Enum.at(nodes,z), {:set_neighbours, [Enum.at(nodes, z-1),Enum.at(nodes, z+1), Enum.at(nodes, z-w),Enum.at(nodes, z+w),Enum.at(nodes,z+ud)]})
        #IO.puts("#{z}-#{z-1},#{z+1},#{z-w},#{z+w}")
      end)
    end)

    #front
    Enum.map_every(s-ud+w+1..s-w-w+1,w,fn x ->
      Enum.each(x..x+w-3,fn z->
        GenServer.cast(Enum.at(nodes,z), {:set_neighbours, [Enum.at(nodes, z-1),Enum.at(nodes, z+1), Enum.at(nodes, z-w),Enum.at(nodes, z+w),Enum.at(nodes,z-ud)]})
        #IO.puts("#{z}-#{z-1},#{z+1},#{z-w},#{z+w}")
      end)
    end)

    #top
    Enum.map_every(ud+1..s-ud-ud+1,ud,fn x ->
      Enum.each(x..x+w-3,fn z->
        GenServer.cast(Enum.at(nodes,z), {:set_neighbours, [Enum.at(nodes, z-1),Enum.at(nodes, z+1), Enum.at(nodes, z-ud),Enum.at(nodes, z+ud),Enum.at(nodes,z+w)]})
        #IO.puts("#{z}-#{z-1},#{z+1},#{z-w},#{z+w}")
      end)
    end)

    #bottom
    Enum.map_every(ud-w+ud+1..s-w-ud+1,ud,fn x ->
      Enum.each(x..x+w-3,fn z->
        GenServer.cast(Enum.at(nodes,z), {:set_neighbours, [Enum.at(nodes, z-1),Enum.at(nodes, z+1), Enum.at(nodes, z-ud),Enum.at(nodes, z+ud),Enum.at(nodes,z-w)]})
        #IO.puts("#{z}-#{z-1},#{z+1},#{z-w},#{z+w}")
      end)
    end)

    #left
    Enum.map_every(w+ud..ud-w-w+ud,w,fn x ->
      Enum.map_every(x..x+(ud*(w-3)),ud,fn z->
        GenServer.cast(Enum.at(nodes,z), {:set_neighbours, [Enum.at(nodes, z-w),Enum.at(nodes, z+w), Enum.at(nodes, z-ud),Enum.at(nodes, z+ud),Enum.at(nodes,z+1)]})
        #IO.puts("#{z}-#{z-1},#{z+1},#{z-w},#{z+w}")
      end)
    end)

    #Right
    Enum.map_every(w+ud+w-1..ud-w+ud-1,w,fn x ->
      Enum.map_every(x..x+(ud*(w-3)),ud,fn z->
        GenServer.cast(Enum.at(nodes,z), {:set_neighbours, [Enum.at(nodes, z-w),Enum.at(nodes, z+w), Enum.at(nodes, z-ud),Enum.at(nodes, z+ud),Enum.at(nodes,z-1)]})
        #IO.puts("#{z}-#{z-1},#{z+1},#{z-w},#{z+w}")
      end)
    end)

    #Inner
    Enum.map_every(w+1+ud..s-ud+w+1-ud,ud,fn x ->
      Enum.map_every(x..x+(ud*(w-3)),w,fn y  ->
        Enum.each(y..y+w-3,fn z->
          GenServer.cast(Enum.at(nodes,z), {:set_neighbours, [Enum.at(nodes, z-1),Enum.at(nodes, z+1), Enum.at(nodes, z-w),Enum.at(nodes, z+w),Enum.at(nodes,z-ud),Enum.at(nodes,z+ud)]})
          #IO.puts("#{z}-#{z-1},#{z+1},#{z-w},#{z+w}")
        end)
      end)
    end)

    nodes

  end

  def generatenodes(non,algo) do
    case algo do
      "gossip" -> nodes = 1..non |> Enum.map(fn _ -> GossipSimulator.NetworkSupervisor.add_node_g() end)
          GenServer.cast(self(), {:addnodes, non, nodes})
                  GossipSimulator.Converge.savenon(non)
          nodes
      "push-sum" -> nodes = 1..non |> Enum.map(fn _ -> GossipSimulator.NetworkSupervisor.add_node_ps() end)
                    GenServer.cast(self(), {:addnodes, non, nodes})
                    GossipSimulator.Converge.savenon(non)
                    nodes
      _ -> process(:help)
    end
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

end
