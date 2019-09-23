defmodule Chat.Helpers do
  require Logger
  @valid_hosts Application.fetch_env!(:chat, :hosts)

  def validate_url(url) do
    parsed_url = URI.parse(url)

    case parsed_url do
      %URI{scheme: nil} ->
        {:error, "No scheme"}

      %URI{host: nil} ->
        {:error, "No host"}

      %URI{path: nil} ->
        {:error, "No path"}

      _ ->
        is_valid =
          Enum.reduce(@valid_hosts, false, fn host, acc ->
            case String.contains?(parsed_url.host, host) do
              true -> true
              _ -> acc
            end
          end)

        if(is_valid) do
          {:ok, url}
        else
          Logger.debug("host_not_supported",
            parsed_url: inspect(parsed_url),
            supported_hosts: @valid_hosts
          )

          {:error, "Host not supported"}
        end
    end
  end
end
