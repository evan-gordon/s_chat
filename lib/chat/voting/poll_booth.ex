defmodule Chat.Voting.PollBooth do
  use GenServer
  require Logger
  @name :general

  def start_link(_arg1, _arg2), do: GenServer.start_link(__MODULE__, [], name: @name)

  def start_poll(link) do
    if(GenServer.call(@name, :voting)) do
      :error
    else
      GenServer.cast(@name, {:start, link})
      Logger.debug("STARTING POLL: #{link}")
      :ok
    end
  end

  def cast_vote(vote) do
    if(GenServer.call(@name, :voting)) do
      Logger.debug("CASTING VOTE: #{vote}")
      GenServer.cast(@name, {:vote, vote})
      :ok
    end
  end

  # this initializes the state var
  @impl true
  def init(_args) do
    # ChatWeb.Endpoint.subscribe("ballot:start", [])
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:vote, :yes}, state) do
    %{:link => link, :yes => y, :no => n} = Map.get(state, :watch)
    {:noreply, Map.put(state, :watch, %{:link => link, :yes => y + 1, :no => n})}
  end

  @impl true
  def handle_cast({:vote, :no}, state) do
    %{:link => link, :yes => y, :no => n} = Map.get(state, :watch)
    {:noreply, Map.put(state, :watch, %{:link => link, :yes => y, :no => n + 1})}
  end

  @impl true
  def handle_cast({:start, link}, state) do
    timer()
    {:noreply, Map.put(state, :watch, %{:link => link, :yes => 0, :no => 0})}
  end

  @impl true
  def handle_info(:end, state) do
    Logger.debug("VOTE ENDED WITH: #{inspect(Map.get(state, :watch))}")
    {:noreply, Map.delete(state, :watch)}
  end

  @impl true
  def handle_call(:voting, _from, state) do
    {:reply, Map.has_key?(state, :watch), state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl true
  def handle_call(:keys, _from, state) do
    {:reply, Map.keys(state), state}
  end

  defp timer(interval \\ 20000), do: Process.send_after(self(), :end, interval)
end
