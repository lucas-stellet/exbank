defmodule Teller do
  @moduledoc false

  alias Teller.Client

  def client, do: Client

  def list_transactions(client_reference, params),
    do: Client.make_request(client_reference, :list_transactions, params)

  def get_account_details(client_reference, params),
    do: Client.make_request(client_reference, :get_account_details, params)

  def list_balances(client_reference, params),
    do: Client.make_request(client_reference, :list_balances, params)

  def decrypt_account_number(client_reference, account_number),
    do: Client.decrypt_account_number(client_reference, account_number)
end
