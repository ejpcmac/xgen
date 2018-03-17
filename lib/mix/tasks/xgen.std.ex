defmodule Mix.Tasks.Xgen.Std do
  use Mix.Task

  import ExGen.Help

  @shortdoc "Generates a standard Elixir project"

  @moduledoc """
  Generates a standard Elixir project.

  ## Usage

      mix xgen.std <path> [--app <app>] [--module <module>] [--sup] [--rel]
                          [--contrib] [--package] [--license <license>] [--todo]
                          [--no-git] [--config <file>]

  #{general_description()}

  ## Options

    * #{app()}
    * #{module()}
    * #{sup()}
    * `--rel`: add a Distillery configuration to the project.
    * #{contrib()}
    * `--package`: add package information in `mix.exs`.
    * #{license()} If the `--package` option is set, the license is precised in
      the package information.
    * #{todo()}
    * #{no_git()}
    * #{config()}

  #{supported_licences()}
  """

  @switches [
    app: :string,
    module: :string,
    sup: :boolean,
    rel: :boolean,
    contrib: :boolean,
    package: :boolean,
    license: :string,
    todo: :boolean,
    no_git: :boolean,
    config: :string
  ]

  @impl true
  def run(args) do
    {opts, argv} = OptionParser.parse!(args, strict: @switches)

    case argv do
      [] -> Mix.Tasks.Help.run(["xgen.std"])
      [path | _] -> ExGen.generate(:std, path, opts)
    end
  end
end
