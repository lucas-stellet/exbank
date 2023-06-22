defmodule Exbank.Users.Queries do
  @moduledoc """
  The basic queries to be used in composition to build complex queries.
  """
  import Ecto.Query, warn: false

  alias Exbank.Users.User

  def with_username(query \\ User, username) do
    query
    |> where([u], u.username == ^username)
  end
end
