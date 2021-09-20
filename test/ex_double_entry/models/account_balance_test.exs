defmodule ExDoubleEntry.AccountBalanceTest do
  use ExDoubleEntry.DataCase, async: true
  alias ExDoubleEntry.{Account, AccountBalance}
  doctest AccountBalance

  setup do
    insert(:account_balance, identifier: "savings", currency: "USD", scope: "user/1", balance: 42)
    insert(:account_balance, identifier: "savings", currency: "USD", balance: 24)
    insert(:account_balance, identifier: "savings", currency: "AUD", balance: 1337)
    insert(:account_balance, identifier: "checking", currency: "AUD", balance: 233)

    :ok
  end

  describe "for_account/1" do
    test "a" do
      ab =
        AccountBalance.for_account(%Account{
          identifier: :savings, currency: :USD, scope: "user/1",
        })

      assert %AccountBalance{
        identifier: "savings", currency: :USD, scope: "user/1", balance: 42,
      } = ab
    end

    test "b" do
      ab =
        AccountBalance.for_account(%Account{
          identifier: :savings, currency: :AUD,
        })

      assert %AccountBalance{
        identifier: "savings", currency: :AUD, scope: nil, balance: 1337,
      } = ab
    end

    test "c" do
      ab =
        AccountBalance.for_account(%Account{
          identifier: :checking, currency: :AUD,
        })

      assert %AccountBalance{
        identifier: "checking", currency: :AUD, scope: nil, balance: 233,
      } = ab
    end
  end
end
