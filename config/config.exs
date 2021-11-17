import Config

config :ex_double_entry,
  ecto_repos: [ExDoubleEntry.Repo],
  db: :postgres,
  db_table_prefix: "ex_double_entry_",
  repo: ExDoubleEntry.Repo,
  default_currency: :USD,
  accounts: %{
    bank: [],
    savings: [positive_only: true],
    checking: []
  },
  transfers: %{
    deposit: [
      {:bank, :savings},
      {:bank, :checking},
      {:checking, :savings}
    ],
    withdraw: [
      {:savings, :checking}
    ],
    stress_test: []
  }

import_config "#{config_env()}.exs"
