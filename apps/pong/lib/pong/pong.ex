defmodule Pong do
  @moduledoc """
  Documentation for `Pong`.
  """
  require Logger
  use GenServer

  @hittime 750

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl GenServer
  def init(args) do
    court = Keyword.get(args, :court, 0)

    case Horde.Registry.register(PingPong.Registry, :pong, court) do
      {:ok, _} -> {:ok, court}
      {:error, {:already_registered, _}} -> :ignore
    end
  end

  @impl GenServer
  def handle_cast(:ping, court) do
    answer = "pong!"

    time = Enum.random(500..1000)

    # Se meno di @hittime è una schiacciata!
    answer =
      "court #{court}: " <>
        if time < @hittime,
          do: "super " <> answer,
          else: answer

    case Horde.Registry.lookup(PingPong.Registry, :ping) do
      [] ->
        _ =
          Logger.warning(
            "Nobody wants to play anymore in court #{court} :( putting the racket down."
          )

        {:stop, :shutdown, court}

      [{pid, ^court}] ->
        IO.puts(answer)
        :timer.sleep(time)
        GenServer.cast(pid, :pong)
        {:noreply, court}

      _multiple_players ->
        _ = Logger.warning("Too many players! Going home.")
        {:stop, :shutdown, court}
    end
  end
end
