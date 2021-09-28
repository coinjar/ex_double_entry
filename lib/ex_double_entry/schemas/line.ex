defmodule ExDoubleEntry.Line do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExDoubleEntry.{Repo, AccountBalance, Line}

  schema "#{ExDoubleEntry.db_table_prefix()}lines" do
    field(:account_identifier, ExDoubleEntry.EctoType.Identifier)
    field(:account_scope, ExDoubleEntry.EctoType.Scope)
    field(:currency, ExDoubleEntry.EctoType.Currency)
    field(:amount, :integer)
    field(:balance_amount, :integer)
    field(:code, ExDoubleEntry.EctoType.Identifier)
    field(:partner_identifier, ExDoubleEntry.EctoType.Identifier)
    field(:partner_scope, ExDoubleEntry.EctoType.Scope)
    field(:metadata, :map)

    belongs_to(:partner_line, Line)
    belongs_to(:account_balance, AccountBalance)

    timestamps()
  end

  defp changeset(params) do
    %Line{}
    |> cast(params, [
      :account_identifier,
      :account_scope,
      :currency,
      :amount,
      :balance_amount,
      :code,
      :partner_identifier,
      :partner_scope,
      :metadata,
      :account_balance_id,
      :partner_line_id
    ])
    |> validate_required([
      :account_identifier,
      :currency,
      :amount,
      :balance_amount,
      :code,
      :partner_identifier
    ])
    |> foreign_key_constraint(:partner_line_id)
    |> foreign_key_constraint(:account_balance_id)
  end

  def insert!(money, account: account, partner: partner, code: code, metadata: metadata) do
    %{
      account_identifier: account.identifier,
      account_scope: account.scope,
      currency: money.currency,
      code: code,
      amount: money.amount,
      balance_amount: Money.add(account.balance, money).amount,
      partner_identifier: partner.identifier,
      partner_scope: partner.scope,
      metadata: metadata,
      account_balance_id: account.id
    }
    |> changeset()
    |> Repo.insert!()
  end

  def update_partner_line_id!(%Line{} = line, partner_line_id) do
    line
    |> Ecto.Changeset.change(partner_line_id: partner_line_id)
    |> ExDoubleEntry.Repo.update!()
  end
end
