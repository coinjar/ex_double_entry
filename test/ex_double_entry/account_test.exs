defmodule ExDoubleEntry.AccountTest do
  use ExDoubleEntry.DataCase
  alias ExDoubleEntry.Account
  doctest Account

  test "present/1" do
    balance = Money.new(42, :USD)

    account =
      :account_balance
      |> insert(identifier: "savings", currency: "USD", scope: "user/1", balance: 42)
      |> Account.present()

    assert %Account{
      identifier: :savings,
      currency: :USD,
      scope: "user/1",
      positive_only: true,
      balance: ^balance
    } = account
  end
end
