defmodule Exbank.BankProviders.Teller.BankAccount do
  @moduledoc false
  defstruct ~w(ach alias id number product available last_transactions ledger)a

  def new(client_id, balance_data, account_data) do
    account_data = %{
      account_data
      | number: Teller.decrypt_account_number(client_id, account_data.number)
    }

    [balance_data, account_data]
    |> Enum.map(&Map.to_list/1)
    |> List.flatten()
    |> then(&struct(__MODULE__, &1))
  end
end

defimpl Exbank.BankProviders.BankAccount,
  for: Exbank.BankProviders.Teller.BankAccount do
  def current_balance(data), do: data.ledger

  def available_balance(data), do: data.available

  def number(data), do: data.number

  def alias(data), do: data.alias

  def external_id(data), do: data.id
end
