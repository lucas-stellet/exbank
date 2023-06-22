defmodule Teller.Client.TokenBuilder do
  @moduledoc false

  import Teller.Utils, only: [get_client_configuration: 1]

  @type token :: binary()

  @spec run(
          token_spec :: binary(),
          username :: binary(),
          device_id :: binary(),
          last_request_id :: binary()
        ) :: token()
  def run(token_spec, username, device_id, last_request_id) do
    data = %{
      "username" => username,
      "api-key" => get_client_configuration(:api_key),
      "device-id" => device_id,
      "last-request-id" => last_request_id
    }

    token_spec
    |> Base.decode64!(padding: false)
    |> extract_specs()
    |> extract_keys()
    |> extract_symbol()
    |> build_token(data)
  end

  defp extract_specs(spec) do
    spec
    |> String.split(["(", ")"])
    |> List.delete_at(2)
    |> List.to_tuple()
  end

  defp extract_keys({encode_spec, values_spec}) do
    regex = ~r/(?<!-)--(?!-)|&|:|%|\||\+|\$/

    keys = String.split(values_spec, regex, trim: true)

    {encode_spec, keys, values_spec}
  end

  defp extract_symbol({encode_spec, keys, values_spec}) do
    symbol =
      values_spec
      |> String.replace(keys, " ")
      |> String.split(" ", trim: true)
      |> Enum.at(0)

    {encode_spec, keys, symbol}
  end

  defp build_token({"sha-256-b64-np", keys, symbol}, data) do
    keys
    |> Enum.map_join(symbol, &Map.get(data, &1))
    |> then(fn pre_token ->
      :crypto.hash(:sha256, pre_token)
      |> Base.encode64(padding: false)
    end)
  end
end
