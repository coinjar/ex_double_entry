defmodule ExDoubleEntry.Transfer do
  @enforce_keys [:money, :from, :to, :code]
  defstruct [:money, :from, :to, :code, :metadata]

  alias ExDoubleEntry.{AccountBalance, Guard, Line, Transfer}

  def perform!(%Transfer{} = transfer) do
    with {:ok, _} <- Guard.positive_amount?(transfer),
         {:ok, _} <- Guard.valid_definition?(transfer),
         {:ok, _} <- Guard.matching_currency?(transfer),
         {:ok, _} <- Guard.positive_balance_if_enforced?(transfer)
    do
      perform(transfer)
    end
  end

  def perform!(transfer_attrs) do
    Transfer |> struct(transfer_attrs) |> perform!()
  end

  def perform(%Transfer{money: money, from: from, to: to, code: code, metadata: metadata} = transfer) do
    AccountBalance.lock_multi!([from, to], fn ->
      Line.insert!(Money.neg(money),
        account: from,
        partner: to,
        code: code,
        metadata: metadata
      )

      Line.insert!(money,
        account: to,
        partner: from,
        code: code,
        metadata: metadata
      )

      from_amount = Money.subtract(from.balance, money).amount
      to_amount   = Money.add(to.balance, money).amount

      AccountBalance.update_balance!(from, from_amount)
      AccountBalance.update_balance!(to, to_amount)

      transfer
    end)
  end

  def perform(transfer_attrs) do
    Transfer |> struct(transfer_attrs) |> perform()
  end
end
