defmodule Mix.Tasks.Local.Xgen do
  use Mix.Task

  @shortdoc "Updates xgen locally"

  @moduledoc """
  Updates xgen locally.

  ## Usage

      mix local.xgen

  Accepts the same command line options as `archive.install`.
  """

  @repo "ejpcmac/xgen"

  @impl true
  def run(args) do
    Mix.Task.run("archive.install", ["github", @repo] ++ args)
  end
end
