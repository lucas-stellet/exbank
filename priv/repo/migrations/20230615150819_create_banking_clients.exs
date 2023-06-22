defmodule Exbank.Repo.Migrations.CreateBankingClients do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:banking_clients, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :identifier, :binary
      add :password, :binary
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :bank_id, references(:banks, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:banking_clients, [:bank_id])
    create index(:banking_clients, [:user_id])
  end
end
