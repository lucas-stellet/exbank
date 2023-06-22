defmodule ExbankWeb.ClientsController do
  use ExbankWeb, :controller

  action_fallback ExbankWeb.FallbackController

  def new(conn, %{"identifier" => identifier, "password" => password, "bank_name" => bank_name}) do
    user = get_authenticated_user(conn)

    with {:ok, client_id} <- Exbank.new_client(user, identifier, password, bank_name) do
      conn
      |> put_status(:created)
      |> render(:new, client_id: client_id)
    end
  end

  def list(conn, _params) do
    user = get_authenticated_user(conn)

    with {:ok, clients} <- Exbank.list_user_clients(user) do
      conn
      |> put_status(:ok)
      |> render(:list, clients: clients)
    end
  end
end
