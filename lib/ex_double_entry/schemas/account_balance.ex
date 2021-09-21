defmodule ExDoubleEntry.AccountBalance do
  use Ecto.Schema
  import Ecto.Query

  alias ExDoubleEntry.{Repo, Account, AccountBalance}

  schema "#{ExDoubleEntry.db_table_prefix}account_balances" do
    field :identifier, ExDoubleEntry.EctoType.Identifier
    field :currency, ExDoubleEntry.EctoType.Currency
    field :scope, :string
    field :balance_amount, :integer

    timestamps()
  end

  def create!(
    %Account{
      identifier: identifier, scope: scope, currency: currency
    }
  ) do
    %AccountBalance{
      identifier: identifier,
      scope: scope,
      currency: currency,
      balance_amount: 0,
    }
    |> ExDoubleEntry.Repo.insert!()
  end

  def for_account(%Account{} = account) do
    for_account(account, lock: false)
  end

  def for_account(%Account{} = account, lock: lock) do
    identifier = account.identifier
    currency   = account.currency

    ab =
      from(
        ab in AccountBalance,
        where: ab.identifier == ^identifier,
        where: ab.currency == ^currency
      )
      |> scope_cond(account.scope)
      |> lock_cond(lock)
      |> Repo.one()

    ab || create!(account)
  end

  defp scope_cond(query, scope) do
    case scope do
      nil -> where(query, [ab], is_nil(ab.scope))
      _   -> where(query, [ab], ab.scope == ^scope)
    end
  end

  defp lock_cond(query, lock) do
    case lock do
      true  -> lock(query, "FOR SHARE NOWAIT")
      false -> query
    end
  end

  def lock!(%Account{} = account) do
    for_account(account, lock: true)
  end

  def lock_multi!(accounts, fun) do
    Repo.transaction(fn ->
      accounts |> Enum.sort() |> Enum.map(fn account -> lock!(account) end)
      fun.()
    end)
  end

  def update_balance!(%Account{} = account, balance_amount) do
    account
    |> lock!()
    |> Ecto.Changeset.change(balance_amount: balance_amount)
    |> Repo.update!()
  end
end
