defmodule Exbank.Clients.Client do
  @moduledoc """
  The Banking Client schema
  """
  use Exbank.Schema

  import Ecto.Changeset

  alias Exbank.Banks
  alias Exbank.Users

  @derive {Jason.Encoder, only: ~w(id identifier password )a}

  schema "banking_clients" do
    field :identifier, EncryptedBinary
    field :password, EncryptedBinary

    belongs_to :user, Users.User
    belongs_to :bank, Banks.Bank

    timestamps()
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> cast(attrs, [:identifier, :password, :bank_id, :user_id])
    |> validate_required([:identifier, :password, :bank_id, :user_id])
    |> foreign_key_constraint(:bank_id, message: "user does not exist")
    |> foreign_key_constraint(:user_id, message: "bank does not exist")
  end
end
