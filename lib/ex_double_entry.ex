defmodule ExDoubleEntry do
  @db_table_prefix Application.fetch_env!(:ex_double_entry, :db_table_prefix)

  def db_table_prefix, do: @db_table_prefix

  @doc """
  ## Examples

  iex> ExDoubleEntry.account(:savings)
  %ExDoubleEntry.Account{identifier: :savings, currency: :USD, scope: nil, positive_only?: true}
  """
  defdelegate account(account, opts \\ []),
    to: ExDoubleEntry.Account, as: :make!

  @doc """
  ## Examples

  iex> (:savings |> ExDoubleEntry.account() |> ExDoubleEntry.account_balance()).__struct__
  ExDoubleEntry.AccountBalance
  """
  defdelegate account_balance(account),
    to: ExDoubleEntry.AccountBalance, as: :for_account

  @doc """
  ## Examples

  iex> [ExDoubleEntry.account(:savings)] |> ExDoubleEntry.lock_accounts(fn -> true end)
  {:ok, true}
  """
  defdelegate lock_accounts(accounts, fun),
    to: ExDoubleEntry.AccountBalance, as: :lock_multi!

  @doc """
  ## Examples

  iex> %ExDoubleEntry.Transfer{
  iex>   money: Money.new(42, :USD),
  iex>   from: %ExDoubleEntry.Account{identifier: :checking, currency: :USD, balance: Money.new(42, :USD), positive_only?: false},
  iex>   to: %ExDoubleEntry.Account{identifier: :savings, currency: :USD, balance: Money.new(0, :USD)},
  iex>   code: :deposit
  iex> }
  iex> |> ExDoubleEntry.transfer()
  iex> |> Tuple.to_list()
  iex> |> List.first()
  :ok
  """
  defdelegate transfer(transfer),
    to: ExDoubleEntry.Transfer, as: :perform!
end
