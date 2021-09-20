defmodule ExDoubleEntry.AccountBalanceTest do
  use ExDoubleEntry.DataCase
  alias ExDoubleEntry.{Account, AccountBalance}
  doctest AccountBalance

  setup do
    insert(:account_balance, account: "savings", currency: "USD", scope: "user/1", balance: 42)
    insert(:account_balance, account: "savings", currency: "USD", balance: 24)
    insert(:account_balance, account: "savings", currency: "AUD", balance: 1337)
    insert(:account_balance, account: "checking", currency: "AUD", balance: 233)
    :ok
  end

  test "for_account/1" do
    assert %AccountBalance{
      account: "savings", currency: :USD, scope: "user/1", balance: 42,
    } = AccountBalance.for_account(%Account{
      identifier: :savings, currency: :USD, scope: "user/1",
    })

    assert %AccountBalance{
      account: "savings", currency: :AUD, scope: nil, balance: 1337,
    } = AccountBalance.for_account(%Account{
      identifier: :savings, currency: :AUD,
    })

    assert %AccountBalance{
      account: "checking", currency: :AUD, scope: nil, balance: 233,
    } = AccountBalance.for_account(%Account{
      identifier: :checking, currency: :AUD,
    })
  end
end
