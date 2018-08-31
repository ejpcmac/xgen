defmodule XGen.Wizards.Nerves do
  @moduledoc """
  A wizard to setup Nerves projects.
  """

  use XGen.Wizard

  alias XGen.Wizards.{ElixirBase, LicenseChooser}

  @impl true
  @spec run :: :ok
  @spec run(keyword()) :: :ok
  def run(opts \\ []) do
    info([:bright, "\n=== Nerves project ===\n"])

    {path, elixir_opts} = ElixirBase.run()

    user_opts = [
      net: yes?("Add networking support?"),
      push: yes?("Add support to push firware updates via SSH?", false),
      ssh: yes?("Add SSH support with remote IEx sessions?", false),
      ntp: yes?("Add NTP support?", false),
      rtc: yes?("Add support for a DS3231 RTC?", false),
      contrib: yes?("Add a CONTRIBUTING.md?", false),
      license: LicenseChooser.run(),
      todo: yes?("Create a TODO file?", false),
      # TODO: Remove double negation.
      no_git: !yes?("Initialise a git repository?")
    ]

    info("\nGenerating the project...")
    XGen.generate(:nerves, path, opts ++ elixir_opts ++ user_opts)
  end
end
