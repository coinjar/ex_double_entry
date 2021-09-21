defmodule ExDoubleEntry.TransferTest do
  use ExDoubleEntry.DataCase
  alias ExDoubleEntry.{Repo, Account, AccountBalance, Line, Transfer}
  doctest Transfer

  setup do
    acc_a = :account_balance |> insert(identifier: :checking, balance_amount: 200_00) |> Account.present()
    acc_b = :account_balance |> insert(identifier: :savings, balance_amount: 200_00) |> Account.present()

    [acc_a: acc_a, acc_b: acc_b]
  end

  describe "perform!/1" do
    test "successful", %{acc_a: acc_a, acc_b: acc_b} do
      transfer =
        Transfer.perform!(
          %Transfer{
            money: Money.new(123_45, :USD),
            from: acc_a,
            to: acc_b,
            code: :deposit,
          }
        )

      assert {:ok, %Transfer{}} = transfer
      assert Line |> Repo.all() |> Enum.count == 2
    end

    test "failure", %{acc_a: acc_a, acc_b: acc_b} do
      transfer =
        Transfer.perform!(
          %Transfer{
            money: Money.new(123_45, :USD),
            from: acc_a,
            to: acc_b,
            code: :give_away,
          }
        )

      assert {:error, :undefined_transfer_code, "Transfer code :give_away is undefined."} = transfer
      assert Line |> Repo.all() |> Enum.count == 0
    end
  end

  test "perform/1", %{acc_a: acc_a, acc_b: acc_b} do
    Transfer.perform(
      %Transfer{
        money: Money.new(123_45, :USD),
        from: acc_a,
        to: acc_b,
        code: :deposit,
        metadata: %{diamond: "hands"},
      }
    )

    [line1, line2] = Repo.all(Line)

    assert %AccountBalance{
      balance_amount: 76_55,
    } = AccountBalance.for_account(acc_a)

    assert %AccountBalance{
      balance_amount: 323_45,
    } = AccountBalance.for_account(acc_b)

    assert %Line{
      account_identifier: :checking,
      account_scope: nil,
      currency: :USD,
      amount: -123_45,
      balance_amount: 76_55,
      code: :deposit,
      partner_identifier: :savings,
      partner_scope: nil,
      metadata: %{"diamond" => "hands"},
    } = line1

    assert %Line{
      account_identifier: :savings,
      account_scope: nil,
      currency: :USD,
      amount: 123_45,
      balance_amount: 323_45,
      code: :deposit,
      partner_identifier: :checking,
      partner_scope: nil,
      metadata: %{"diamond" => "hands"},
    } = line2
  end
end
