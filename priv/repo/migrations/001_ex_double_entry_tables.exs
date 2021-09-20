defmodule ExDoubleEntry.Repo.Migrations.ExDoubleEntryMoney do
  use Ecto.Migration

  def change do
    json_type =
      if ExDoubleEntry.Repo.__adapter__ == Ecto.Adapters.Postgres do
        :jsonb
      else
        :json
      end

    create table(:"#{ExDoubleEntry.db_table_prefix}account_balances") do
      add :identifier, :string
      add :currency, :string
      add :scope, :string
      add :balance, :bigint

      timestamps()
    end

    create index(:"#{ExDoubleEntry.db_table_prefix}account_balances", [:scope, :currency, :identifier], unique: true, name: :scope_currency_identifier_index)

    create table(:"#{ExDoubleEntry.db_table_prefix}lines") do
      add :account_identifier, :string
      add :account_scope, :string
      add :currency, :string
      add :amount, :bigint
      add :balance, :bigint
      add :code, :string
      add :partner_identifier, :string
      add :partner_scope, :string
      add :metadata, json_type
      add :partner_line_id, references(:"#{ExDoubleEntry.db_table_prefix}lines")
      add :account_balance_id, references(:"#{ExDoubleEntry.db_table_prefix}account_balances")

      timestamps()
    end

    create index(:"#{ExDoubleEntry.db_table_prefix}lines", [:account_identifier, :code, :currency, :inserted_at], name: :account_identifier_code_currency_inserted_at_index)
    create index(:"#{ExDoubleEntry.db_table_prefix}lines", [:account_scope, :account_identifier, :currency, :inserted_at], name: :account_scope_account_identifier_currency_inserted_at_index)
  end
end
