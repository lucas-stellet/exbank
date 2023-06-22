defmodule Exbank.UserTest do
  @moduledoc false

  use Exbank.DataCase, async: true

  alias Exbank.Users

  describe "create_user" do
    test "should return a user when given correct attrs" do
      user_attrs = %{
        username: "john_doe",
        password: "123password"
      }

      assert {:ok, %Users.User{}} = Users.create_user(user_attrs)
    end

    test "should return an error when given an usernem with invalid characteres" do
      user_attrs = %{
        username: "john-doe/mario",
        password: "123password"
      }

      assert {:error, changeset} = Users.create_user(user_attrs)

      assert "only letters and underline symbol" in errors_on(changeset).username
    end

    test "should return an error when given a password with less than 6 characteres" do
      user_attrs = %{
        username: "john_doe",
        password: "short"
      }

      assert {:error, changeset} = Users.create_user(user_attrs)

      assert "should be at least 6 character(s)" in errors_on(changeset).password
    end
  end

  describe "fetch_user" do
    setup do
      user = insert(:user)
      %{user: user}
    end

    test "should return an ok tuple with user when given a valid user id", %{user: user} do
      assert {:ok, retrieved_user} = Users.fetch_user(user.id)

      assert retrieved_user.id == user.id
    end

    test "should return an error tuple when given an invalid user id" do
      invalid_user_id = generate_short_uuid!()

      assert {:error, :USER_NOT_FOUND} = Users.fetch_user(invalid_user_id)
    end
  end

  describe "fetch_user_by_username" do
    setup do
      user = insert(:user)
      %{user: user}
    end

    test "should return an ok tuple with user when given a valid username", %{user: user} do
      assert {:ok, retrieved_user} = Users.fetch_user_by_username(user.username)

      assert retrieved_user.id == user.id
    end

    test "should return an error tuple when given an invalid username" do
      invalid_username = Faker.Internet.user_name()

      assert {:error, :USER_NOT_FOUND} = Users.fetch_user_by_username(invalid_username)
    end
  end
end
