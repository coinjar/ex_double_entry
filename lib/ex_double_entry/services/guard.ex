defmodule ExDoubleEntry.Guard do
  alias ExDoubleEntry.{MoneyProxy, Transfer}

  @doc """
  ## Examples

  iex> %Transfer{money: MoneyProxy.new(42, :USD), from: nil, to: nil, code: nil}
  iex> |> Guard.positive_amount?()
  {:ok, %Transfer{money: MoneyProxy.new(42, :USD), from: nil, to: nil, code: nil}}

  iex> %Transfer{money: MoneyProxy.new(-42, :USD), from: nil, to: nil, code: nil}
  iex> |> Guard.positive_amount?()
  {:error, :positive_amount_only, ""}
  """
  def positive_amount?(%Transfer{money: money} = transfer) do
    case MoneyProxy.positive?(money) do
      true -> {:ok, transfer}
      false -> {:error, :positive_amount_only, ""}
    end
  end

  @doc """
  ## Examples

  iex> %Transfer{
  iex>   money: nil,
  iex>   from: %Account{identifier: :checking, currency: :USD},
  iex>   to: %Account{identifier: :savings, currency: :USD},
  iex>   code: :deposit
  iex> }
  iex> |> Guard.valid_definition?()
  {
    :ok,
    %Transfer{
      money: nil,
      code: :deposit,
      from: %Account{identifier: :checking, currency: :USD},
      to: %Account{identifier: :savings, currency: :USD},
    }
  }

  iex> %Transfer{
  iex>   money: nil,
  iex>   from: %Account{identifier: :checking, currency: :USD},
  iex>   to: %Account{identifier: :savings, currency: :USD},
  iex>   code: :give_away
  iex> }
  iex> |> Guard.valid_definition?()
  {:error, :undefined_transfer_code, "Transfer code :give_away is undefined."}

  iex> %Transfer{
  iex>   money: nil,
  iex>   from: %Account{identifier: :checking, currency: :USD},
  iex>   to: %Account{identifier: :savings, currency: :USD},
  iex>   code: :withdraw
  iex> }
  iex> |> Guard.valid_definition?()
  {:error, :undefined_transfer_pair, "Transfer pair :checking -> :savings does not exist for code withdraw."}
  """
  def valid_definition?(%Transfer{from: from, to: to, code: code} = transfer) do
    with {:ok, pairs} <-
           :ex_double_entry
           |> Application.fetch_env!(:transfers)
           |> Map.fetch(code),
         true <- Enum.member?(pairs, {from.identifier, to.identifier}) do
      {:ok, transfer}
    else
      :error ->
        {:error, :undefined_transfer_code, "Transfer code :#{code} is undefined."}

      false ->
        {:error, :undefined_transfer_pair,
         "Transfer pair :#{from.identifier} -> :#{to.identifier} does not exist for code #{code}."}
    end
  end

  @doc """
  ## Examples

  iex> %Transfer{
  iex>   money: MoneyProxy.new(42, :USD),
  iex>   from: %Account{identifier: :checking, currency: :USD},
  iex>   to: %Account{identifier: :savings, currency: :USD},
  iex>   code: :deposit
  iex> }
  iex> |> Guard.matching_currency?()
  {
    :ok,
    %Transfer{
      money: MoneyProxy.new(42, :USD),
      code: :deposit,
      from: %Account{identifier: :checking, currency: :USD},
      to: %Account{identifier: :savings, currency: :USD},
    }
  }

  iex> %Transfer{
  iex>   money: MoneyProxy.new(42, :AUD),
  iex>   from: %Account{identifier: :checking, currency: :USD},
  iex>   to: %Account{identifier: :savings, currency: :USD},
  iex>   code: :deposit
  iex> }
  iex> |> Guard.matching_currency?()
  {:error, :mismatched_currencies, "Attempted to transfer :AUD from :checking in :USD to :savings in :USD."}

  iex> %Transfer{
  iex>   money: MoneyProxy.new(42, :USD),
  iex>   from: %Account{identifier: :checking, currency: :USD},
  iex>   to: %Account{identifier: :savings, currency: :AUD},
  iex>   code: :deposit
  iex> }
  iex> |> Guard.matching_currency?()
  {:error, :mismatched_currencies, "Attempted to transfer :USD from :checking in :USD to :savings in :AUD."}
  """
  def matching_currency?(%Transfer{money: money, from: from, to: to} = transfer) do
    if from.currency == money.currency and to.currency == money.currency do
      {:ok, transfer}
    else
      {:error, :mismatched_currencies,
       "Attempted to transfer :#{money.currency} from :#{from.identifier} in :#{from.currency} to :#{to.identifier} in :#{to.currency}."}
    end
  end

  @doc """
  ## Examples

  iex> %Transfer{
  iex>   money: MoneyProxy.new(42, :USD),
  iex>   from: %Account{identifier: :checking, currency: :USD, balance: MoneyProxy.new(42, :USD), positive_only?: true},
  iex>   to: %Account{identifier: :savings, currency: :USD},
  iex>   code: :deposit
  iex> }
  iex> |> Guard.positive_balance_if_enforced?()
  {
    :ok,
    %Transfer{
      money: MoneyProxy.new(42, :USD),
      code: :deposit,
      from: %Account{identifier: :checking, currency: :USD, balance: MoneyProxy.new(42, :USD), positive_only?: true},
      to: %Account{identifier: :savings, currency: :USD},
    }
  }

  iex> %Transfer{
  iex>   money: MoneyProxy.new(42, :USD),
  iex>   from: %Account{identifier: :checking, currency: :USD, balance: MoneyProxy.new(10, :USD), positive_only?: false},
  iex>   to: %Account{identifier: :savings, currency: :USD},
  iex>   code: :deposit
  iex> }
  iex> |> Guard.positive_balance_if_enforced?()
  {
    :ok,
    %Transfer{
      money: MoneyProxy.new(42, :USD),
      code: :deposit,
      from: %Account{identifier: :checking, currency: :USD, balance: MoneyProxy.new(10, :USD), positive_only?: false},
      to: %Account{identifier: :savings, currency: :USD},
    }
  }

  iex> %Transfer{
  iex>   money: MoneyProxy.new(42, :USD),
  iex>   from: %Account{identifier: :checking, currency: :USD, balance: MoneyProxy.new(10, :USD)},
  iex>   to: %Account{identifier: :savings, currency: :USD},
  iex>   code: :deposit
  iex> }
  iex> |> Guard.positive_balance_if_enforced?()
  {
    :ok,
    %Transfer{
      money: MoneyProxy.new(42, :USD),
      code: :deposit,
      from: %Account{identifier: :checking, currency: :USD, balance: MoneyProxy.new(10, :USD), positive_only?: nil},
      to: %Account{identifier: :savings, currency: :USD},
    }
  }

  iex> %Transfer{
  iex>   money: MoneyProxy.new(42, :USD),
  iex>   from: %Account{identifier: :checking, currency: :USD, balance: MoneyProxy.new(10, :USD), positive_only?: true},
  iex>   to: %Account{identifier: :savings, currency: :USD},
  iex>   code: :deposit
  iex> }
  iex> |> Guard.positive_balance_if_enforced?()
  {:error, :insufficient_balance, "Transfer amount: 42, :checking balance amount: 10"}
  """
  def positive_balance_if_enforced?(%Transfer{money: money, from: from} = transfer) do
    if !!from.positive_only? and MoneyProxy.cmp(from.balance, money) == :lt do
      {:error, :insufficient_balance,
       "Transfer amount: #{money.amount}, :#{from.identifier} balance amount: #{from.balance.amount}"}
    else
      {:ok, transfer}
    end
  end
end
