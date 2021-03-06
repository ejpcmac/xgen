defmodule XGen do
  @moduledoc """
  An opinionated interactive project generator.

  ## Commands

    * `generate`: executes the project generator *(default)*
    * `config`: configures xgen
    * `update`: updates xgen

  ## Options

    * `--config <file>`: indicate which configuration file to use. Defaults to
      `~/.xgen.exs`
  """

  use ExCLI.DSL

  import Marcus

  alias XGen.Configuration
  alias XGen.Generator
  alias XGen.Generators.Elixir.{Escript, Nerves, Std}
  alias XGen.Options.Config

  @repo "ejpcmac/xgen"
  @version Mix.Project.config()[:version]

  @config_options [
    Config.Name,
    Config.GitHubAccount
  ]

  @generators [
    Std,
    Nerves,
    Escript
  ]

  name "xgen"
  description "An opinionated project generator"

  option :config,
    help: "Set a config file",
    aliases: [:c]

  default_command :generate

  command :generate do
    description "Generates a project"

    run context do
      context
      |> get_config_file()
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

  command :config do
    description "Configures xgen"

    run context do
      context
      |> get_config_file()
      |> Configuration.resolve(@config_options, always_update: true)
    end
  end

  command :update do
    description "Updates xgen"

    option :dev,
      type: :boolean,
      help: "Use the development version"

    run context do
      dev? = Map.get(context, :dev, false)
      opts = if dev?, do: ["branch", "develop"], else: []

      case System.find_executable("mix") do
        nil ->
          halt("""
          xgen needs Mix to fetch and build its update.
          Mix does not seem to be installed on your machine. Aborting.
          """)

        mix ->
          System.cmd(
            mix,
            ["escript.install", "--force", "github", @repo] ++ opts,
            into: IO.stream(:stdio, :line)
          )
      end
    end
  end

  @doc false
  @spec main([binary()]) :: any()
  def main(args) do
    enable_colors()
    info("xgen #{@version}\n")
    ExCLI.run!(__MODULE__, args)
  end

  ##
  ## Helpers
  ##

  @spec get_config_file(map()) :: Path.t()
  defp get_config_file(context) do
    Map.get(context, :config, System.user_home() |> Path.join(".xgen.exs"))
  end
end
