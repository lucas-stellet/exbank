defmodule Exbank.Banks.Queries do
  @moduledoc false

  import Ecto.Query, warn: false

  alias Exbank.Banks.Bank

  def with_name(query \\ Bank, name) do
    query
    |> where([b], b.name == ^name)
  end

  def with_active_status(query \\ Bank, status) do
    query
    |> where([b], b.active == ^status)
  end
end
