# ExDoubleEntry

[![Build Status](https://github.com/coinjar/ex_double_entry/actions/workflows/ci.yml/badge.svg)](https://github.com/coinjar/ex_double_entry/actions)

An Elixir double-entry library inspired by Ruby's [DoubleEntry](https://github.com/envato/double_entry). Brought to you by [CoinJar](https://coinjar.com).

![](https://i.imgur.com/QqrlYZ9.png)

## Supported Databases

- Postgres 8.1+
- MySQL 8.0+

## Installation

```elixir
def deps do
  [
    {:ex_double_entry, github: "coinjar/ex_double_entry"},
    # pick one DB package
    {:postgrex, ">= 0.0.0"},
    {:myxql, ">= 0.0.0"},
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
# creates a new account with 0 balance
account = ExDoubleEntry.make_account(:savings, scope: "user/1")

# looks up an account with its balance
account = ExDoubleEntry.account_lookup(:savings, scope: "user/1")
```

### Transfers

```elixir
ExDoubleEntry.transfer(
  money: Money.new(100, :USD),
  from: account_a,
  to: account_b,
  code: :deposit
)
```

### Locking

```elixir
ExDoubleEntry.lock_accounts([account_a, account_b], fn ->
  ExDoubleEntry.transfer(
    money: Money.new(100, :USD),
    from: account_a,
    to: account_b,
    code: :deposit
  )

  # perform other tasks that should be committed atomically with the transfer
end)
```
