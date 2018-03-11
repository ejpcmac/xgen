defmodule Mix.Tasks.Xgen.Nerves do
  use Mix.Task

  @shortdoc "Generates a Nerves project"

  @moduledoc """
  Generates a Nerves project.

  ## Usage

      mix xgen.nerves <path> [--app <app>] [--module <module>] [--sup] [--net]
                             [--contrib] [--license <license>] [--todo]
                             [--config <file>]

  A project will be create at the given `<path>`. The application and module
  names will be inferred from the path, unless you specify them using the
  `--app` and `--module` options.

  ## Options

    * `--app <app>`: set the OTP application name for the project.
    * `--module <module>`: set the module name for the project.
    * `--sup`: add an `Application` module to the project containing a
      supervision tree. This option also adds the callback in the `mix.exs`.
    * `--net`: add `nerves_network` to the project with a basic configuration.
    * `--contrib`: add a `CONTRIBUTING.md` to the project.
    * `--license <license>`: set the license for the project. If the license is
      supported, a `LICENSE` file is created with the maintainer name.
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
    net: :boolean,
    contrib: :boolean,
    license: :string,
    todo: :boolean,
    config: :string
  ]

  @impl true
  def run(args) do
    {opts, argv} = OptionParser.parse!(args, strict: @switches)

    case argv do
      [] ->
        Mix.raise(
          "Expected <path> to be given. Please use `mix xgen.nerves <path>`."
        )

      [path | _] ->
        ExGen.generate(:nerves, path, opts)
    end
  end
end
