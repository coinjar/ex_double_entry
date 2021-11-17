defmodule ExDoubleEntry.Factory do
  use ExMachina.Ecto, repo: ExDoubleEntry.repo()

  def account_balance_factory do
    %ExDoubleEntry.AccountBalance{
      identifier: :savings,
      currency: :USD,
      scope: nil,
      balance_amount: 0
    }
  end
end
