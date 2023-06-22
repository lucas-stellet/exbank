defmodule Exbank.Users.User do
  @moduledoc false

  use Exbank.Schema

  import Ecto.Changeset

  alias Exbank.Clients

  @derive {Jason.Encoder, only: [:id, :username, :password]}
  schema "users" do
    field :username, :string
    field :password, EncryptedBinary

    has_many :bank_clients, Clients.Client

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:password, :username])
    |> validate_required([:password, :username])
    |> unique_constraint(:username, message: "username already is being used")
    |> validate_length(:password, min: 6, max: 20)
    |> validate_format(:username, ~r/^[a-zA-Z_]+$/, message: "only letters and underline symbol")
    |> validate_length(:username, min: 6, message: "minimum 6 characteres")
  end
end
