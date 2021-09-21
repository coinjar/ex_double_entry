defmodule ExDoubleEntry do
  @db_table_prefix Application.fetch_env!(:ex_double_entry, :db_table_prefix)

  def db_table_prefix, do: @db_table_prefix

  @doc """
  ## Examples

  iex> ExDoubleEntry.account(:savings)
  %ExDoubleEntry.Account{identifier: :savings, currency: :USD, scope: nil, positive_only: true}
  """
  defdelegate account(account, opts \\ []), to: ExDoubleEntry.Account, as: :make!

  @doc """
  ## Examples

  iex> :savings |> ExDoubleEntry.account() |> ExDoubleEntry.account_balance()
  nil
  """
  defdelegate account_balance(account), to: ExDoubleEntry.AccountBalance, as: :for_account

  @doc """
  ## Examples

  iex> [ExDoubleEntry.account(:savings)] |> ExDoubleEntry.lock_accounts(fn -> true end)
  {:ok, true}
  """
  defdelegate lock_accounts(accounts, fun), to: ExDoubleEntry.AccountBalance, as: :lock_multi!
end
