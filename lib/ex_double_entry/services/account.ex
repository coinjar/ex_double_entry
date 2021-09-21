defmodule ExDoubleEntry.Account do
  @enforce_keys [:identifier, :currency]
  defstruct [:id, :identifier, :scope, :currency, :balance, :positive_only?]

  alias ExDoubleEntry.AccountBalance

  def present(%AccountBalance{} = params) do
    %__MODULE__{
      id: params.id,
      identifier: params.identifier,
      currency: params.currency,
      scope: params.scope,
      positive_only?: positive_only?(params.identifier),
      balance: Money.new(params.balance_amount, params.currency)
    }
  end

  @doc """
  ## Examples

  iex> Account.make!(:savings)
  %Account{identifier: :savings, currency: :USD, scope: nil, positive_only?: true}

  iex> Account.make!(:savings, currency: :AUD)
  %Account{identifier: :savings, currency: :AUD, scope: nil, positive_only?: true}

  iex> Account.make!(:checking, currency: :AUD, scope: "user/1")
  %Account{identifier: :checking, currency: :AUD, scope: "user/1", positive_only?: false}
  """
  def make!(identifier, opts \\ []) do
    %__MODULE__{
      identifier: identifier,
      currency: currency(opts),
      scope: opts[:scope],
      positive_only?: positive_only?(identifier)
    }
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
