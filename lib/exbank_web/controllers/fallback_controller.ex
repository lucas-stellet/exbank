defmodule ExbankWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ExbankWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{}}) do
    conn
    |> put_status(:conflict)
    |> put_view(json: ExbankWeb.ErrorJSON)
    |> render(:"409")
  end

  def call(conn, {:error, :NOT_FOUND}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: ExbankWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :RESOURCE_NOT_FOUND}) do
    conn
    |> put_status(500)
    |> put_view(json: ExbankWeb.ErrorJSON)
    |> render(:"500")
  end

  def call(conn, {:error, :INTERNAL_ERROR}) do
    conn
    |> put_status(500)
    |> put_view(json: ExbankWeb.ErrorJSON)
    |> render(:"500")
  end

  def call(conn, {:error, :INVALID_PARAMS}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: ExbankWeb.ErrorJSON)
    |> render(:"422")
  end

  def call(conn, {:error, :UNAUTHORIZED}) do
    conn
    |> put_status(401)
    |> put_view(json: ExbankWeb.ErrorJSON)
    |> render(:"401")
  end
end
