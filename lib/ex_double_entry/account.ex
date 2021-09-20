defmodule ExDoubleEntry.Account do
  @enforce_keys [:identifier, :currency]
  defstruct [:identifier, :currency, :scope, :positive_only]

  @doc """
  ## Examples

  iex> Account.make!(:savings)
  iex> %Account{identifier: :savings, currency: :USD, scope: nil, positive_only: true}

  iex> Account.make!(:savings, currency: :AUD)
  iex> %Account{identifier: :savings, currency: :AUD, scope: nil, positive_only: true}

  iex> Account.make!(:checking, currency: :AUD, scope: "user/1")
  iex> %Account{identifier: :savings, currency: :AUD, scope: "user/1", positive_only: false}
  """
  def make!(identifier, opts \\ []) do
    currency =
      opts[:currency] || Application.fetch_env!(:ex_double_entry, :default_currency)

    account_opts =
      :ex_double_entry
      |> Application.fetch_env!(:accounts)
      |> Map.fetch!(identifier)

    %__MODULE__{
      identifier: identifier,
      currency: currency,
      scope: opts[:scope],
      positive_only: !! account_opts[:positive_only]
    }
  end
end
