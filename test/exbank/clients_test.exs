defmodule Exbank.ClientsTest do
  @moduledoc false

  use Exbank.DataCase, async: true

  alias Exbank.Clients

  describe "create_client/1" do
    setup do
      bank = insert(:bank)
      user = insert(:user)

      %{bank: bank, user: user}
    end

    test "should insert and return a Client", %{bank: bank, user: user} do
      client_attrs = build(:client, %{bank_id: bank.id, user_id: user.id}) |> Map.from_struct()

      assert {:ok, client} = Clients.create_client(client_attrs)

      assert %Clients.Client{} = client

      assert client_attrs.identifier == client.identifier
    end

    test "should return an error if there is no user_id", %{bank: bank} do
      client_attrs = build(:client, %{bank_id: bank.id}) |> Map.from_struct()

      assert {:error, %Ecto.Changeset{errors: [user_id: _]}} = Clients.create_client(client_attrs)
    end

    test "should return an error if there is no bank_id", %{user: user} do
      client_attrs = build(:client, %{user_id: user.id}) |> Map.from_struct()

      assert {:error, %Ecto.Changeset{errors: [bank_id: _]}} = Clients.create_client(client_attrs)
    end
  end

  describe "list_clients_with_user/1" do
    setup do
      user = insert(:user)
      clients = insert_list(2, :client, user_id: user.id)

      %{user: user, clients: clients}
    end

    test "should return an empty list if there is no client tied to the user" do
      user = insert(:user)

      assert [] = Clients.list_clients_with_user(user.id)
    end

    test "should return a list of clients tied to the user", %{user: user, clients: clients} do
      assert retrieved_clients = Clients.list_clients_with_user(user.id)

      Enum.each(clients, fn client ->
        assert Enum.any?(retrieved_clients, fn c -> c.id == client.id end)
      end)
    end
  end

  describe "get_client_with_user/1" do
    setup do
      bank = insert(:bank)
      user = insert(:user)
      client = insert(:client, user_id: user.id, bank_id: bank.id)

      %{client: client, user: user}
    end

    test "should return a client when given the user_id and client_id", %{
      client: client,
      user: user
    } do
      assert retrieved_client = Clients.get_client_with_user(user.id, client.id)

      assert retrieved_client.user_id == user.id
      assert retrieved_client.id == client.id
    end

    test "should return nil when there is no client with the given params" do
      user = insert(:user)
      client = insert(:client)

      assert nil == Clients.get_client_with_user(user.id, client.id)
    end
  end
end
