defmodule Exbank.BankProviders.BankMock.BankAccount do
  @moduledoc false
  defstruct ~w(current_balance available_balance number alias external_id)a
end

defimpl Exbank.BankProviders.BankAccount,
  for: Exbank.BankProviders.BankMock.BankAccount do
  def current_balance(data), do: data.current_balance

  def available_balance(data), do: data.available_balance

  def number(data), do: data.number

  def alias(data), do: data.alias

  def external_id(data), do: data.external_id
end
