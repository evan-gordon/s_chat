defmodule JsonEncoder do
  alias Jason.Encoder

  defimpl Encoder, for: Tuple do
    def encode(data, options) when is_tuple(data) do
      data
      |> Tuple.to_list()
      |> Encoder.List.encode(options)
    end
  end

  defimpl Encoder, for: PID do
    def encode(data, options) when is_pid(data) do
      data
      |> inspect()
      |> Encoder.BitString.encode(options)
    end
  end
end
