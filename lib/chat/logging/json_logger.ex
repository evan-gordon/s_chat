defmodule JsonLogger do
  def format(level, message, timestamp, metadata) do
    metadata_map =
      Enum.reduce(metadata, %{}, fn {key, value}, acc ->
        Map.put(acc, key, value)
      end)

    encoded =
      %{
        level: level,
        message: message,
        metadata: metadata_map,
        timestamp: timestamp
      }
      |> Jason.encode!()

    "\n" <> encoded
  end
end
