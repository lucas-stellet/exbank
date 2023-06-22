defmodule ExbankWeb.Auth do
  @moduledoc false

  import Plug.Conn
  import Phoenix.Controller

  alias Exbank.Guardian

  require Logger

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, claims} <- Guardian.decode_and_verify(token),
         {:ok, user} <- Guardian.resource_from_claims(claims) do
      assign(conn, :authenticated_user, user)
    else
      [] ->
        halt_conn(conn)

      {:error, error} ->
        Logger.error("[ExbankWeb.Auth] error when checking authentication: #{inspect(error)}")

        halt_conn(conn)
    end
  end

  defp halt_conn(conn) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: ExbankWeb.ErrorJSON)
    |> render(:"401")
    |> halt()
  end
end
