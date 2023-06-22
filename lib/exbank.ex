defmodule Exbank do
  @moduledoc """
  Exbank is the main module of the application. It provides the main API for
  the clients to interact with the application.

  The API is divided in two parts: the authentication and the client
  management. The authentication is used to create new users and to login
  existing ones. The client management is used to create new clients and to
  list the existing ones.

  The authentication is done using the Guardian library. The client management
  is done using the Exbank.BankProviders module, which is responsible for
  communicating with the banks.
  """

  alias Exbank.BankProviders
  alias Exbank.{Banks, Clients, Guardian, Users}

  require Logger

  @doc """
  Registers a new user in the application.

  ## Parameters

    * `username` - The username of the user.
    * `password` - The password of the user.

  ## Examples

    ```
    iex> register(username, password)
    {:ok, token}
    ```
  """
  def register(username, password) do
    user_attrs = %{username: username, password: password}

    with {:ok, user} <- Users.create_user(user_attrs),
         {:ok, token, _} <- Guardian.encode_and_sign(user) do
      {:ok, token}
    else
      {:error, %Ecto.Changeset{}} ->
        {:error, :INVALID_PARAMS}

      {:error, error} ->
        Logger.error("[Exbank] Internal error: #{inspect(error)}")
        {:error, :INTERNAL_ERROR}
    end
  end

  @doc """
  Logs in an existing user.

  ## Parameters

    * `username` - The username of the user.
    * `password` - The password of the user.

  ## Examples

    ```
    iex> login(username, password)
    {:ok, token}

    ```
  """
  def login(username, password) do
    with {:ok, user} <- Users.fetch_user_by_username(username),
         {:ok, token, _} <- Guardian.encode_and_sign(user),
         true <- user.password == password do
      {:ok, token}
    else
      false ->
        {:error, :UNAUTHORIZED}

      {:error, :USER_NOT_FOUND} ->
        {:error, :UNAUTHORIZED}
    end
  end

  @doc """
  Creates a new client for the given user.
  Each client is associated with a bank and has an identifier and a password
  that are used to authenticate the client with the bank.

  ## Parameters

    * `user` - The user that will own the client.
    * `identifier` - The identifier of the client.
    * `password` - The password of the client.
    * `bank_name` - The name of the bank that the client will be associated with.

  ## Examples

    ```
    iex> new_client(user, identifier, password, bank_name)
    {:ok, client_id}
    ```
  """
  def new_client(user, identifier, password, bank_name) do
    client_attrs = %{identifier: identifier, password: password, user_id: user.id}

    with {:ok, bank} <- Banks.fetch_bank_by_name(bank_name),
         {:ok, client} <- Clients.create_client(Map.put(client_attrs, :bank_id, bank.id)) do
      start_the_client(client, bank_name)
      {:ok, client.id}
    else
      {:error, :BANK_NOT_FOUND} ->
        {:error, :NOT_FOUND}

      {:error, error} ->
        {:error, error}
    end
  end

  defp start_the_client(client, bank_name) do
    Task.start(fn ->
      client = %{id: client.id, identifier: client.identifier, password: client.password}

      BankProviders.register_client(client, bank_name)
    end)
  end

  @doc """
  Lists the clients of the given user.

  ## Parameters

    * `user` - The user whose clients will be listed.

  ## Examples

    ```
    iex> list_user_clients(user)
    {:ok, [%{client_id: client_id, bank_name: bank_name}]}
    ```
  """
  @spec list_user_clients(user :: Users.User.t()) ::
          {:ok, list(%{client_id: binary(), bank_name: binary()}) | list()}
  def list_user_clients(user) do
    case Clients.list_clients_with_user(user.id) do
      [%Clients.Client{} | _] = clients ->
        {:ok, Enum.map(clients, &%{client_id: &1.id, bank_name: &1.bank.name})}

      [] ->
        {:ok, []}
    end
  end

  @doc """
  Gets the bank accounts of the given client.

  ## Parameters

    * `user` - The user that owns the client.
    * `client_id` - The id of the client related to the bank accounts.

  ## Examples

    ```
    iex> get_client_accounts(user, client_id)
    {:ok, [%{account_id: account_id, bank_name: bank_name}]}
    ```
  """

  @spec get_account_data(user :: Users.User.t(), client_id :: binary(), account_id :: binary()) ::
          {:ok, map()} | {:error, :INTERNAL_ERROR | :NOT_FOUND}
  def get_account_data(user, client_id, account_id) do
    with %Clients.Client{id: ^client_id} = client <-
           Clients.get_client_with_user(user.id, client_id),
         {client_data, bank_name} <- extract_client_data_and_bank_name(client),
         {:ok, account} <-
           BankProviders.get_account_information(client_data, bank_name, account_id) do
      {:ok, account}
    else
      nil ->
        {:error, :NOT_FOUND}

      {:error, error} ->
        Logger.error("[Exbank] Internal error: #{inspect(error)}")
        {:error, :INTERNAL_ERROR}
    end
  end

  @doc """

  Lists the bank accounts of the given client.

  ## Parameters

    * `user` - The user that owns the client.
    * `client_id` - The id of the client related to the bank accounts.

  ## Examples

    ```
    iex> list_client_accounts(user, client_id)
    {:ok, [transaction]}
    ```
  """
  def list_transactions_from_account(user, client_id, account_id) do
    with %Clients.Client{id: ^client_id} = client <-
           Clients.get_client_with_user(user.id, client_id),
         {client_data, bank_name} <- extract_client_data_and_bank_name(client),
         {:ok, transactions} <-
           BankProviders.list_account_transactions(client_data, bank_name, account_id) do
      {:ok, transactions}
    else
      nil ->
        {:error, :NOT_FOUND}

      {:error, error} ->
        Logger.error("[Exbank] Internal error: #{inspect(error)}")
        {:error, :INTERNAL_ERROR}
    end
  end

  defp extract_client_data_and_bank_name(client) do
    {%{id: client.id, identifier: client.identifier, password: client.password}, client.bank.name}
  end
end
