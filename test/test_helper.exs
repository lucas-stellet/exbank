Mox.defmock(Exbank.BankProviders.BankMock, for: Exbank.BankProviders.Provider)

{:ok, _} = Application.ensure_all_started(:ex_machina, :mox)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Exbank.Repo, :manual)
