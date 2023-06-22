defmodule Exbank.EctoTypes.EncryptedBinary do
  @moduledoc false

  use Cloak.Ecto.Binary, vault: Exbank.Vault
end
