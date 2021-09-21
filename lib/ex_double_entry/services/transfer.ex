defmodule ExDoubleEntry.Transfer do
  @enforce_keys [:amount, :from, :to, :code]
  defstruct [:amount, :from, :to, :code, :metadata]

  alias ExDoubleEntry.{AccountBalance, Line}

  def perform!(money, from: from, to: to, code: code, metadata: metadata) do
    AccountBalance.lock_multi!([from, to], fn ->
      Line.insert!(Money.neg(money),
        account: from, partner: to, code: code, metadata: metadata
      )

      Line.insert!(money,
        account: to, partner: from, code: code, metadata: metadata
      )

      from_amount = Money.subtract(from.balance, money).amount
      to_amount   = Money.add(to.balance, money).amount

      AccountBalance.update_balance!(from, from_amount)
      AccountBalance.update_balance!(to, to_amount)
    end)
  end
end
