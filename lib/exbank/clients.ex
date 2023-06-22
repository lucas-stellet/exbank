defmodule Exbank.Clients do
  @moduledoc """
  The Banking.Clients context.
  """
  alias Exbank.Clients
  alias Clients.{Client, Queries}
  alias Exbank.Repo

  import Queries

  @doc """
  Returns the list of banking_clients.

  ## Examples

      iex> list_clients_with_user(user_id)
      [%Client{}, ...]

  """
  @spec list_clients_with_user(user_id :: binary()) :: list(Client.t()) | list()
  def list_clients_with_user(user_id) do
    Client
    |> with_user_id(user_id)
    |> Repo.all()
    |> Repo.preload(:bank)
  end

  @spec get_client_with_user(user_id :: binary(), client_id :: binary()) :: Client.t() | nil
  def get_client_with_user(user_id, client_id) do
    Client
    |> with_client_id(client_id)
    |> with_user_id(user_id)
    |> Repo.all()
    |> case do
      [] ->
        nil

      [%Clients.Client{} = client] ->
        Repo.preload(client, :bank)
    end
  end

  @doc """
  Creates a client.

  ## Examples

      iex> create_client(%{field: value})
      {:ok, %Client{}}

      iex> create_client(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_client(attrs \\ %{}) do
    %Client{}
    |> Client.changeset(attrs)
    |> Repo.insert()
  end
end
