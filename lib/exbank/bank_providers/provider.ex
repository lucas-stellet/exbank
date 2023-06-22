defmodule Exbank.BankProviders.Provider do
  @moduledoc """
  A behaviour module that defines callbacks that have to been implemented for each bank provider module
  It is necessary to translate the bank provider's API data to the Exbank AP, what make possible to connect
  with multiple bank providers.
  """

  @type error ::
          %{
            details: binary()
          }
          | atom()

  @callback register_client(client_id :: binary(), identifier :: binary(), password :: binary()) ::
              :ok | {:error, error()}

  @callback get_account_information(client_id :: binary(), bank_account_reference :: binary()) ::
              {:ok, map()} | {:error, error()}

  @callback list_account_transactions(client_id :: binary(), bank_account_reference :: binary()) ::
              {:ok, list(map)} | {:error, error() | atom()}

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      alias Exbank.BankProviders

      @behaviour BankProviders.Provider

      @registry BankClientsRegistry

      @mname __MODULE__

      @clients_manager Keyword.get(opts, :client_manager)

      def client_is_alive?(client_reference) do
        case Registry.lookup(@registry, client_reference) do
          [{_pid, nil}] ->
            true

          [] ->
            false
        end
      end

      def client_registry(client_id) do
        {:via, Registry, {@registry, client_id}}
      end
    end
  end
end
