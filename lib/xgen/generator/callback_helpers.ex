defmodule XGen.Generator.CallbackHelpers do
  @moduledoc """
  Helpers to create generator callbacks.
  """

  import XGen.Wizard

  @doc """
  Runs a command.
  """
  @spec run_command(binary(), [binary()], keyword()) :: :ok
  def run_command(cmd, args, opts \\ []) do
    env = Enum.map(opts[:env] || [], fn {key, value} -> " #{key}=#{value}" end)
    fmt_args = Enum.join(args, " ")

    info([:green, "* running", :reset] ++ env ++ [" #{cmd} ", fmt_args])

    _ = System.cmd(cmd, args, opts)
    :ok
  end
end
