defmodule ExDoubleEntry.LineTest do
  use ExDoubleEntry.DataCase, async: true
  alias ExDoubleEntry.{Account, Line}
  doctest Line

  setup do
    account_a = :account_balance |> insert(identifier: "savings") |> Account.present()
    account_b = :account_balance |> insert(identifier: "checking") |> Account.present()

    [account_a: account_a, account_b: account_b]
  end

  describe "insert/2" do
    test "savings", %{account_a: account_a, account_b: account_b} do
      account_a_id = account_a.id

      line =
        Line.insert!(
          Money.new(100, :USD),
          account: account_a, partner: account_b,
          code: :deposit, metadata: %{diamond: "hands"}
        )

      assert %Line{
        account_identifier: "savings",
        currency: :USD,
        code: "deposit",
        amount: 100,
        balance: 100,
        partner_identifier: "checking",
        metadata: %{diamond: "hands"},
        account_balance_id: ^account_a_id,
      } = line
    end
  end
end
