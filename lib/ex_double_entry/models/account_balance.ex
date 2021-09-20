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
    identifier = "#{account.identifier}"
    currency   = "#{account.currency}"

    from(
      ab in AccountBalance,
      where: ab.identifier == ^identifier,
      where: ab.currency == ^currency
    )
    |> scope_cond(account.scope)
    |> Repo.one()
  end

  defp scope_cond(query, scope) do
    case scope do
      nil -> where(query, [ab], is_nil(ab.scope))
      _   -> where(query, [ab], ab.scope == ^scope)
    end
  end
end
