defmodule Exbank.Banks do
  @moduledoc """
  The Banking.Banks context.
  """

  alias Exbank.Banks
  alias Banks.{Bank, Queries}
  alias Exbank.Repo

  import Queries

  @doc """
  Fetchs a bank by his name.

  Returns an error tuple if the bank does not exists.

  ## Examples

      iex> fetch_bank_by_name("Bank X")
      {:ok, %Bank{}}

      iex> fetch_bank_by_name("Unknown Bank")
      ** {:error, :BANK_NOT_FOUND}

  """
  @spec fetch_bank_by_name(name :: binary()) :: {:ok, Bank.t()} | {:error, :BANK_NOT_FOUND}
  def fetch_bank_by_name(name) do
    Bank
    |> with_name(name)
    |> with_active_status(true)
    |> Repo.one()
    |> case do
      nil ->
        {:error, :BANK_NOT_FOUND}

      bank ->
        {:ok, bank}
    end
  end
end
