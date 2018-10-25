# fix joined server notifications not working
# remove all channel_monitor code? it seems pointless now :(
# get the message box stuck to bottom of screen
# look into drab for frontend dom editing
defmodule ChatWeb.RoomChannel do
  use ChatWeb, :channel
  use GenServer

  def join("room:lobby", params, socket) do
    socket = assign(socket, :rooms, ["room:lobby"])
    send(self(), :after_join)
    {:ok, socket}
  end

  #def join("room:" <> _private_room_id, params, socket) do
  #  {:error, %{reason: "unauthorized"}}
  #end

  #notify server of join
  def handle_info(:after_join, socket) do
    payload = %{name: "SERVER", message: "User #{socket.assigns.user_id} has joined!"}
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  def handle_in("edit:name", payload, socket) do
    socket = assign(socket, :user_id, payload["name"])
    {:noreply, socket}
  end

  # Heartbeat function, to keep connection open
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", %{"message" => message}, socket) do
    # process_command(payload["message"], socket)
    payload = %{name: socket.assigns.user_id, message: message}
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("leave", payload, socket) do
    uname = socket.assigns.user_id
    leave("room:lobby", payload, socket)
    payload = %{name: "SERVER", message: "User #{uname} left :("}
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def leave("room:lobby", params, socket) do
    {:ok, socket}
  end

    # defp subscribe_to_notifications(room_id, socket) do
    #   room = "room:#{room_id}"
    #   if(can_join?(room, socket)) do
    #     IO.puts "Subscribing to: #{room}"
    #     :ok = ChatWeb.Endpoint.subscribe(room)
    #     assign(socket, :rooms, [room | socket.assigns.rooms])
    #   else
    #     :error
    #   end
    # end

    # defp can_join?(new_room, socket) do
    #   new_room not in socket.assigns.rooms
    # end

    # #TODO allow for ! commands, and create better command structure later on
    # defp process_command(message, socket) do
    #   first_char = String.at(message, 0)
    #   IO.puts "Processing command..."
    #   case first_char do
    #     "!" ->
    #       {:ok, socket}
    #     "/" ->
    #       split = String.split(message)
    #       if(Enum.at(split, 0) == "/watch" && length(split) > 1) do
    #         socket = subscribe_to_notifications(Enum.at(split, 1), socket)
    #       end
    #       {:ok, socket}
    #     ->
    #       :none
    #   end
    # end
end