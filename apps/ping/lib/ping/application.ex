defmodule Ping.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topology = [
      gossip: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]

    children = [
      {Cluster.Supervisor, [topology, [name: PingPong.Cluster.Supervisor]]},
      {Horde.Registry, [keys: :unique, name: PingPong.Registry, members: :auto]},
      Ping
    ]

    opts = [strategy: :one_for_one, name: Ping.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
