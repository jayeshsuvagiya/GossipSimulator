defmodule GossipSimulator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    System.argv() |> parse_args |> process
  end

  @doc """
  'args' can be -h or help.
  Otherwise it is a numofnodes,topology,algorithm.
  Eg - 1000 line gossip
  """
  def parse_args(args) do
    parse =
      OptionParser.parse(args,
        strict: [non: :integer, top: :string, algo: :string]
      )

    case parse do
      {[help: true], _, _} ->
        :help

      {_, [n, t, a], _} ->
        {String.to_integer(n), t, a}

      _ ->
        :help
    end
  end

  @doc """
  Actual start of algorithm.
  """
  def process({non, top, algo}) do
    # IO.puts("#{non} , #{top} , #{algo}")
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: GossipSimulator.Worker.start_link(arg)
      # {GossipSimulator.Worker, arg},
      GossipSimulator.Converge,
      {GossipSimulator.NetworkSimulator, {non, top, algo, []}},
      GossipSimulator.NetworkSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GossipSimulator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def process(:help) do
    IO.puts("""
    usage:  mix run --no-halt proj2.exs <n> <topology> <algorithm>
    Where n is number of nodes.
    Topology can be full|3D|rand2D|torus|line|imline.
    Algorithm cab be gossip|push-sum.
    """)

    System.halt(0)
  end
end
