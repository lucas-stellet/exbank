defmodule Teller.API do
  @moduledoc false

  import Teller.API.Base

  alias HTTPoison.Response

  import Teller.Utils, only: [get_header_value: 2]

  @type device :: %{
          id: binary(),
          mask: binary(),
          type: binary()
        }

  @type account :: %{
          ach: binary() | nil,
          alias: binary(),
          id: binary(),
          number: binary(),
          product: binary(),
          type: binary()
        }

  @type transaction :: %{
          amount: integer(),
          date: binary(),
          id: binary(),
          posted: boolean(),
          title: binary()
        }

  @type balances :: %{
          available: integer(),
          last_transactions: list(transaction()),
          ledger: integer()
        }

  @type account_default_params :: %{
          r_token: binary(),
          f_token: binary(),
          s_token: binary(),
          device_id: binary(),
          account_id: binary()
        }

  @type response_data ::
          account()
          | transaction()
          | list(transaction())
          | balances()
          | list(account())

  @type auth_headers :: %{
          r_token: binary(),
          f_token_spec: binary(),
          f_request_id: binary(),
          s_token: binary()
        }

  @type sign_in_params :: %{
          username: binary(),
          password: binary(),
          device_id: binary()
        }

  @type sign_in_response :: %{
          devices: list(device()),
          r_token: binary(),
          f_token_spec: binary(),
          f_request_id: binary()
        }

  @type mfa_params :: %{
          mfa_device_id: binary(),
          device_id: binary(),
          r_token: binary(),
          f_token: binary()
        }

  @type mfa_response :: %{
          r_token: binary(),
          f_token_spec: binary(),
          f_request_id: binary()
        }

  @type mfa_verify_params :: %{
          mfa_code: binary(),
          device_id: binary(),
          r_token: binary(),
          f_token: binary()
        }

  @type mfa_verify_response :: %{
          r_token: binary(),
          f_token_spec: binary(),
          f_request_id: binary(),
          s_token: binary(),
          enc_key: binary()
        }

  @type get_transaction_params :: %{
          r_token: binary(),
          f_token: binary(),
          s_token: binary(),
          account_id: binary(),
          transaction_id: binary(),
          device_id: binary()
        }

  @type get_account_params :: account_default_params()

  @type get_account_details_params :: account_default_params()

  @type list_balances_params :: account_default_params()

  @type list_transactions_params :: account_default_params()

  @type teller_error_response ::
          {:error,
           %{
             code: binary(),
             message: binary()
           }}

  @type teller_successful_response ::
          {:ok,
           %{
             data: response_data(),
             headers: auth_headers()
           }}

  @spec resources_available() :: list(atom())
  def resources_available,
    do:
      ~w( sign_in mfa mfa_verify get_account get_account_details list_transactions get_transaction list_balances )a

  @spec sign_in(params :: sign_in_params()) :: {:ok, sign_in_response()} | teller_error_response()
  def sign_in(params) do
    username = Map.get(params, :username)
    password = Map.get(params, :password)
    device_id = Map.get(params, :device_id)

    "/signin"
    |> post(
      %{username: username, password: password},
      [{"device-id", device_id}]
    )
    |> handle_response(&extract_from_sign_in_response/1)
  end

  defp extract_from_sign_in_response(%Response{
         headers: headers,
         body: %{data: %{devices: devices}, result: "mfa_required"}
       }) do
    %{
      devices: devices,
      r_token: get_header_value(headers, "r-token"),
      f_token_spec: get_header_value(headers, "f-token-spec"),
      f_request_id: get_header_value(headers, "f-request-id")
    }
  end

  @spec mfa(params :: mfa_params()) :: {:ok, mfa_response()} | teller_error_response()
  def mfa(params) do
    mfa_device_id = Map.get(params, :mfa_device_id)
    device_id = Map.get(params, :device_id)
    r_token = Map.get(params, :r_token)
    f_token = Map.get(params, :f_token)

    "/signin/mfa"
    |> post(
      %{device_id: mfa_device_id},
      custom_headers(device_id, r_token, f_token)
    )
    |> handle_response(&extract_from_mfa_response/1)
  end

  defp extract_from_mfa_response(%Response{
         headers: headers
       }) do
    %{
      r_token: get_header_value(headers, "r-token"),
      f_token_spec: get_header_value(headers, "f-token-spec"),
      f_request_id: get_header_value(headers, "f-request-id")
    }
  end

  @spec mfa_verify(params :: mfa_verify_params()) ::
          {:ok, mfa_verify_response()} | teller_error_response()
  def mfa_verify(params) do
    mfa_code = Map.get(params, :mfa_code)
    device_id = Map.get(params, :device_id)
    r_token = Map.get(params, :r_token)
    f_token = Map.get(params, :f_token)

    "/signin/mfa/verify"
    |> post(
      %{code: mfa_code},
      custom_headers(device_id, r_token, f_token)
    )
    |> handle_response(&extract_from_mfa_verify_response/1)
  end

  defp extract_from_mfa_verify_response(%Response{
         body: %{data: data},
         headers: headers
       }) do
    %{
      enc_key: data.enc_key,
      r_token: get_header_value(headers, "r-token"),
      s_token: get_header_value(headers, "s-token"),
      f_token_spec: get_header_value(headers, "f-token-spec"),
      f_request_id: get_header_value(headers, "f-request-id")
    }
  end

  @spec get_account(params :: get_account_params()) ::
          teller_successful_response() | teller_error_response()
  def get_account(params) do
    headers = auth_headers(params)
    account_id = Map.get(params, :account_id)

    "/accounts/#{account_id}"
    |> get(headers)
    |> handle_response()
  end

  @spec get_account_details(params :: get_account_details_params()) ::
          teller_successful_response() | teller_error_response()
  def get_account_details(params) do
    headers = auth_headers(params)
    account_id = Map.get(params, :account_id)

    "/accounts/#{account_id}/details"
    |> get(headers)
    |> handle_response()
  end

  @spec list_transactions(params :: list_transactions_params()) ::
          teller_successful_response() | teller_error_response()
  def list_transactions(params) do
    headers = auth_headers(params)
    account_id = Map.get(params, :account_id)

    "/accounts/#{account_id}/transactions"
    |> get(headers)
    |> handle_response()
  end

  @spec get_transaction(params :: get_transaction_params()) ::
          teller_successful_response() | teller_error_response()
  def get_transaction(params) do
    headers = auth_headers(params)
    account_id = Map.get(params, :account_id)
    transaction_id = Map.get(params, :transaction_id)

    "/accounts/#{account_id}/transactions/#{transaction_id}"
    |> get(headers)
    |> handle_response()
  end

  @spec list_balances(params :: list_balances_params()) ::
          teller_successful_response() | teller_error_response()
  def list_balances(params) do
    headers = auth_headers(params)
    account_id = Map.get(params, :account_id)

    "/accounts/#{account_id}/balances"
    |> get(headers)
    |> handle_response()
  end

  defp custom_headers(device_id, r_token, f_token) do
    [
      {"device-id", device_id},
      {"r-token", r_token},
      {"f-token", f_token},
      {"teller-mission", "accepted!"}
    ]
  end

  defp auth_headers(params) do
    s_token = Map.get(params, :s_token)
    f_token = Map.get(params, :f_token)
    r_token = Map.get(params, :r_token)
    device_id = Map.get(params, :device_id)

    [
      {"device-id", device_id},
      {"r-token", r_token},
      {"f-token", f_token},
      {"s-token", s_token},
      {"teller-mission", "accepted!"}
    ]
  end

  @success_status_code_list [200, 201, 202, 203, 204]

  defp handle_response({:ok, %Response{status_code: status_code, body: body, headers: headers}})
       when status_code in @success_status_code_list do
    {:ok,
     %{
       data: body,
       headers: %{
         r_token: get_header_value(headers, "r-token"),
         s_token: get_header_value(headers, "s-token"),
         f_token_spec: get_header_value(headers, "f-token-spec"),
         f_request_id: get_header_value(headers, "f-request-id")
       }
     }}
  end

  defp handle_response({:ok, %Response{body: body}}) do
    {:error, body}
  end

  defp handle_response(
         {:ok, %Response{status_code: status_code} = response},
         extract_from_response
       )
       when status_code in @success_status_code_list do
    {:ok, extract_from_response.(response)}
  end

  defp handle_response({:ok, %Response{body: body}}, _) do
    {:error, body}
  end
end
