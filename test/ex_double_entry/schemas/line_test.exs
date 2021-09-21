defmodule ExDoubleEntry.LineTest do
  use ExDoubleEntry.DataCase
  alias ExDoubleEntry.{Account, Line}
  doctest Line

  test "insert/2" do
    acc_a = :account_balance |> insert(identifier: :checking) |> Account.present()
    acc_b = :account_balance |> insert(identifier: :savings) |> Account.present()

    acc_a_id = acc_a.id

    line =
      Line.insert!(
        Money.new(100, :USD),
        account: acc_a, partner: acc_b,
        code: :deposit, metadata: %{diamond: "hands"}
      )

    assert %Line{
      account_identifier: :checking,
      currency: :USD,
      code: :deposit,
      amount: 100,
      balance_amount: 100,
      partner_identifier: :savings,
      metadata: %{diamond: "hands"},
      account_balance_id: ^acc_a_id,
    } = line
  end
end
