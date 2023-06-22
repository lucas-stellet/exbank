defmodule Teller.Utils do
  @moduledoc false

  @type headers :: list(tuple())

  @spec get_r_token(headers :: headers()) :: binary()
  def get_r_token(headers), do: get_header_value(headers, "r-token")

  @spec get_f_request_id(headers :: headers()) :: binary()
  def get_f_request_id(headers), do: get_header_value(headers, "f-request-id")

  @spec get_f_token_spec(headers :: headers()) :: binary()
  def get_f_token_spec(headers), do: get_header_value(headers, "f-token-spec")

  @spec get_client_configuration(key_name :: atom()) :: binary() | nil
  def get_client_configuration(key_name) do
    Application.get_env(:exbank, :teller)
    |> Keyword.get(key_name)
  end

  @spec get_header_value(headers :: headers(), name :: binary()) :: binary()
  def get_header_value(headers, name),
    do: Enum.find(headers, &(elem(&1, 0) == name)) |> elem(1)

  @spec module_name(atom()) :: String.t()
  def module_name(module, n_elements \\ 1) do
    module
    |> to_string()
    |> String.split(".")
    |> Enum.slice(-n_elements..-1)
    |> Enum.join(".")
  end

  @spec convert_into_kw(struct :: struct()) :: keyword()
  def convert_into_kw(struct) do
    struct
    |> Map.from_struct()
    |> Keyword.new(fn {k, v} ->
      {k, v}
    end)
  end
end
