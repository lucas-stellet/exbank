defmodule Exbank.Clients.Queries do
  @moduledoc false

  import Ecto.Query, warn: false

  alias Exbank.Clients.Client

  def with_user_id(query \\ Client, user_id) do
    query
    |> where([c], c.user_id == ^user_id)
  end

  def with_client_id(query \\ Client, client_id) do
    query
    |> where([c], c.id == ^client_id)
  end
end
