# fix joined server notifications not working
# remove all channel_monitor code? it seems pointless now :(
# get the message box stuck to bottom of screen
# look into drab for frontend dom editing
defmodule ChatWeb.RoomChannel do
  use ChatWeb, :channel
  require Logger
  alias Chat.Voting.PollBooth
  alias Chat.Helpers

  def join("room:lobby", _params, socket) do
    socket = assign(socket, :rooms, ["room:lobby"])
    send(self(), :after_join)
    {:ok, socket}
  end

  # def join("room:" <> _private_room_id, params, socket) do
  #  {:error, %{reason: "unauthorized"}}
  # end

  # notify server of join
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
    process_command(message, socket)
    payload = %{name: socket.assigns.user_id, message: message}
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  def handle_in("leave", payload, socket) do
    uname = socket.assigns.user_id
    leave("room:lobby", payload, socket)
    payload = %{name: "SERVER", message: "User #{uname} left :("}
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  def leave("room:lobby", _params, socket) do
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
  defp process_command(message, socket) do
    first_char = String.at(message, 0)
    split = String.split(message)

    command =
      Enum.at(split, 0)
      |> String.downcase()

    if first_char == "/" and length(split) > 1 do
      case command do
        "/watch" ->
          Logger.debug("watch command found.")
          # socket = subscribe_to_notifications(Enum.at(split, 1), socket)
          {:ok, socket}

        "/vote" ->
          arg1 =
            Enum.at(split, 1)
            |> String.downcase()

          cond do
            Regex.match?(~r/^y(es)?$/, arg1) ->
              PollBooth.cast_vote(:yes)
              {:ok, socket}

            Regex.match?(~r/^n(o)?$/, arg1) ->
              PollBooth.cast_vote(:no)
              {:ok, socket}

            true ->
              :none
          end

        "/vote_next" ->
          case Helpers.validate_url(Enum.at(split, 1)) do
            {:ok, url} ->
              PollBooth.start_poll(url)
              {:ok, socket}

            {:error, reason} ->
              payload = %{name: "SERVER", message: reason}
              broadcast(socket, "shout", payload)
              :none
          end

        _ ->
          :none
      end
    else
      :none
    end
  end
end
