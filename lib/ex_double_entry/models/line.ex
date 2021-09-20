defmodule ExDoubleEntry.Line do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExDoubleEntry.Repo
  alias ExDoubleEntry.AccountBalance

  schema "#{ExDoubleEntry.db_table_prefix}lines" do
    field :account_identifier, :string
    field :account_scope, :string
    field :currency, Money.Currency.Ecto.Type
    field :amount, :integer
    field :balance, :integer
    field :code, :string
    field :partner_identifier, :string
    field :partner_scope, :string
    field :metadata, :map

    belongs_to(:partner_line, __MODULE__)
    belongs_to(:account_balance, AccountBalance)

    timestamps()
  end

  def insert!(money,
    account: account, partner: partner,
    code: code, metadata: metadata
  ) do
    %{
      account_identifier: "#{account.identifier}",
      account_scope: "#{account.scope}",
      currency: "#{money.currency}",
      code: "#{code}",
      amount: money.amount,
      balance: Money.add(account.balance, money).amount,
      partner_identifier: "#{partner.identifier}",
      partner_scope: partner.scope,
      metadata: metadata,
      account_balance_id: account.id,
    }
    |> changeset()
    |> Repo.insert!()
  end

  defp changeset(params) do
    %__MODULE__{}
    |> cast(params, [
        :account_identifier, :account_scope, :currency, :amount, :balance,
        :code, :partner_identifier, :partner_scope, :metadata,
        :account_balance_id, :partner_line_id,
      ])
    |> validate_required([
        :account_identifier, :currency, :amount, :balance,
        :code, :partner_identifier,
      ])
    |> foreign_key_constraint(:partner_line_id)
    |> foreign_key_constraint(:account_balance_id)
  end
end
