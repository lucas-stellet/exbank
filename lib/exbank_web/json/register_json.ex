defmodule ExbankWeb.RegisterJSON do
  @doc """
  Renders a list of users.
  """
  def new(%{token: token}) do
    %{
      data: %{
        token: token
      }
    }
  end
end
