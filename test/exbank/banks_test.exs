defmodule Exbank.BanksTest do
  @moduledoc false

  use Exbank.DataCase, async: true

  alias Exbank.Banks

  describe "fetch_bank_by_name" do
    setup do
      active_bank = insert(:bank)
      inactive_bank = insert(:inactive_bank)

      %{active_bank: active_bank, inactive_bank: inactive_bank}
    end

    test "should return an active bank with when given the correct name", %{active_bank: bank} do
      assert {:ok, retrieved_bank} = Banks.fetch_bank_by_name(bank.name)

      assert retrieved_bank.name == bank.name
      assert retrieved_bank.active == true
    end

    test "should return an error tuple if the bank is not active", %{inactive_bank: bank} do
      assert {:error, :BANK_NOT_FOUND} = Banks.fetch_bank_by_name(bank.name)
    end
  end
end
