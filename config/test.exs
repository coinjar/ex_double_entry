import Config

config :ex_double_entry, ExDoubleEntry.Repo,
  username: "postgres",
  password: "postgres",
  database: System.get_env("POSTGRES_DB", "ex_double_entry_test"),
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  pool: Ecto.Adapters.SQL.Sandbox,
  show_sensitive_data_on_connection_error: true

config :logger, level: :info
