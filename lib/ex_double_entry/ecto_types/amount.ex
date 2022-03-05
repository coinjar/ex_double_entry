if Code.ensure_loaded?(Ecto.Type) do
  defmodule ExDoubleEntry.EctoType.Amount do
    if macro_exported?(Ecto.Type, :__using__, 1) do
      use Ecto.Type
    else
      @behaviour Ecto.Type
    end

    def type, do: :integer

    def cast(val) when is_integer(val), do: {:ok, val}
    def cast(%Decimal{} = val), do: {:ok, Decimal.to_integer(val)}
    def cast(_), do: :error

    def load(val) when is_integer(val), do: {:ok, val}

    def dump(val) when is_integer(val), do: {:ok, val}
    def dump(%Decimal{} = val), do: {:ok, Decimal.to_integer(val)}
    def dump(_), do: :error
  end
end
