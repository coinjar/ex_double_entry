# ExDoubleEntry

![Build Status](https://github.com/coinjar/ex_double_entry/actions/workflows/CI/badge.svg)

An Elixir double-entry library inspired by Ruby's [DoubleEntry](https://github.com/envato/double_entry). Brought to you by [CoinJar](https://coinjar.com).

![](https://i.imgur.com/QqrlYZ9.png)

## Installation

```elixir
def deps do
  [
    {:ex_double_entry, github: "coinjar/ex_double_entry"},
    # pick one DB package
    {:postgrex, ">= 0.0.0"},
    {:myxql, ">= 0.0.0"},
    {:ecto_sqlite3, ">= 0.0.0"},
  ]
end
```

## Configuration

```elixir
config :ex_double_entry,
  db: :postgres,
  db_table_prefix: "ex_double_entry_",
  default_currency: :USD,
  accounts: %{
    bank: [],
    savings: [positive_only: true],
    checking: [],
  },
  transfers: %{
    deposit: [
      {:bank, :savings},
      {:bank, :checking},
      {:checking, :savings},
    ],
    withdraw: [
      {:savings, :checking},
    ],
  }
```

## Usage

### Accounts & Balances

```elixir
:savings
|> ExDoubleEntry.account(scope: "user/1")
|> ExDoubleEntry.account_balance()
```

### Transfers

```elixir
ExDoubleEntry.transfer(
  Money.new(100, :USD),
  from: :savings,
  to: :checking,
  code: :deposit
)
```

### Locking

```elixir
ExDoubleEntry.lock_accounts(:savings, :checking, fn ->
  ExDoubleEntry.transfer(
    Money.new(100, :USD),
    from: :savings,
    to: :checking,
    code: :deposit
  )

  # perform other tasks that should be committed atomically with the transfer
end)
```
