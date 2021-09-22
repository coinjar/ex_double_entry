# ExDoubleEntry

[![Build Status](https://github.com/coinjar/ex_double_entry/actions/workflows/ci.yml/badge.svg)](https://github.com/coinjar/ex_double_entry/actions)

An Elixir double-entry library inspired by Ruby's [DoubleEntry](https://github.com/envato/double_entry). Brought to you by [CoinJar](https://coinjar.com).

![](https://i.imgur.com/QqrlYZ9.png)

## Supported Databases

- Postgres 9.4+ (for `JSONB` support)
- MySQL 8.0+ (for row locking support)

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

### DB Migration

You will need to copy and run the [migration file](priv/repo/migrations/001_ex_double_entry_tables.exs) to create the DB tables.

## Configuration

```elixir
config :ex_double_entry,
  db: :postgres,
  db_table_prefix: "ex_double_entry_",
  default_currency: :USD,
  # all accounts need to be defined here
  accounts: %{
    # account identifier: account options
    #
    # valid options are:
    #   "positive_only": whether the account can go into negative balance
    bank: [],
    savings: [positive_only: true],
    checking: [],
  },
  # all transfers need to be defined here
  transfers: %{
    # transfer code: transfer pairs
    #
    # for each transfer pair:
    #   - the first element is the source account
    #   - the second element is the destination account
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
ExDoubleEntry.make_account!(
  # identifier of the account, in atom
  :savings,
  # currency can be any arbitrary atom
  currency: :USD,
  # optional, scope can be any arbitrary string
  #
  # due to DB index on `NULL` values, scope value `nil` and `""` (empty string)
  # are treated as the same
  scope: "user/1"
)

# looks up an account with its balance
ExDoubleEntry.lookup_account!(
  :savings,
  currency: :USD,
  scope: "user/1"
)
```

Both functions return an `ExDoubleEntry.Account` struct that looks like this:

```elixir
%ExDoubleEntry.Account{
  id: 1,
  identifier: :savings,
  currency: :USD,
  scope: "user/1",
  positive_only?: true,
  balance: Money.new(0, :USD),
}
```

### Transfers

There are two transfer modes, `transfer` and `transfer!`.

Note: ExDoubleEntry relies on the [money](https://github.com/elixirmoney/money)
library for balances and amounts.

```elixir
# accounts need to exist in the DB otherwise
# `ExDoubleEntry.Account.NotFoundError` is raised
ExDoubleEntry.transfer(
  money: Money.new(100_00, :USD),
  # accounts need to be defined in the config
  from: account_a,
  to: account_b,
  # transfer code is required, and must be defined in the config
  code: :deposit,
  # optional, metadata can be any arbitrary map, it gets stored in the DB
  # as either a JSON string (MySQL) or a JSONB object (Postgres)
  metadata: %{diamond: "hands"}
)

# accounts will be created in the DB if they don't exist
# once accounts are created they will be locked during the transfer
ExDoubleEntry.transfer!(
  money: Money.new(100_00, :USD),
  from: account_a,
  to: account_b,
  code: :deposit
)
```

### Locking

Transfer itself will already lock the accounts involved. However, if there are
other tasks that need to be performed atomically with the transfer, you can
perform them using `lock_accounts`.

Transactions can be nested arbitrarily, since in Ecto, transactions are
flattened and are committed or rolled back based on the outer most transaction.

Read more on Ecto's transaction handling [here](https://hexdocs.pm/ecto/Ecto.Repo.html#c:transaction/2).

```elixir
ExDoubleEntry.lock_accounts([account_a, account_b], fn ->
  ExDoubleEntry.transfer!(
    money: Money.new(100, :USD),
    from: account_a,
    to: account_b,
    code: :deposit
  )

  # perform other tasks that should be committed atomically with the transfer
end)
```

## License

Licensed under [MIT](LICENSE.md).
