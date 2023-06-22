defmodule Exbank.Repo do
  use Ecto.Repo,
    otp_app: :exbank,
    adapter: Ecto.Adapters.Postgres
end
