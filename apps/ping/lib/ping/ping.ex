defmodule Ping do
  @moduledoc """
  Documentation for `Ping`.
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

    case Horde.Registry.register(PingPong.Registry, :ping, court) do
      {:ok, _} -> {:ok, court}
      {:error, {:already_registered, _}} -> :ignore
    end
  end

  @impl GenServer
  def handle_cast(:start, court) do
    Logger.info("Starting game in court #{court}!")

    start = "starting ping!"

    time = Enum.random(500..1000)

    # Se meno di @hittime è una schiacciata
    start =
      "court #{court}: " <>
        if time < @hittime,
          do: "super " <> start,
          else: start

    case Horde.Registry.lookup(PingPong.Registry, :pong) do
      [] ->
        _ =
          Logger.warning("Nobody wants to play in court #{court} :( putting the racket down.")

        {:stop, :shutdown, court}

      [{pid, ^court}] ->
        IO.puts(start)
        :timer.sleep(time)
        GenServer.cast(pid, :ping)
        {:noreply, court}

      _multiple_players ->
        _ = Logger.warning("Too many players! Going home.")
        {:stop, :shutdown, court}
    end
  end

  @impl GenServer
  def handle_cast(:pong, court) do
    answer = "ping!"

    time = Enum.random(500..1000)

    # Se meno di @hittime è una schiacciata
    answer =
      "court #{court}: " <>
        if time < @hittime,
          do: "super " <> answer,
          else: answer

    case Horde.Registry.lookup(PingPong.Registry, :pong) do
      [] ->
        _ =
          Logger.warning(
            "Nobody wants to play anymore in court #{court} :( putting the racket down."
          )

        {:stop, :shutdown, court}

      [{pid, ^court}] ->
        IO.puts(answer)
        :timer.sleep(time)
        GenServer.cast(pid, :ping)
        {:noreply, court}

      _multiple_players ->
        _ = Logger.warning("Too many players! Going home.")
        {:stop, :shutdown, court}
    end
  end
end
