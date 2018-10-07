defmodule XGen.CLI do
  @moduledoc """
  Command-line interface for XGen.

  ## Options

    * `--config <file>`: indicate which configuration file to use. Defaults to
      `~/.xgen.exs`
  """

  alias XGen.Wizards.{ConfigUpdater, ProjectGenerator}

  import XGen.Wizard

  @version Mix.Project.config()[:version]
  @switches [
    config: :string
  ]

  @spec main([binary()]) :: :ok | no_return()
  def main(args) do
    # Enable ANSI printing. This could cause issues on Windows, but it is not
    # supported yet.
    Application.put_env(:elixir, :ansi_enabled, true)

    info("xgen #{@version}\n")

    {opts, _argv} = OptionParser.parse!(args, strict: @switches)
    config_file = opts[:config] || System.user_home() |> Path.join(".xgen.exs")

    ConfigUpdater.run(file: config_file)
    ProjectGenerator.run(config: config_file)
  end
end
