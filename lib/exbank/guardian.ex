defmodule Exbank.Guardian do
  @moduledoc """
  Guardian implement for token generation.
  """
  use Guardian, otp_app: :exbank

  alias Exbank.Users

  def subject_for_token(%Users.User{id: id}, _claims) do
    {:ok, id}
  end

  def subject_for_token(_, _) do
    {:error, :UNAUTHORIZED}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Users.fetch_user(id) do
      {:ok, user} ->
        {:ok, user}

      {:error, :USER_NOT_FOUND} ->
        {:error, :NOT_FOUND}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :UNAUTHORIZED}
  end

  def after_encode_and_sign(_resource, _claims, token, _options) do
    {:ok, Base.encode64(token, padding: false)}
  end
end
