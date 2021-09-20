{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(ExDoubleEntry.Repo, :manual)

require Logger
db = Application.fetch_env!(:ex_double_entry, :db)
Logger.info("Running tests with #{db}...")
