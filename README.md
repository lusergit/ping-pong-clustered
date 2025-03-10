# Ping Pong Clustered

An overkill ping pong game.
Two apps can communicate between them, using libcluster and horde.

# Preliminary steps

both in `apps/ping` and `apps/pong`
```sh
mix deps.get
mix deps.compile
```

# Usage

1. In `apps/ping`
   
  ```sh
  iex --sname ping -S mix
  ```

2. In `apps/pong`

  ``` sh
  iex --sname pong -S mix
  ```

3. In `apps/ping`
```elixir
iex(ping@fedora)1> [{ping_pid, 0}] = Horde.Registry.lookup(PingPong.Registry, :ping)
## [{pid(), 0}]

iex(ping@fedora)2> GenServer.cast(ping_pid, :start)
## :ok
```

4. Enjoy Two supervised processes playing ping pong!
