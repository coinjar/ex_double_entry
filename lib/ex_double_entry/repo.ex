defmodule ExDoubleEntry.Repo do
  @db Application.fetch_env!(:ex_double_entry, :db)

  @db_adapter (
    case @db do
      :postgres   -> Ecto.Adapters.Postgres
      :postgresql -> Ecto.Adapters.Postgres
      :mysql      -> Ecto.Adapters.MyXQL
      :sqlite     -> Ecto.Adapters.SQLite3
    end
  )

  use Ecto.Repo,
    otp_app: :ex_double_entry,
    adapter: @db_adapter
end
