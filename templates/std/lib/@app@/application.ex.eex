defmodule <%= @mod %>.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # <%= @mod %>.Worker1,
      # {<%= @mod %>.Worker2, arg},
    ]

    opts = [strategy: :one_for_one, name: <%= @mod %>.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
