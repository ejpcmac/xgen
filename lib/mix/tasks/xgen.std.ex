defmodule Mix.Tasks.Xgen.Std do
  use Mix.Task

  @shortdoc "Generates a standard Elixir project"

  @moduledoc """
  Generates a standard Elixir project.

  ## Usage

      mix xgen.std <path> [--app <app>] [--module <module>] [--sup] [--contrib]
                          [--package] [--license <license>] [--todo]
                          [--config <file>]

  A project will be create at the given `<path>`. The application and module
  names will be inferred from the path, unless you specify them using the
  `--app` and `--module` options.

  ## Options

    * `--app <app>`: set the OTP application name for the project.
    * `--module <module>`: set the module name for the project.
    * `--sup`: add an `Application` module to the project containing a
      supervision tree. This option also adds the callback in the `mix.exs`.
    * `--contrib`: add a `CONTRIBUTING.md` to the project.
    * `--package`: add package information in the `mix.exs`.
    * `--license <license>`: set the license for the project. If the `--package`
      option is set, the license is precised in the package information. If the
      license is supported, a `LICENSE` file is created with the maintainer
      name.
    * `--todo`: add a `TODO` file to the project. This file is also added to
      the Git excluded files in `.git/info/exclude`.
    * `--config <file>`: indicate which configuration file to use. Defaults to
      `~/.xgen.exs`

  ## Supported licenses

  Currently, only the `MIT` license is supported.
  """

  @switches [
    app: :string,
    module: :string,
    sup: :boolean,
    contrib: :boolean,
    package: :boolean,
    license: :string,
    todo: :boolean,
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
