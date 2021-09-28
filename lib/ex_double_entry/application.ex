defmodule ExDoubleEntry.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ExDoubleEntry.Repo
    ]

    opts = [strategy: :one_for_one, name: ExDoubleEntry.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
