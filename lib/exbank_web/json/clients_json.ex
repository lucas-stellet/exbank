defmodule ExbankWeb.ClientsJSON do
  @moduledoc false

  def new(%{client_id: client_id}) do
    %{
      data: %{
        client_id: client_id
      }
    }
  end

  def list(%{clients: clients}) do
    %{
      data: for(client <- clients, do: data(client))
    }
  end

  def data(%{client_id: client_id, bank_name: bank_name}) do
    %{
      client_id: client_id,
      bank_name: bank_name
    }
  end
end
