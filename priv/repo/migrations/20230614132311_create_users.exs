defmodule Exbank.Repo.Migrations.CreateUsers do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :password, :binary
      add :username, :string

      timestamps()
    end

    create unique_index(:users, :username)
  end
end
