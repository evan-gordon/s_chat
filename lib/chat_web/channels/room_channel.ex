defmodule ChatWeb.RoomChannel do
  # fix joined server notifications not working
  # remove all channel_monitor code? it seems pointless now :(
  # get the message box stuck to bottom of screen
  # look into live_view for frontend dom editing

  @type command ::
          {:broadcast, String.t(), List.t()}
          | {:quiet, String.t(), List.t()}

  use ChatWeb, :channel
  require Logger
  alias Chat.Voting.PollBooth
  alias Chat.Helpers

  @impl true
  def join("room:lobby", _params, socket) do
    socket = assign(socket, :rooms, ["room:lobby"])
    send(self(), :after_join)
    {:ok, socket}
  end

  # def join("room:" <> _private_room_id, params, socket) do
  #  {:error, %{reason: "unauthorized"}}
  # end

  # notify server of join
  @impl true
  def handle_info(:after_join, socket) do
    payload = %{
      name: "SERVER",
      message: "User #{socket.assigns.user_id} has joined!",
      type: "chat"
    }

    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  def handle_info(:start_video, socket) do
    broadcast(socket, "shout", %{type: "start-player"})
    {:noreply, socket}
  end

  def handle_cast({:vote_result, map}, socket) do
    if(map[:yes] > map[:no]) do
      map[:link]
      |> broadcast_video(socket)
    else
      payload = %{
        name: "SERVER",
        message: "Vote failed with yes: #{map[:yes]} no: #{map[:no]}",
        type: "chat"
      }

      broadcast(socket, "shout", payload)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_in("edit:name", payload, socket) do
    socket = assign(socket, :user_id, payload["name"])
    {:noreply, socket}
  end

  # Heartbeat function, to keep connection open
  def handle_in("ping", payload, socket), do: {:reply, {:ok, payload}, socket}

  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", %{"message" => message}, socket) do
    payload = %{name: socket.assigns.user_id, message: message, type: "chat"}

    message
    |> parse_command()
    |> process_command(socket)
    |> case do
      {:quiet, _, _} -> nil
      {:broadcast, _, _} -> broadcast(socket, "shout", payload)
      _ -> broadcast(socket, "shout", payload)
    end

    # broadcast_message =
    #   case parse_command(message) do
    #     {:quiet, _, _} = command ->
    #       process_command(command, socket)
    #       false

    #     {:broadcast, _, _} = command ->
    #       process_command(command, socket)
    #       true

    #     _ ->
    #       true
    #   end

    # if(broadcast_message) do

    #   broadcast(socket, "shout", payload)
    # end

    {:noreply, socket}
  end

  def handle_in("watch", _payload, socket) do
    Process.send_after(self(), :start_video, 3000)
    {:noreply, socket}
  end

  def handle_in("leave", payload, socket) do
    uname = socket.assigns.user_id
    leave("room:lobby", payload, socket)
    payload = %{name: "SERVER", message: "User #{uname} left :(", type: "chat"}
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

  @doc """
    Attepmt to parse out a command type from a given string.
  """
  @spec parse_command(String.t()) :: command() | :none
  def parse_command(message) do
    [full_command | args] = String.split(message)
    full_command = String.downcase(full_command)

    # [full_command | args] =
    #   Enum.at(split_message, 0)
    #   |> String.downcase()

    {notify_type, command} = String.split_at(full_command, 1)

    case notify_type do
      "!" -> {:broadcast, command, args}
      "/" -> {:quiet, command, args}
      _ -> :none
    end
  end

  @doc """
    Given a command type, attempt to enact that command.
    If given command is not valid return `:none`.
  """
  @spec process_command(command(), map()) :: :ok | command() | command() | :none
  def process_command({_mode, name, args} = command, socket) do
    case name do
      "watch" ->
        Logger.debug("watch_command_found.")
        # socket = subscribe_to_notifications(Enum.at(split, 1), socket)
        case Helpers.validate_url(Enum.at(args, 0)) do
          {:ok, url} ->
            # PollBooth.start_poll(url)
            broadcast_video(url, socket)
            command

          {:error, reason} ->
            payload = %{name: "SERVER", message: reason, type: "chat"}
            broadcast(socket, "shout", payload)
            :none
        end

      "vote" ->
        arg1 = List.first(args) |> String.downcase()

        cond do
          Regex.match?(~r/^y(es)?$/, arg1) ->
            PollBooth.cast_vote(:yes)
            command

          Regex.match?(~r/^n(o)?$/, arg1) ->
            PollBooth.cast_vote(:no)
            command

          true ->
            :none
        end

      "vote_next" ->
        Logger.debug("vote_next_command_found")

        case Helpers.validate_url(Enum.at(args, 0)) do
          {:ok, url} ->
            PollBooth.start_poll(url)
            command

          {:error, reason} ->
            payload = %{name: "SERVER", message: reason, type: "chat"}
            broadcast(socket, "shout", payload)
            :none
        end

      _ ->
        :none
    end
  end

  def process_command(_, _), do: :none

  def broadcast_video(link, socket) do
    if(String.contains?(link, "youtube.com/watch?v=")) do
      hash =
        link
        |> String.split("youtube.com/watch?v=")
        |> Enum.at(1)

      payload = %{type: "video-player", platform: "youtube", hash: hash}
      broadcast(socket, "shout", payload)
    else
      # add better behavior for this later
      nil
    end
  end
end
