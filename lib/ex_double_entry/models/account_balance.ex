defmodule ExDoubleEntry.AccountBalance do
  use Ecto.Schema
  import Ecto.Query

  alias ExDoubleEntry.{Repo, Account, AccountBalance}

  schema "#{ExDoubleEntry.db_table_prefix}account_balances" do
    field :identifier, :string
    field :currency, Money.Currency.Ecto.Type
    field :scope, :string
    field :balance, :integer

    timestamps()
  end

  def for_account(%Account{} = account) do
    for_account(account, lock: false)
  end

  def for_account(%Account{} = account, lock: lock) do
    identifier = "#{account.identifier}"
    currency   = "#{account.currency}"

    from(
      ab in AccountBalance,
      where: ab.identifier == ^identifier,
      where: ab.currency == ^currency
    )
    |> scope_cond(account.scope)
    |> lock_cond(lock)
    |> Repo.one()
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

  def update_balance!(%Account{} = account, balance) do
    account
    |> lock!()
    |> Ecto.Changeset.change(balance: balance)
    |> Repo.update!()
  end
end
