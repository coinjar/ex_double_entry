defmodule ExDoubleEntry.AccountBalance do
  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias ExDoubleEntry.{Account, AccountBalance}

  schema "#{ExDoubleEntry.db_table_prefix()}account_balances" do
    field(:identifier, ExDoubleEntry.EctoType.Identifier)
    field(:currency, ExDoubleEntry.EctoType.Currency)
    field(:scope, ExDoubleEntry.EctoType.Scope)
    field(:balance_amount, :integer)

    timestamps(type: :utc_datetime_usec)
  end

  defp changeset(params) do
    %AccountBalance{}
    |> cast(params, [:identifier, :currency, :scope, :balance_amount])
    |> validate_required([:identifier, :currency, :balance_amount])
    |> unique_constraint(:identifier, name: :scope_currency_identifier_index)
  end

  def find(%Account{} = account) do
    for_account(account, lock: false)
  end

  def create!(%Account{identifier: identifier, currency: currency, scope: scope}) do
    %{
      identifier: identifier,
      currency: currency,
      scope: scope,
      balance_amount: 0
    }
    |> changeset()
    |> ExDoubleEntry.repo().insert!()
  end

  def for_account!(%Account{} = account) do
    for_account!(account, lock: false)
  end

  def for_account!(%Account{} = account, lock: lock) do
    for_account(account, lock: lock) || create!(account)
  end

  def for_account(nil), do: nil

  def for_account(%Account{} = account) do
    for_account(account, lock: false)
  end

  def for_account(
        %Account{identifier: identifier, currency: currency, scope: scope},
        lock: lock
      ) do
    from(
      ab in AccountBalance,
      where: ab.identifier == ^identifier,
      where: ab.currency == ^currency
    )
    |> scope_cond(scope)
    |> lock_cond(lock)
    |> ExDoubleEntry.repo().one()
  end

  defp scope_cond(query, scope) do
    case scope do
      nil -> where(query, [ab], ab.scope == "")
      _ -> where(query, [ab], ab.scope == ^scope)
    end
  end

  defp lock_cond(query, lock) do
    case lock do
      true -> lock(query, "FOR SHARE NOWAIT")
      false -> query
    end
  end

  def lock!(%Account{} = account) do
    for_account(account, lock: true)
  end

  def lock_multi!(accounts, fun) do
    ExDoubleEntry.repo().transaction(fn ->
      accounts |> Enum.sort() |> Enum.map(fn account -> lock!(account) end)
      fun.()
    end)
  end

  def update_balance!(%Account{} = account, balance_amount) do
    account
    |> lock!()
    |> Ecto.Changeset.change(balance_amount: balance_amount)
    |> ExDoubleEntry.repo().update!()
  end
end
