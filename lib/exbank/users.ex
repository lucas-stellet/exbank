defmodule Exbank.Users do
  @moduledoc """
  The Users context.
  """

  alias Exbank.Repo
  alias Exbank.Users.{Queries, User}

  import Queries

  @type user_attrs :: %{
          username: binary(),
          password: binary()
        }

  @doc """
  Fetchs a single user.

  Return an error tuple in case of no user is found.

  ## Examples

      iex> fetch_user(123)
      {:OK, %User{}}

      iex> fetch_user(456)
      {:error, :USER_NOT_FOUND}

  """
  @spec fetch_user(id :: binary()) :: {:ok, User.t()} | {:error, :USER_NOT_FOUND}
  def fetch_user(id) do
    case Repo.get(User, id) do
      nil ->
        {:error, :USER_NOT_FOUND}

      user ->
        {:ok, user}
    end
  end

  @spec fetch_user_by_username(username :: binary()) ::
          {:ok, User.t()} | {:error, :USER_NOT_FOUND}
  def fetch_user_by_username(username) do
    username
    |> with_username()
    |> Repo.one()
    |> case do
      nil ->
        {:error, :USER_NOT_FOUND}

      user ->
        {:ok, user}
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user(attrs :: user_attrs()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
