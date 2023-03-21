defmodule SupervisorTracker do
  use GenServer

  ## Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def crash_the_server(server, number) when is_integer number do
    GenServer.call(server,{:crash_me, number})
  end

  ## Callbacks (Server API)
  def init(state) do
    {:ok, state}
  end

# Callbacks (Server API)
  def handle_call({:crash_me, number}, _from, state) do
    {:reply, div(number,0), state}
  end

end
