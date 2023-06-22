defmodule Exbank.Banks.Bank do
  @moduledoc """
  A bank schema.
  """

  use Exbank.Schema

  alias Exbank.Clients

  import Ecto.Changeset

  schema "banks" do
    field :active, :boolean, default: false
    field :name, :string

    has_many :banking_clients, Clients.Client

    timestamps()
  end

  @doc false
  def changeset(bank, attrs) do
    bank
    |> cast(attrs, [:name, :active])
    |> validate_required([:name, :active])
  end
end
