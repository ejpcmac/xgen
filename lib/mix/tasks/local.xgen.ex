defmodule Mix.Tasks.Local.Xgen do
  use Mix.Task

  @shortdoc "Updates ExGen locally"

  @moduledoc """
  Updates ExGen locally.

  ## Usage

      mix local.xgen

  Accepts the same command line options as `archive.install`.
  """

  @url "https://ejpcmac.net/bin/ex_gen.ez"

  @impl true
  def run(args) do
    Mix.Task.run("archive.install", [@url | args])
  end
end
