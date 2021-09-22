defmodule ExDoubleEntry.AccountBalanceTest do
  use ExDoubleEntry.DataCase
  alias ExDoubleEntry.{Account, AccountBalance, Transfer}
  doctest AccountBalance

  test "create!/1 - balance will always be 0" do
    account =
      %Account{
        identifier: :savings,
        scope: "user/1",
        currency: :USD,
        balance: Money.new(42, :USD)
      }

    assert %AccountBalance{balance_amount: 0} = AccountBalance.create!(account)

    assert_raise(Ecto.InvalidChangesetError, fn ->
      AccountBalance.create!(account)
    end)
  end

  describe "for_account/1" do
    setup do
      insert(:account_balance, identifier: :savings, currency: :USD, scope: "user/1", balance_amount: 42)
      insert(:account_balance, identifier: :savings, currency: :USD, balance_amount: 24)
      insert(:account_balance, identifier: :savings, currency: :AUD, balance_amount: 1337)
      insert(:account_balance, identifier: :checking, currency: :AUD, balance_amount: 233)

      :ok
    end

    test "a" do
      ab =
        AccountBalance.for_account(%Account{
          identifier: :savings, currency: :USD, scope: "user/1",
        })

      assert %AccountBalance{
        identifier: :savings, currency: :USD, scope: "user/1", balance_amount: 42,
      } = ab
    end

    test "b" do
      ab =
        AccountBalance.for_account(%Account{
          identifier: :savings, currency: :AUD,
        })

      assert %AccountBalance{
        identifier: :savings, currency: :AUD, scope: nil, balance_amount: 1337,
      } = ab
    end

    test "c" do
      ab =
        AccountBalance.for_account(%Account{
          identifier: :checking, currency: :AUD,
        })

      assert %AccountBalance{
        identifier: :checking, currency: :AUD, scope: nil, balance_amount: 233,
      } = ab
    end
  end

  describe "for_account!/1" do
    test "a" do
      ab =
        AccountBalance.for_account!(%Account{
          identifier: :crypto, currency: :BTC,
        })

      assert %AccountBalance{
        identifier: :crypto, currency: :BTC, scope: nil, balance_amount: 0,
      } = ab
    end

    test "b" do
      ab =
        AccountBalance.for_account!(%Account{
          identifier: :crypto, currency: :BTC, scope: ""
        })

      assert %AccountBalance{
        identifier: :crypto, currency: :BTC, scope: nil, balance_amount: 0,
      } = ab
    end
  end

  describe "lock_multi!/2" do
    setup do
      acc_a = :account_balance |> insert(identifier: :checking) |> Account.present()
      acc_b = :account_balance |> insert(identifier: :savings) |> Account.present()

      [acc_a: acc_a, acc_b: acc_b]
    end

    test "multiple locks", %{acc_a: acc_a, acc_b: acc_b} do
      tasks =
        for i <- 0..4 do
          Task.async(fn ->
            AccountBalance.lock_multi!([acc_a, acc_b], fn -> i end)
          end)
        end
        |> Task.await_many()

      assert Enum.reduce(tasks, 0, fn {:ok, n}, acc -> acc + n end) == 10
    end

    test "failed locks", %{acc_a: acc_a, acc_b: acc_b} do
      [
        Task.async(fn ->
          AccountBalance.lock_multi!([acc_a, acc_b], fn -> :timer.sleep(250) end)
        end),
        Task.async(fn ->
          assert_raise(DBConnection.ConnectionError, fn ->
            AccountBalance.lock_multi!([acc_a, acc_b], fn ->
              Transfer.perform(
                %Transfer{
                  money: Money.new(42, :USD),
                  from: acc_a, to: acc_b,
                  code: :deposit, metadata: nil,
                }
              )
            end)
          end)
        end),
      ]
      |> Task.await_many()
    end
  end
end
