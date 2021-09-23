defmodule ExDoubleEntry.Account do
  @enforce_keys [:identifier, :currency]
  defstruct [:id, :identifier, :scope, :currency, :balance, :positive_only?]

  alias ExDoubleEntry.{Account, AccountBalance}

  def present(nil), do: nil

  def present(%AccountBalance{} = params) do
    %Account{
      id: params.id,
      identifier: params.identifier,
      currency: params.currency,
      scope: params.scope,
      positive_only?: positive_only?(params.identifier),
      balance: Money.new(params.balance_amount, params.currency)
    }
  end

  def lookup!(identifier, opts \\ []) do
    opts = [identifier: identifier, currency: currency(opts)] ++ opts

    Account
    |> struct(opts)
    |> AccountBalance.find()
    |> present()
  end

  def make!(identifier, opts \\ []) do
    %Account{
      identifier: identifier,
      currency: currency(opts),
      scope: opts[:scope],
      positive_only?: positive_only?(identifier)
    }
    |> AccountBalance.create!()
    |> present()
  end

  defp currency(opts) do
    opts[:currency] || Application.fetch_env!(:ex_double_entry, :default_currency)
  end

  defp positive_only?(identifier) do
    account_opts =
      :ex_double_entry
      |> Application.fetch_env!(:accounts)
      |> Map.fetch!(identifier)

    !! account_opts[:positive_only]
  end
end

defmodule ExDoubleEntry.Account.NotFoundError do
  defexception message: "Account not found."
end

defmodule ExDoubleEntry.Account.InvalidScopeError do
  defexception message: "Invalid scope: empty string not allowed."
end
