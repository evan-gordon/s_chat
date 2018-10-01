defmodule ChatWeb.RoomChannel do
  use ChatWeb, :channel
  use GenServer

  @monitor_name :c_monitor

  def join("room:lobby", params, socket) do
    IO.puts "SOCKET: #{inspect socket}"
    Chat.ChannelMonitor.set(@monitor_name, socket.channel_pid, socket.assigns[:user_id])
    
    if authorized?(params) do
      send self, :after_join
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def join("room:" <> _private_room_id, params, socket) do
    {:error, %{reason: "unauthorized"}}
  end

  #notify server of join
  def handle_info(:after_join, socket) do
    params = %{"name" => "SERVER", "message" => "User #{socket.assigns[:user_id]} has joined!"}
    broadcast socket, "shout", params
    #push socket, "feed", %{list: feed_items(socket)}
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("leave", payload, socket) do
    uname = Chat.ChannelMonitor.get(@monitor_name, socket.channel_pid)
    leave "room:lobby", payload, socket
    payload = Map.put(payload, "name", "SERVER")
    payload = Map.put(payload, "message", "User #{uname} left :(")
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def leave("room:lobby", params, socket) do
    Chat.ChannelMonitor.delete(@monitor_name, socket.channel_pid)
    {:ok, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end