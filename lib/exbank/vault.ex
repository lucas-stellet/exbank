defmodule Exbank.Vault do
  @moduledoc false

  use Cloak.Vault, otp_app: :exbank

  @impl GenServer
  def init(config) do
    vault_key = Keyword.get(config, :vault_key) |> Base.decode64!()

    config =
      Keyword.put(config, :ciphers,
        default: {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: vault_key}
      )

    {:ok, config}
  end
end
