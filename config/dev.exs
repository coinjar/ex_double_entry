import Config

config :ex_double_entry, ExDoubleEntry.Repo,
  username: "postgres",
  password: "postgres",
  database: "ex_double_entry_dev",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
