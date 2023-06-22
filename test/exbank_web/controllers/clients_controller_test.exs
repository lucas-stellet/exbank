defmodule ExbankWeb.ClientsControllerTest do
  @moduledoc false
  use ExbankWeb.ConnCase

  @bank_name "teller"

  setup %{conn: conn} do
    user = insert(:user)

    bank = insert(:bank, name: @bank_name)

    %{conn: auth_user(conn, user), user: user, bank: bank}
  end

  describe "new" do
    test "register a new client and start the bank provider client process successfully", %{
      conn: conn
    } do
      params = %{
        "identifier" => "john_doe",
        "password" => "123password",
        "bank_name" => @bank_name
      }

      assert conn = post(conn, ~p"/api/clients", params)

      assert %{"client_id" => _client_id} = json_response(conn, 201)["data"]
    end

    test "receives a 404 status code if the given bank does not exist", %{
      conn: conn
    } do
      params = %{
        "identifier" => "john_doe",
        "password" => "123password",
        "bank_name" => "unknownbank"
      }

      assert conn = post(conn, ~p"/api/clients", params)

      assert %{"details" => "Not found"} = json_response(conn, 404)["error"]
    end
  end

  describe "list" do
    test "returns a list of clients registered by the user", %{
      conn: conn,
      user: user,
      bank: bank
    } do
      clients_list = insert_list(3, :client, user_id: user.id, bank_id: bank.id)

      conn = get(conn, ~p"/api/clients")

      retrieved_clients_list = json_response(conn, 200)["data"]

      Enum.each(clients_list, fn client ->
        assert Enum.any?(retrieved_clients_list, &(&1["client_id"] == client.id))
      end)
    end

    test "returns a empty list if the there is no clients registered by the user", %{
      conn: conn
    } do
      conn = get(conn, ~p"/api/clients")

      assert [] = json_response(conn, 200)["data"]
    end
  end
end
