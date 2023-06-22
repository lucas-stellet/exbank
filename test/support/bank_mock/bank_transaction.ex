defmodule Exbank.BankProviders.BankMock.BankTransaction do
  @moduledoc false
  defstruct ~w(date amount description external_id)a
end

defimpl Exbank.BankProviders.BankTransaction,
  for: Exbank.BankProviders.BankMock.BankTransaction do
  def date(transaction), do: transaction.date

  def amount(transaction), do: Money.new(transaction.amount, :USD)

  def description(transaction), do: transaction.description

  def external_id(transaction), do: transaction.external_id
end
