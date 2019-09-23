defmodule Chat.Voting.Supervisor do
  use Supervisor
  alias Chat.Voting.PollBooth

  def start_link() do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      %{
        id: "general",
        start: {PollBooth, :start_link, ["general", "poll" <> "general"]}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
