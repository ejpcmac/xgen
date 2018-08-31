defmodule Mix.Tasks.Xgen do
  use Mix.Task

  @shortdoc "Runs the interactive project generator."

  @moduledoc """
  Runs the interactive project generator.

  ## Options

    * `--config <file>`: indicate which configuration file to use. Defaults to
      `~/.xgen.exs`
  """

  alias XGen.Wizards.{ConfigCreator, ProjectGenerator}

  import XGen.Wizard

  @version Mix.Project.config()[:version]
  @switches [
    config: :string
  ]

  @impl true
  @spec run([binary()]) :: :ok | no_return()
  def run(args) do
    info("xgen #{@version}\n")

    {opts, _argv} = OptionParser.parse!(args, strict: @switches)
    config_file = opts[:config] || user_home() |> Path.join(".xgen.exs")

    unless File.regular?(config_file) do
      ConfigCreator.run(file: config_file)
    end

    ProjectGenerator.run(config: config_file)
  end
end
