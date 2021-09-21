defmodule ExDoubleEntry.TransferTest do
  use ExDoubleEntry.DataCase
  alias ExDoubleEntry.{Repo, Account, AccountBalance, Line, Transfer}
  doctest Transfer

  test "perform/1" do
    account_a = :account_balance |> insert(identifier: "savings", balance: 200_00) |> Account.present()
    account_b = :account_balance |> insert(identifier: "checking", balance: 200_00) |> Account.present()

    Transfer.perform!(
      Money.new(123_45, :USD),
      from: account_a,
      to: account_b,
      code: :deposit,
      metadata: %{diamond: "hands"}
    )

    [line1, line2] = Repo.all(Line)

    assert %AccountBalance{
      balance: 76_55,
    } = AccountBalance.for_account(account_a)

    assert %AccountBalance{
      balance: 323_45,
    } = AccountBalance.for_account(account_b)

    assert %Line{
      account_identifier: "savings",
      account_scope: nil,
      currency: :USD,
      amount: -123_45,
      balance: 76_55,
      code: "deposit",
      partner_identifier: "checking",
      partner_scope: nil,
      metadata: %{"diamond" => "hands"},
    } = line1

    assert %Line{
      account_identifier: "checking",
      account_scope: nil,
      currency: :USD,
      amount: 123_45,
      balance: 323_45,
      code: "deposit",
      partner_identifier: "savings",
      partner_scope: nil,
      metadata: %{"diamond" => "hands"},
    } = line2
  end
end
