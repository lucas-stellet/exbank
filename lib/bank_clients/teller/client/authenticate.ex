defmodule Teller.Client.Authenticate do
  @moduledoc false

  alias Teller.API
  alias Teller.Client.TokenBuilder

  import Teller.Utils

  require Logger

  import Flow

  @mfa_code "123456"

  @mname module_name("Teller.Client.Authenticate")

  @type response :: %{
          r_token: binary(),
          s_token: binary(),
          f_token_spec: binary(),
          f_request_id: binary(),
          enc_key: binary()
        }
  @type error_response :: %{
          code: binary(),
          message: binary()
        }

  @spec run(device_id :: binary(), username :: binary(), password :: binary()) ::
          {:ok, response()} | {:error, error_response()}
  def run(device_id, username, password) do
    %{device_id: device_id, username: username, password: password}
    |> new_flow()
    |> sign_in()
    |> mfa()
    |> mfa_verify()
    |> finish_with(&return_auth_data/1)
  end

  defp sign_in(%Flow{assigns: assigns} = flow) do
    params = %{
      username: assigns.username,
      password: assigns.password,
      device_id: assigns.device_id
    }

    case API.sign_in(params) do
      {:ok, response} ->
        r_token = response.r_token
        devices = response.devices
        f_token_spec = response.f_token_spec
        f_request_id = response.f_request_id

        flow
        |> multiple_assigns(
          r_token: r_token,
          f_token_spec: f_token_spec,
          f_request_id: f_request_id
        )
        |> assign(:mfa_device_id, get_sms_mfa(devices))
        |> assign(:f_token, &generate_f_token/1)

      {:error, error} ->
        Logger.warn("[#{@mname}] error on 'sign_in' step: #{inspect(error)}")
        halt(error)
    end
  end

  defp get_sms_mfa(devices) do
    devices
    |> Enum.find(&(&1.type == "SMS"))
    |> Map.get(:id)
  end

  defp mfa(%Flow{assigns: assigns, halt: false} = flow) do
    params = %{
      mfa_device_id: assigns.mfa_device_id,
      device_id: assigns.device_id,
      r_token: assigns.r_token,
      f_token: assigns.f_token
    }

    case API.mfa(params) do
      {:ok, response} ->
        r_token = response.r_token
        f_token_spec = response.f_token_spec
        f_request_id = response.f_request_id

        flow
        |> multiple_assigns(
          r_token: r_token,
          f_token_spec: f_token_spec,
          f_request_id: f_request_id
        )
        |> assign(:f_token, &generate_f_token/1)

      {:error, error} ->
        Logger.warn("[#{@mname}] error on 'mfa' step: #{inspect(error)}")
        halt(error)
    end
  end

  defp mfa(%Flow{halt: true} = flow), do: flow

  defp mfa_verify(%Flow{halt: true} = flow), do: flow

  defp mfa_verify(%Flow{assigns: assigns, halt: false} = flow) do
    params = %{
      mfa_code: @mfa_code,
      device_id: assigns.device_id,
      r_token: assigns.r_token,
      f_token: assigns.f_token
    }

    case API.mfa_verify(params) do
      {:ok, response} ->
        r_token = response.r_token
        f_token_spec = response.f_token_spec
        f_request_id = response.f_request_id
        s_token = response.s_token
        enc_key = response.enc_key

        flow
        |> multiple_assigns(
          r_token: r_token,
          f_token_spec: f_token_spec,
          f_request_id: f_request_id,
          s_token: s_token,
          enc_key: enc_key
        )

      {:error, error} ->
        Logger.warn("[#{@mname}] error on 'mfa_verify' step: #{inspect(error)}")
        halt(error)
    end
  end

  defp return_auth_data(assigns) do
    %{
      r_token: assigns.r_token,
      f_token_spec: assigns.f_token_spec,
      s_token: assigns.s_token,
      f_request_id: assigns.f_request_id,
      enc_key: assigns.enc_key
    }
  end

  defp generate_f_token(assigns) do
    f_token_spec = assigns.f_token_spec
    f_request_id = assigns.f_request_id
    username = assigns.username
    device_id = assigns.device_id

    TokenBuilder.run(f_token_spec, username, device_id, f_request_id)
  end
end
