if Code.ensure_loaded?(Ecto.Type) do
  defmodule ExDoubleEntry.EctoType.Scope do
    if macro_exported?(Ecto.Type, :__using__, 1) do
      use Ecto.Type
    else
      @behaviour Ecto.Type
    end

    def type, do: :string

    def cast(nil), do: {:ok, ""}
    def cast(atom) when is_atom(atom), do: {:ok, Atom.to_string(atom)}
    def cast(str) when is_binary(str), do: {:ok, str}
    def cast(_), do: :error

    def load(""), do: {:ok, nil}
    def load(str) when is_binary(str), do: {:ok, str}

    def dump(str) when is_binary(str), do: {:ok, str}
    def dump(_), do: :error
  end
end
