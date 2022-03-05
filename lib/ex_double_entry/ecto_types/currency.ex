if Code.ensure_loaded?(Ecto.Type) do
  defmodule ExDoubleEntry.EctoType.Currency do
    if macro_exported?(Ecto.Type, :__using__, 1) do
      use Ecto.Type
    else
      @behaviour Ecto.Type
    end

    def type, do: :string

    def cast(val)

    def cast(%{currency: currency}), do: {:ok, currency}

    def cast(atom) when is_atom(atom), do: {:ok, atom}

    def cast(str) when is_binary(str) do
      {:ok, String.to_atom(str)}
    rescue
      _ -> :error
    end

    def cast(_), do: :error

    def load(str) when is_binary(str), do: {:ok, String.to_atom(str)}

    def dump(atom) when is_atom(atom), do: {:ok, Atom.to_string(atom)}
    def dump(_), do: :error
  end
end
