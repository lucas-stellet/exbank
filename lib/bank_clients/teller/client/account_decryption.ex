defmodule Teller.Client.AccountDecryption do
  @moduledoc false

  def run(enc_key, username, acc_number) do
    username = <<"#{username}">>

    key =
      enc_key
      |> Base.decode64!()
      |> Jason.decode!(keys: :atoms)
      |> Map.get(:key)
      |> Base.decode64!()

    [cipher_text, iv, tag] =
      acc_number
      |> String.split(":", parts: 3)
      |> Enum.map(fn x -> Base.decode64!(x, padding: true) end)

    :crypto.crypto_one_time_aead(:aes_256_gcm, key, iv, cipher_text, username, tag, false)
  end
end
