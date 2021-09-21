defmodule ExDoubleEntry.Transfer do
  @enforce_keys [:money, :from, :to, :code]
  defstruct [:money, :from, :to, :code, :metadata]

  alias ExDoubleEntry.{Account, AccountBalance, Guard, Line, Transfer}

  def perform!(%Transfer{} = transfer) do
    perform!(transfer, ensure_accounts: true)
  end

  def perform!(transfer_attrs) do
    perform!(transfer_attrs, ensure_accounts: true)
  end

  def perform!(%Transfer{} = transfer, ensure_accounts: ensure_accounts) do
    with {:ok, _} <- Guard.positive_amount?(transfer),
         {:ok, _} <- Guard.valid_definition?(transfer),
         {:ok, _} <- Guard.matching_currency?(transfer),
         {:ok, _} <- Guard.positive_balance_if_enforced?(transfer)
    do
      perform(transfer, ensure_accounts: ensure_accounts)
    end
  end

  def perform!(transfer_attrs, ensure_accounts: ensure_accounts) do
    Transfer |> struct(transfer_attrs) |> perform!(ensure_accounts: ensure_accounts)
  end

  def perform(%Transfer{} = transfer) do
    perform(transfer, ensure_accounts: true)
  end

  def perform(
    %Transfer{
      money: money, from: from, to: to, code: code, metadata: metadata
    } = transfer,
    ensure_accounts: ensure_accounts
  ) do
    {from, to} =
      if ensure_accounts == true do
        {
          from |> AccountBalance.for_account!() |> Account.present(),
          to |> AccountBalance.for_account!() |> Account.present(),
        }
      else
        cond do
          is_nil(AccountBalance.for_account(from)) ->
            raise Account.NotFoundError
          is_nil(AccountBalance.for_account(to)) ->
            raise Account.NotFoundError
        end
    end

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
end
