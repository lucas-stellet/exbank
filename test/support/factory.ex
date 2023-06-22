defmodule Exbank.Factory do
  @moduledoc """
  Factory module for testing purposes.
  Uses ExMachina library to create factories
  """

  use ExMachina.Ecto, repo: Exbank.Repo

  alias Exbank.Banks.Bank
  alias Exbank.Clients.Client
  alias Exbank.Users.User
  alias Exbank.BankProviders.BankMock.{BankAccount, BankTransaction}

  def bank_factory do
    %Bank{
      name: Faker.Company.name(),
      active: true
    }
  end

  def inactive_bank_factory do
    struct!(
      bank_factory(),
      active: false
    )
  end

  def user_factory do
    %User{
      password: Faker.Superhero.name() <> Faker.Beer.name(),
      username: Faker.Internet.user_name()
    }
  end

  def client_factory do
    %Client{
      identifier: Faker.Internet.user_name(),
      password: Faker.Superhero.name() <> Faker.Beer.name()
    }
  end

  def mock_bank_account_factory do
    # balance = Enum.random(1000..9999) |> Money.new(:USD)

    %BankAccount{
      # current_balance: balance,
      # available_balance: Money.add(balance, Enum.random(1000..9999) |> Money.new(:USD)),
      current_balance: Enum.random(1000..9999),
      available_balance: Enum.random(1000..9999),
      number: Faker.Util.format("%8d"),
      alias: Faker.Lorem.sentence(5),
      external_id: Ecto.UUID.generate() |> ShortUUID.encode!()
    }
  end

  def mock_bank_transaction_factory do
    %BankTransaction{
      amount: Enum.random(-50..50),
      date: Enum.random(1..15) |> Faker.Date.backward() |> Date.to_string(),
      description: Faker.Lorem.sentence(3),
      external_id: Ecto.UUID.generate() |> ShortUUID.encode!()
    }
  end
end
