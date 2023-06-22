defmodule Exbank.BankProviders.Teller do
  @moduledoc false

  alias Exbank.BankProviders.Teller.{BankAccount, BankTransaction}
  alias Teller, as: TellerClient

  use Exbank.BankProviders.Provider,
    client: TellerClient.client(),
    client_manager: TellerClientManager

  require Logger

  @impl true
  def register_client(client_id, identifier, password) do
    if client_is_alive?(client_id) do
      :ok
    else
      DynamicSupervisor.start_child(
        @clients_manager,
        %{
          id: Teller.client(),
          start: {__MODULE__, :start_client, [client_id, identifier, password]}
        }
      )
      |> case do
        {:ok, _} ->
          :ok

        error ->
          error
      end
    end
  end

  def start_client(client_id, identifier, password) do
    GenServer.start_link(Teller.client(), %{username: identifier, password: password},
      name: client_registry(client_id)
    )
  end

  @impl true
  def list_account_transactions(client_id, account_id) do
    with true <- client_is_alive?(client_id),
         {:ok, transactions_data} <- list_transactions(client_id, account_id) do
      {:ok, for(transaction <- transactions_data, do: BankTransaction.new(transaction))}
    else
      false ->
        Logger.error(
          "[#{@mname}] client with id '#{client_id}' is not alive: not restarted by Supervisor"
        )

        {:error, :CLIENT_OFFLINE}

      error ->
        handle_response(error)
    end
  end

  defp list_transactions(client_id, account_id) do
    client_id
    |> client_registry()
    |> TellerClient.list_transactions(%{account_id: account_id})
    |> handle_response()
  end

  @impl true
  def get_account_information(client_id, account_id) do
    with true <- client_is_alive?(client_id),
         {:ok, balances_data} <- list_balances(client_id, account_id),
         {:ok, account_data} <- get_account_details(client_id, account_id) do
      {:ok, BankAccount.new(client_registry(client_id), balances_data, account_data)}
    else
      false ->
        Logger.error(
          "[#{@mname}] client with id '#{client_id}' is not alive: not restarted by Supervisor"
        )

        {:error, :CLIENT_OFFLINE}

      error ->
        handle_response(error)
    end
  end

  defp get_account_details(client_id, account_id) do
    client_id
    |> client_registry()
    |> TellerClient.get_account_details(%{account_id: account_id})
    |> handle_response()
  end

  defp list_balances(client_id, account_id) do
    client_id
    |> client_registry()
    |> TellerClient.list_balances(%{account_id: account_id})
    |> handle_response()
  end

  defp handle_response({:error, %{code: "bad_request"} = response}) do
    Logger.error("[#{@mname}] Bad return from Teller API: #{inspect(response)}")

    {:error, :BAD_REQUEST}
  end

  defp handle_response({:error, "Not Found"}) do
    Logger.error("[#{@mname}] Bad return from Teller API: resource NOT FOUND}")

    {:error, :RESOURCE_NOT_FOUND}
  end

  defp handle_response(response), do: response
end
