defmodule Teller.Client do
  @moduledoc false
  use GenServer

  alias Teller.API
  alias Teller.Client.{AccountDecryption, Authenticate, TokenBuilder}

  require Logger

  defstruct ~w(device_id username password f_request_id f_token s_token r_token enc_key )a

  @resources_available API.resources_available()

  @mname "Teller.Client"

  @spec make_request(client_reference :: tuple(), resource :: atom(), params :: map()) ::
          {:ok, map()} | {:error, atom() | map()}
  def make_request(client_reference, resource, params \\ %{})

  def make_request(client_reference, resource, params) when resource in @resources_available do
    GenServer.call(client_reference, {:call_api, resource, params})
  end

  def make_request(_, _, _), do: {:error, :unknown_resource}

  @spec decrypt_account_number(client_reference :: tuple(), account_number :: binary()) ::
          {:ok, binary()}
  def decrypt_account_number(client_reference, account_number) do
    GenServer.call(client_reference, {:decrypt_account, account_number})
  end

  @impl true
  def init(%{username: username, password: password}) do
    initial_state = %__MODULE__{
      username: username,
      password: password
    }

    {:ok, initial_state, {:continue, :signin}}
  end

  @impl true
  def handle_continue(:signin, state) do
    case authenticate(state) do
      {:ok, updated_state} ->
        {:noreply, updated_state}

      {:error, _error} ->
        {:stop, :normal, :authentication_failed, state}
    end
  end

  @impl true
  def handle_call({:call_api, resource, params}, _from, state) do
    call_api(resource, params, state)
  end

  @impl true
  def handle_call(
        {:decrypt_account, account_number},
        _from,
        %__MODULE__{enc_key: enc_key, username: username} = state
      ) do
    {:reply, AccountDecryption.run(enc_key, username, account_number), state}
  end

  defp call_api(resource, params, state) do
    api_params = [Map.merge(params, state)]

    case apply(API, resource, api_params) do
      {:ok, %{data: data, headers: headers}} ->
        updated_state = update_state(headers, state)

        {:reply, {:ok, data}, updated_state}

      {:error, %{code: "session_expired"}} ->
        case authenticate(state) do
          {:ok, updated_state} ->
            call_api(resource, params, updated_state)

          {:error, error} ->
            {:reply, {:error, error}, state}
        end

      {:error, error} ->
        Logger.warn("[#{@mname}] error when trying to call the resource: #{inspect(resource)}")

        {:reply, {:error, error}, state}
    end
  end

  defp authenticate(%__MODULE__{username: username, password: password} = state) do
    device_id = generate_device_id()

    state = %__MODULE__{state | device_id: device_id}

    case Authenticate.run(device_id, username, password) do
      {:ok, response} ->
        updated_state = update_state(response, state)

        Logger.debug("[#{@mname}] state updated: #{inspect(updated_state)}")

        {:ok, updated_state}

      {:error, error} ->
        Logger.warn("[#{@mname}] error when trying to authenticate: #{inspect(error)}")

        {:error, error}
    end
  end

  defp generate_device_id do
    letters = ~w(A B C D E F G H I J K L M N O P Q R S T U V X W Y Z)
    numbers = [2, 3, 4, 5, 6, 7]

    Enum.map_join(1..16, "", fn _ ->
      Enum.random(letters ++ numbers)
    end)
  end

  defp update_state(auth_data, state) do
    f_token_spec = auth_data.f_token_spec
    f_request_id = auth_data.f_request_id
    username = state.username
    device_id = state.device_id
    enc_key = Map.get(auth_data, :enc_key, state.enc_key)

    f_token = TokenBuilder.run(f_token_spec, username, device_id, f_request_id)

    %__MODULE__{
      state
      | f_token: f_token,
        r_token: auth_data.r_token,
        s_token: auth_data.s_token,
        f_request_id: auth_data.f_request_id,
        enc_key: enc_key
    }
  end
end
