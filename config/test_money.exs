import Config

config :ex_double_entry,
  db: :postgres,
  money: :money

config :ex_double_entry, ExDoubleEntry.Repo,
  username: System.get_env("POSTGRES_DB_USERNAME", "postgres"),
  password: System.get_env("POSTGRES_DB_PASSWORD", "postgres"),
  database: System.get_env("POSTGRES_DB_NAME", "ex_double_entry_test"),
  hostname: System.get_env("POSTGRES_DB_HOST", "localhost"),
  pool: Ecto.Adapters.SQL.Sandbox,
  show_sensitive_data_on_connection_error: true,
  timeout: :infinity,
  queue_target: 200,
  queue_interval: 10

config :logger, level: :info
