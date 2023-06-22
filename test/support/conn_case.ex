defmodule ExbankWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use ExbankWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint ExbankWeb.Endpoint

      use ExbankWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import ExbankWeb.ConnCase
      import Exbank.Factory
      import Mox

      alias Exbank.Guardian

      @doc """
      Authenticates a user in the connection.

      ## Examples

          iex> auth_user(conn, user)
          %Plug.Conn{...}
      """

      def auth_user(conn, user) do
        {:ok, token, _} = Guardian.encode_and_sign(user)

        conn
        |> put_req_header("authorization", "Bearer #{token}")
      end

      @doc """
      Generates a valid ShortUUID.

      ## Examples

          iex> generate_short_uuid()
          "o5RepWqSFZZCftv8kLVvWk"
      """
      def generate_short_uuid! do
        Ecto.UUID.generate()
        |> ShortUUID.encode!()
      end
    end
  end

  setup tags do
    Exbank.DataCase.setup_sandbox(tags)

    {:ok,
     conn:
       Phoenix.ConnTest.build_conn()
       |> Plug.Conn.put_req_header("accept", "application/json")
       |> Plug.Conn.put_req_header("content-type", "application/json")}
  end
end
