defmodule ExDoubleEntry.MoneyProxy do
  @moduledoc """
  The `Money` and `ExMoney` packages both claim the `Money` module namespace,
  therefore this proxy module normalises the function uses so that ExDoubleEntry
  can be used by either.
  """

  defdelegate new(amount, currency), to: Money

  def add(a, b) do
    if function_exported?(Money, :add!, 2) do
      apply(Money, :add!, [a, b])
    else
      apply(Money, :add, [a, b])
    end
  end

  def subtract(a, b) do
    if function_exported?(Money, :sub!, 2) do
      apply(Money, :sub!, [a, b])
    else
      apply(Money, :subtract, [a, b])
    end
  end

  def cmp(a, b) do
    if function_exported?(Money, :compare!, 2) do
      apply(Money, :compare!, [a, b])
    else
      apply(Money, :cmp, [a, b])
    end
  end

  def neg(money) do
    if function_exported?(Money, :neg, 1) do
      apply(Money, :neg, [money])
    else
      apply(Money, :mult!, [money, -1])
    end
  end

  def positive?(money) do
    if function_exported?(Money, :positive?, 1) do
      apply(Money, :positive?, [money])
    else
      apply(Money, :cmp!, [money, Money.new(0, money.currency)]) >= 0
    end
  end
end
