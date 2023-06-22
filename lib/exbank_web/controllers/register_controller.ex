defmodule ExbankWeb.RegisterController do
  use ExbankWeb, :controller

  action_fallback ExbankWeb.FallbackController

  def new(conn, %{"username" => username, "password" => password}) do
    with {:ok, token} <- Exbank.register(username, password) do
      conn
      |> put_status(:created)
      |> render(:new, token: token)
    end
  end

  def login(conn, %{"username" => username, "password" => password}) do
    with {:ok, token} <- Exbank.login(username, password) do
      conn
      |> put_status(:ok)
      |> render(:new, token: token)
    end
  end
end
