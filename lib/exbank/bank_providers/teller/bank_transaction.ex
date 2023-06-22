defmodule Exbank.BankProviders.Teller.BankTransaction do
  @moduledoc false
  defstruct ~w(amount date id posted title)a

  def new(transaction_data) do
    transaction_data
    |> Map.to_list()
    |> then(&struct(__MODULE__, &1))
  end
end

defimpl Exbank.BankProviders.BankTransaction,
  for: Exbank.BankProviders.Teller.BankTransaction do
  def date(teller_transaction), do: teller_transaction.date

  def amount(teller_transaction), do: Money.new(teller_transaction.amount, :USD)

  def description(teller_transaction), do: teller_transaction.title

  def external_id(teller_transaction), do: teller_transaction.id
end
