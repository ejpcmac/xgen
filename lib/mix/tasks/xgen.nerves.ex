defmodule Mix.Tasks.Xgen.Nerves do
  use Mix.Task

  import ExGen.Help

  @shortdoc "Generates a Nerves project"

  @moduledoc """
  Generates a Nerves project.

  ## Usage

      mix xgen.nerves <path> [--app <app>] [--module <module>] [--sup] [--net]
                             [--contrib] [--license <license>] [--todo]
                             [--no-git] [--config <file>]

  #{general_description()}

  ## Options

    * #{app()}
    * #{module()}
    * #{sup()}
    * `--net`: add `nerves_network` to the project with a basic configuration.
    * #{contrib()}
    * #{license()}
    * #{todo()}
    * #{no_git()}
    * #{config()}

  #{supported_licences()}
  """

  @switches [
    app: :string,
    module: :string,
    sup: :boolean,
    net: :boolean,
    contrib: :boolean,
    license: :string,
    todo: :boolean,
    no_git: :boolean,
    config: :string
  ]

  @impl true
  def run(args) do
    {opts, argv} = OptionParser.parse!(args, strict: @switches)

    case argv do
      [] -> Mix.Tasks.Help.run(["xgen.nerves"])
      [path | _] -> ExGen.generate(:nerves, path, opts)
    end
  end
end
