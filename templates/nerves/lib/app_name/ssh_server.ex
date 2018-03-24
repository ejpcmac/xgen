defmodule <%= @mod %>.SSHServer do
  @moduledoc """
  SSH server for the Nerves application.
  """

  use GenServer

  @doc """
  Starts the SSH server.
  """
  @spec start_link(GenServer.options()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    system_dir = '/etc/ssh'

    user_dir =
      :<%= @app %>
      |> Application.app_dir("priv/ssh")
      |> String.to_charlist()

    {:ok, server} =
      :ssh.daemon(
        22,
        shell: {IEx, :start, []},
        id_string: :random,
        system_dir: system_dir,
        user_dir: user_dir
      )

    # Link to the server.
    Process.link(server)

    {:ok, nil, :hibernate}
  end
end
