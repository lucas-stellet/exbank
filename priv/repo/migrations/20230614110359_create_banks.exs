defmodule Exbank.Repo.Migrations.CreateBanks do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:banks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :active, :boolean, default: false, null: false

      timestamps()
    end
  end
end
