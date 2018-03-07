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
        nil
        app = opts[:app] || path |> Path.expand() |> Path.basename()
        mod = opts[:module] || Macro.camelize(app)

        unless path == "." do
          check_directory_existence!(path)
          File.mkdir_p!(path)
        end

        compiled? =
          File.cd!(path, fn ->
            ExGen.generate(:nerves, app, mod, opts)
            ExGen.build(:nerves)
          end)

        Mix.shell().info("""

        Your project has been successfully created.
        """)

        unless compiled? do
          Mix.shell().info("""
          You can now fetch its dependencies:

              cd #{path}
              mix deps.get
          """)
        end

        Mix.shell().info("""
        You can then build a firmware image:

            cd #{path}
            MIX_ENV=prod MIX_TARGET=rpi3 mix do deps.get, firmware

        After your first commit, you can setup gitflow:

            ./.gitsetup
        """)
    end
  end

  @spec check_directory_existence!(String.t()) :: nil | no_return()
  defp check_directory_existence!(path) do
    msg =
      "The directory #{inspect(path)} already exists. Are you sure you want " <>
        "to continue?"

    if File.dir?(path) and not Mix.shell().yes?(msg) do
      Mix.raise("Please select another directory for installation")
    end
  end
end