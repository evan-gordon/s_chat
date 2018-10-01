defmodule Chat.ChannelMonitor do
  use GenServer

  def start_link(name \\ nil) do
    GenServer.start_link(__MODULE__, [], name: name) #fn -> loop(%{}) end
  end

  def set(name, key, value) do
    GenServer.cast(name, {:put, key, value})
  end

  def get(name, key) do
    GenServer.call(name, {:get, key})
  end

  def get_keys(name) do
    GenServer.call(name, {:keys})
  end

  def delete(name, key) do
    GenServer.cast(name, { :remove, key})
  end

  #this initialized the state var
  @impl true
  def init(args) do
    {:ok, %{}}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  def handle_call({:keys}, _from, state) do
    {:reply, Map.keys(state), state}
  end

  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  def handle_cast({:remove, key}, state) do
    {:noreply, Map.delete(state, key)}
  end
end