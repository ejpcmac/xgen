defmodule XGen do
  @moduledoc """
  An opinionated project generator.

  ## Options

    * `--config <file>`: indicate which configuration file to use. Defaults to
      `~/.xgen.exs`
  """

  alias XGen.Configuration
  alias XGen.Generator
  alias XGen.Generators.Elixir.{Nerves, Std}
  alias XGen.Options.Config

  import XGen.Wizard

  @version Mix.Project.config()[:version]
  @switches [
    config: :string
  ]

  @config_options [
    Config.Name,
    Config.GitHubAccount
  ]

  @generators [
    Std,
    Nerves
  ]

  @spec main([binary()]) :: :ok | no_return()
  def main(args) do
    # Enable ANSI printing. This could cause issues on Windows, but it is not
    # supported yet.
    Application.put_env(:elixir, :ansi_enabled, true)

    info("xgen #{@version}\n")

    {opts, _argv} = OptionParser.parse!(args, strict: @switches)

    opts
    |> Keyword.get(:config, System.user_home() |> Path.join(".xgen.exs"))
    |> Configuration.resolve(@config_options)
    |> run(@generators)
  end

  @spec run(map(), [Generator.t()]) :: :ok | no_return()
  defp run(config, generators) do
    project_types = generators |> Enum.map(&{&1, &1.name()})

    "Which kind of project do you want to start?"
    |> choose(project_types)
    |> Generator.run(config)
  end
end
