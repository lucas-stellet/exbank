defmodule Teller.API.Base do
  @moduledoc false

  use HTTPoison.Base

  import Teller.Utils, only: [get_client_configuration: 1]

  @endpoint Application.compile_env!(:exbank, :teller)[:url]

  def process_request_headers(headers),
    do: headers ++ base_headers()

  def process_request_url(url),
    do: @endpoint <> url

  def process_request_body(body) when is_map(body),
    do: Jason.encode!(body)

  def process_request_body(body), do: body

  def process_response_body(binary) do
    binary
    |> Jason.decode!(keys: :atoms)
    |> case do
      %{error: error} ->
        error

      body ->
        body
    end
  end

  defp base_headers do
    [
      {"accept", "application/json"},
      {"content-type", "application/json"},
      {"api-key", get_client_configuration(:api_key)},
      {"user-agent", get_client_configuration(:user_agent)}
    ]
  end
end
