defmodule ExbankWeb.BankingControllerTest do
  @moduledoc false
  use ExbankWeb.ConnCase

  @bank_mock Exbank.BankProviders.BankMock

  describe "get_account" do
    setup %{conn: conn} do
      bank = insert(:bank, name: "bank_mock")

      user = insert(:user)

      client = insert(:client, bank_id: bank.id, user_id: user.id)

      account_id = generate_short_uuid!()

      bank_account = build(:mock_bank_account)

      %{
        conn: auth_user(conn, user),
        user: user,
        bank: bank,
        client: client,
        account_id: account_id,
        bank_account_data: bank_account
      }
    end

    test "return all account data related to the user client", %{
      conn: conn,
      client: client,
      account_id: account_id,
      bank_account_data: bank_account_data
    } do
      # bank provider mock
      expect(@bank_mock, :get_account_information, fn user_client_id, user_account_id ->
        assert user_client_id == client.id
        assert user_account_id == account_id

        {:ok, bank_account_data}
      end)

      conn = get(conn, ~p"/api/clients/#{client.id}/banking/accounts/#{account_id}")

      assert %{
               "alias" => bank_account_data.alias,
               "available_balance" => bank_account_data.available_balance,
               "current_balance" => bank_account_data.current_balance,
               "external_id" => bank_account_data.external_id,
               "number" => bank_account_data.number
             } == json_response(conn, 200)["data"]
    end

    test "return a not found status code if the client does not exist", %{
      conn: conn,
      account_id: account_id
    } do
      unknown_client_id = generate_short_uuid!()

      conn = get(conn, ~p"/api/clients/#{unknown_client_id}/banking/accounts/#{account_id}")

      assert %{"details" => "Not found"} == json_response(conn, 404)["error"]
    end

    test "return a internal server error if some unexpected errors happens with the bank provider",
         %{
           conn: conn,
           account_id: account_id,
           client: client
         } do
      expect(@bank_mock, :get_account_information, fn _, _ ->
        {:error, "the trainee turns the server out"}
      end)

      conn = get(conn, ~p"/api/clients/#{client.id}/banking/accounts/#{account_id}")

      assert %{"details" => "Internal server error"} == json_response(conn, 500)["error"]
    end
  end

  describe "list_transactions" do
    setup %{conn: conn} do
      bank = insert(:bank, name: "bank_mock")

      user = insert(:user)

      client = insert(:client, bank_id: bank.id, user_id: user.id)

      account_id = generate_short_uuid!()

      list_of_transactions = build_list(5, :mock_bank_transaction)

      %{
        conn: auth_user(conn, user),
        user: user,
        bank: bank,
        client: client,
        account_id: account_id,
        list_of_transactions: list_of_transactions
      }
    end

    test "return a list of account transactions", %{
      conn: conn,
      client: client,
      account_id: account_id,
      list_of_transactions: list_of_transactions
    } do
      # bank provider mock
      expect(@bank_mock, :list_account_transactions, fn user_client_id, user_account_id ->
        assert user_client_id == client.id
        assert user_account_id == account_id

        {:ok, list_of_transactions}
      end)

      conn = get(conn, ~p"/api/clients/#{client.id}/banking/accounts/#{account_id}/transactions")

      retrieved_list_of_transactions = json_response(conn, 200)["data"]

      for retrieved_transaction <- retrieved_list_of_transactions do
        Enum.any?(list_of_transactions, fn transaction ->
          retrieved_transaction == %{
            "amount" => transaction.amount,
            "description" => transaction.description,
            "external_id" => transaction.external_id,
            "date" => transaction.date
          }
        end)
      end
    end

    test "return a not found status code if the client does not exist", %{
      conn: conn,
      account_id: account_id
    } do
      unknown_client_id = generate_short_uuid!()

      conn =
        get(
          conn,
          ~p"/api/clients/#{unknown_client_id}/banking/accounts/#{account_id}/transactions"
        )

      assert %{"details" => "Not found"} == json_response(conn, 404)["error"]
    end

    test "return a internal server error if some unexpected errors happens with the bank provider",
         %{
           conn: conn,
           account_id: account_id,
           client: client
         } do
      expect(@bank_mock, :list_account_transactions, fn _, _ ->
        {:error, "the trainee turns the server out"}
      end)

      conn = get(conn, ~p"/api/clients/#{client.id}/banking/accounts/#{account_id}/transactions")

      assert %{"details" => "Internal server error"} == json_response(conn, 500)["error"]
    end
  end
end
