import Config

config :ex_double_entry,
  db: :mysql,
  money: :ex_money

config :ex_double_entry, ExDoubleEntry.Repo,
  username: System.get_env("MYSQL_DB_USERNAME", "root"),
  password: System.get_env("MYSQL_DB_PASSWORD", ""),
  database: System.get_env("MYSQL_DB_NAME", "ex_double_entry_test"),
  hostname: System.get_env("MYSQL_DB_HOST", "localhost"),
  pool: Ecto.Adapters.SQL.Sandbox,
  show_sensitive_data_on_connection_error: true,
  timeout: :infinity,
  queue_target: 200,
  queue_interval: 10

config :logger, level: :info
