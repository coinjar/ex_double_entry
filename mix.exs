defmodule ExDoubleEntry.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_double_entry,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {ExDoubleEntry.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:test_mysql), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:money, "~> 1.9"},
      {:ecto_sql, "~> 3.7"},
      {:postgrex, ">= 0.0.0", optional: true},
      {:myxql, ">= 0.0.0", optional: true},
      {:ex_machina, "~> 2.7", only: [:test, :test_mysql]}
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
