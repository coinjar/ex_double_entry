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
      add :account, :string
      add :currency, :string
      add :scope, :string
      add :balance, :bigint

      timestamps()
    end

    create index(:"#{ExDoubleEntry.db_table_prefix}account_balances", [:scope, :currency, :account], unique: true)

    create table(:"#{ExDoubleEntry.db_table_prefix}lines") do
      add :account, :string
      add :currency, :string
      add :scope, :string
      add :code, :string
      add :amount, :bigint
      add :balance, :bigint
      add :partner_id, references(:"#{ExDoubleEntry.db_table_prefix}lines")
      add :partner_account, :string
      add :partner_scope, :string
      add :metadata, json_type
      add :account_balance_id, references(:"#{ExDoubleEntry.db_table_prefix}account_balances")

      timestamps()
    end

    create index(:"#{ExDoubleEntry.db_table_prefix}lines", [:account, :code, :currency, :inserted_at])
    create index(:"#{ExDoubleEntry.db_table_prefix}lines", [:scope, :account, :currency, :inserted_at])
  end
end
