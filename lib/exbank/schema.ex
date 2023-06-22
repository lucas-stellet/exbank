defmodule Exbank.Schema do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      alias Exbank.EctoTypes.EncryptedBinary

      @primary_key {:id, Ecto.ShortUUID, autogenerate: true}
      @foreign_key_type Ecto.ShortUUID

      @type t :: %__MODULE__{}
    end
  end
end
