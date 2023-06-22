defmodule ExbankWeb.BankingController do
  use ExbankWeb, :controller

  action_fallback ExbankWeb.FallbackController

  def get_account(conn, %{"client_id" => client_id, "account_id" => account_id}) do
    user = get_authenticated_user(conn)

    with {:ok, account} <- Exbank.get_account_data(user, client_id, account_id) do
      conn
      |> put_status(:ok)
      |> render(:data, data: account)
    end
  end

  def list_transactions(conn, %{"client_id" => client_id, "account_id" => account_id}) do
    user = get_authenticated_user(conn)

    with {:ok, transactions} <- Exbank.list_transactions_from_account(user, client_id, account_id) do
      conn
      |> put_status(:ok)
      |> render(:data, data: transactions)
    end
  end
end
