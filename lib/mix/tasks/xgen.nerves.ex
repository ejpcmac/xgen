defmodule Mix.Tasks.Xgen.Nerves do
  use Mix.Task

  import ExGen.Help

  @shortdoc "Generates a Nerves project"

  @moduledoc """
  Generates a Nerves project.

  ## Usage

      mix xgen.nerves <path> [--app <app>] [--module <module>] [--sup] [--net]
                             [--push] [--ssh] [--ntp ] [--rtc] [--contrib]
                             [--license <license>] [--todo] [--no-git]
                             [--config <file>]

  #{general_description()}

  ## Options

    * #{app()}
    * #{module()}
    * #{sup()}
    * `--net`: add `nerves_network` to the project with a basic configuration.
    * `--push`: add `nerves_firmware_ssh` to the project to push fwupdates over
      the air.
    * `--ssh`: add an SSH server to the project. This enables remote IEx
      sessions through SSH. (implies `--sup`)
    * `--ntp`: add `nerves_ntp` to the project.
    * `--rtc`: add support for a DS3231 RTC. If the `--sup` option is set, a
      temporary task is generated to set the OS time from the RTC on startup. If
      both `--sup` and `--ntp` are set, a temporary task is generated to sync
      the RTC from OS time 15 seconds after the application startup. This lets
      some time for NTP to sync.
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
    push: :boolean,
    ssh: :boolean,
    ntp: :boolean,
    rtc: :boolean,
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
