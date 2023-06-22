defmodule Exbank.BankProviders do
  @moduledoc """
  This module is responsible for the bank providers management.
  Every call to a bank provider should be done through this module, that will be responsible for
  translating the bank provider's API data to the Exbank API.
  """

  alias Exbank.BankProviders.{BankAccount, BankTransaction}

  @type client :: %{
          id: binary(),
          identifier: binary(),
          password: binary()
        }

  @spec register_client(client :: client(), bank_name :: binary()) ::
          :ok | {:error, any()}
  def register_client(client, bank_name) do
    case provider_module(bank_name).register_client(
           client.id,
           client.identifier,
           client.password
         ) do
      :ok ->
        :ok

      error ->
        error
    end
  end

  @spec list_accounts(client :: client(), bank_name :: binary()) ::
          {:ok, list(map()) | list()} | {:error, any()}
  def list_accounts(client, bank_name) do
    case provider_module(bank_name).list_accounts(client.id) do
      {:ok, accounts_list} ->
        {:ok, accounts_list}

      {:error, :CLIENT_OFFLINE} ->
        case register_client(client, bank_name) do
          :ok ->
            list_accounts(client, bank_name)

          error ->
            error
        end

      error ->
        error
    end
  end

  @spec get_account_information(client :: client(), bank_name :: binary(), account_id :: binary()) ::
          {:ok, map()} | {:error, any()}
  def get_account_information(client, bank_name, account_id) do
    case provider_module(bank_name).get_account_information(client.id, account_id) do
      {:ok, data} ->
        {:ok, build_bank_account(data)}

      {:error, :CLIENT_OFFLINE} ->
        case register_client(client, bank_name) do
          :ok ->
            get_account_information(client, bank_name, account_id)

          error ->
            error
        end

      error ->
        error
    end
  end

  defp build_bank_account(data) do
    %{
      current_balance: BankAccount.current_balance(data),
      available_balance: BankAccount.available_balance(data),
      number: BankAccount.number(data),
      alias: BankAccount.alias(data),
      external_id: BankAccount.external_id(data)
    }
  end

  @spec list_account_transactions(
          client :: client(),
          bank_name :: binary(),
          account_id :: binary()
        ) ::
          {:ok, list(map()) | list()} | {:error, any()}
  def list_account_transactions(client, bank_name, account_id) do
    case provider_module(bank_name).list_account_transactions(client.id, account_id) do
      {:ok, data} ->
        {:ok, build_transactions(data)}

      {:error, :CLIENT_OFFLINE} ->
        case register_client(client, bank_name) do
          :ok ->
            list_account_transactions(client, bank_name, account_id)

          error ->
            error
        end

      error ->
        error
    end
  end

  defp build_transactions(data) do
    Enum.map(data, fn transaction ->
      %{
        amount: transaction |> BankTransaction.amount() |> Money.to_string(),
        description: BankTransaction.description(transaction),
        date: BankTransaction.date(transaction),
        external_id: BankTransaction.external_id(transaction)
      }
    end)
  end

  defp provider_module(bank_name),
    do: String.to_atom("Elixir.Exbank.BankProviders." <> Macro.camelize(bank_name))
end
