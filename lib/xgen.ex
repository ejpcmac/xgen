defmodule XGen do
  @moduledoc """
  An opinionated project generator.

  ## Options

    * `--config <file>`: indicate which configuration file to use. Defaults to
      `~/.xgen.exs`
  """

  use ExCLI.DSL

  alias XGen.Configuration
  alias XGen.Generator
  alias XGen.Generators.Elixir.{Nerves, Std}
  alias XGen.Options.Config

  import XGen.Prompt

  @version Mix.Project.config()[:version]

  @config_options [
    Config.Name,
    Config.GitHubAccount
  ]

  @generators [
    Std,
    Nerves
  ]

  name "xgen"
  description "An opinionated project generator"

  option :config,
    help: "Sets a config file",
    aliases: [:c]

  default_command :generate

  command :generate do
    description "Generates a project"

    run context do
      info("xgen #{@version}\n")

      context
      |> Map.get(:config, System.user_home() |> Path.join(".xgen.exs"))
      |> Configuration.resolve(@config_options)
      |> generate(@generators)
    end
  end

  @spec generate(map(), [Generator.t()]) :: :ok | no_return()
  defp generate(config, generators) do
    project_types = generators |> Enum.map(&{&1, &1.name()})

    "Which kind of project do you want to start?"
    |> choose(project_types)
    |> Generator.run(config)
  end

  @doc false
  @spec main([binary()]) :: any()
  def main(args) do
    # Enable ANSI printing. This could cause issues on Windows, but it is not
    # supported yet.
    Application.put_env(:elixir, :ansi_enabled, true)
    ExCLI.run!(__MODULE__, args)
  end
end
