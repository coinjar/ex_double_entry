defmodule ExDoubleEntry.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_double_entry,
      version: "0.1.2",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      name: "ExDoubleEntry",
      description: description(),
      package: package(),
      source_url: "https://github.com/coinjar/ex_double_entry"
    ]
  end

  def application do
    [
      mod: {ExDoubleEntry.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test_money), do: ["lib", "test/support"]
  defp elixirc_paths(:test_ex_money), do: ["lib", "test/support"]
  defp elixirc_paths(:test_mysql_money), do: ["lib", "test/support"]
  defp elixirc_paths(:test_mysql_ex_money), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:money, "~> 1.9", only: [:test_money, :test_mysql_money]},
      {:ex_money, "~> 5.9", only: [:test_ex_money, :test_mysql_ex_money]},
      {:ecto_sql, "~> 3.7"},
      {:postgrex, ">= 0.0.0", optional: true},
      {:myxql, ">= 0.0.0", optional: true},
      {:ex_machina, "~> 2.7",
       only: [:test_money, :test_mysql_money, :test_ex_money, :test_mysql_ex_money]},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev], runtime: false}
    ]
  end

  defp description() do
    "An Elixir double-entry library inspired by Ruby's DoubleEntry. Brought to you by CoinJar."
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/coinjar/ex_double_entry"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
