defmodule Chat.Helpers do
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
        if(parsed_url.host not in @valid_hosts) do
          {:error, "Host not supported"}
        else
          {:ok, url}
        end
    end
  end
end
