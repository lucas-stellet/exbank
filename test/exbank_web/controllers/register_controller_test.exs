defmodule ExbankWeb.RegisterControllerTest do
  @moduledoc false
  use ExbankWeb.ConnCase

  describe "new" do
    test "register an user and returns a valid token", %{conn: conn} do
      params = %{
        "username" => "john_doe",
        "password" => "123pass456"
      }

      conn = post(conn, ~p"/api/register", params)

      assert %{"token" => _} = json_response(conn, 201)["data"]
    end

    test "try to register an user with invalid data return a 422 status code", %{conn: conn} do
      params = %{
        "username" => "john-doe",
        "password" => "123"
      }

      conn = post(conn, ~p"/api/register", params)

      assert json_response(conn, 422)
    end
  end

  describe "login" do
    setup %{conn: conn} do
      user = insert(:user)

      %{conn: conn, user: user}
    end

    test "returns a valid token given a valid user data", %{conn: conn, user: user} do
      params = %{
        "username" => user.username,
        "password" => user.password
      }

      conn = post(conn, ~p"/api/auth", params)

      assert %{"token" => _} = json_response(conn, 200)["data"]
    end

    test "returns 404 status code when given a invalid user data", %{conn: conn} do
      params = %{
        "username" => "fake_user",
        "password" => "fakepass"
      }

      conn = post(conn, ~p"/api/auth", params)

      assert %{"details" => "Unauthorized"} = json_response(conn, 401)["error"]
    end
  end
end
