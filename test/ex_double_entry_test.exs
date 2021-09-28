defmodule ExDoubleEntryTest do
  use ExDoubleEntry.DataCase
  alias ExDoubleEntry.{Account, Line}
  doctest ExDoubleEntry

  describe "lock accounts and transfer" do
    setup do
      acc_a = :account_balance |> insert(identifier: :checking) |> Account.present()
      acc_b = :account_balance |> insert(identifier: :savings) |> Account.present()

      [acc_a: acc_a, acc_b: acc_b]
    end

    test "successful", %{acc_a: acc_a, acc_b: acc_b} do
      result =
        ExDoubleEntry.lock_accounts([acc_a, acc_b], fn ->
          ExDoubleEntry.transfer!(
            money: Money.new(100, :USD),
            from: acc_a,
            to: acc_b,
            code: :deposit
          )

          :diamond_hands
        end)

      assert result == {:ok, :diamond_hands}
      assert Line |> Repo.all() |> Enum.count() == 2
    end

    test "failure", %{acc_a: acc_a, acc_b: acc_b} do
      assert_raise(RuntimeError, fn ->
        ExDoubleEntry.lock_accounts([acc_a, acc_b], fn ->
          ExDoubleEntry.transfer!(
            money: Money.new(100, :USD),
            from: acc_a,
            to: acc_b,
            code: :deposit
          )

          raise "error"
        end)
      end)

      assert Line |> Repo.all() |> Enum.count() == 0
    end
  end

  describe "no persisted accounts" do
    setup do
      acc_a = %Account{identifier: :checking, currency: :USD}
      acc_b = %Account{identifier: :savings, currency: :USD}

      [acc_a: acc_a, acc_b: acc_b]
    end

    test "transfer!/1", %{acc_a: acc_a, acc_b: acc_b} do
      result =
        ExDoubleEntry.lock_accounts([acc_a, acc_b], fn ->
          ExDoubleEntry.transfer!(
            money: Money.new(100, :USD),
            from: acc_a,
            to: acc_b,
            code: :deposit
          )

          :diamond_hands
        end)

      assert result == {:ok, :diamond_hands}
      assert Line |> Repo.all() |> Enum.count() == 2
    end

    test "transfer/1", %{acc_a: acc_a, acc_b: acc_b} do
      assert_raise(Account.NotFoundError, fn ->
        ExDoubleEntry.lock_accounts([acc_a, acc_b], fn ->
          ExDoubleEntry.transfer(
            money: Money.new(100, :USD),
            from: acc_a,
            to: acc_b,
            code: :deposit
          )

          :diamond_hands
        end)
      end)

      assert Line |> Repo.all() |> Enum.count() == 0
    end
  end
end
