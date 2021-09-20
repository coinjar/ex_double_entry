import Config

config :ex_double_entry, ExDoubleEntry.Repo,
  username: "postgres",
  password: "postgres",
  database: "ex_double_entry_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  show_sensitive_data_on_connection_error: true

config :logger, level: :info
