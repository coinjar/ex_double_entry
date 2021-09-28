defmodule ExDoubleEntry.AccountTest do
  use ExDoubleEntry.DataCase
  alias ExDoubleEntry.Account
  doctest Account

  test "present/1" do
    balance = Money.new(42, :USD)

    account =
      :account_balance
      |> insert(identifier: :savings, currency: :USD, scope: "user/1", balance_amount: 42)
      |> Account.present()

    assert %Account{
             identifier: :savings,
             currency: :USD,
             scope: "user/1",
             positive_only?: true,
             balance: ^balance
           } = account
  end

  describe "lookup!/2" do
    test "found" do
      insert(:account_balance, identifier: :savings, currency: :USD, balance_amount: 42)

      balance = Money.new(42, :USD)

      assert %Account{
               identifier: :savings,
               currency: :USD,
               balance: ^balance
             } = Account.lookup!(:savings, currency: :USD)
    end

    test "with default currency" do
      insert(:account_balance, identifier: :savings, currency: :USD, balance_amount: 42)

      balance = Money.new(42, :USD)

      assert %Account{
               identifier: :savings,
               currency: :USD,
               balance: ^balance
             } = Account.lookup!(:savings)
    end

    test "not found" do
      refute Account.lookup!(:savings, currency: :USD)
    end
  end

  describe "make!/2" do
    test "a" do
      assert %Account{
               identifier: :savings,
               currency: :USD,
               scope: nil,
               positive_only?: true
             } = Account.make!(:savings)
    end

    test "b" do
      assert %Account{
               identifier: :savings,
               currency: :AUD,
               scope: nil,
               positive_only?: true
             } = Account.make!(:savings, currency: :AUD)
    end

    test "c" do
      assert %Account{
               identifier: :checking,
               currency: :AUD,
               scope: "user/1",
               positive_only?: false
             } = Account.make!(:checking, currency: :AUD, scope: "user/1")
    end
  end
end
