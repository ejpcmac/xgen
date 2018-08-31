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
      net: net?(),
      push: push?(),
      ssh: ssh?(),
      ntp: ntp?(),
      rtc: rtc?(),
      contrib: contrib?(),
      license: LicenseChooser.run(),
      todo: yes?("Create a TODO file?", :no),
      git: yes?("Initialise a Git repository?", :yes)
    ]

    info("\nGenerating the project...")
    XGen.generate(:nerves, path, opts ++ elixir_opts ++ user_opts)
  end

  defp net? do
    doc(
      "Networking",
      """
      In Nerves applications, network interfaces are configured directly in
      Elixir thanks to nerves_network. xgen can add nerves_network to the
      project dependencies and generate a default configuration.
      """
    )

    yes?("Add networking support?", :yes)
  end

  defp push? do
    doc(
      "SSH firmware updates",
      """
      Instead of using `mix firmware.burn` each time you build a new firmware,
      you can push updates through the network using nerves_firmware_ssh. xgen
      can add it to the project dependencies and generate SSH keys. It even adds
      a shell script at the project root to generate them on other computers
      for the development phase. Generate keys are stored in priv/ssh so you
      can do:

          $ mix firmware.push --user-dir priv/ssh <target_ip>
      """
    )

    yes?("Add support to pushing firware updates via SSH?", :no)
  end

  defp ssh? do
    doc(
      "SSH server",
      """
      It can sometimes be handy to log onto a device and get an interactive
      Elixir console to help debugging. xgen can generate a little SSH server
      started on application init. It also adds nerves_runtime_shell so you can
      execute non-Elixir command more easily.
      """
    )

    yes?("Add SSH support with remote IEx sessions?", :no)
  end

  defp ntp? do
    doc(
      "NTP support",
      """
      Some targets like Raspberry Pis do not feature a Real Time Clock. If you
      need to set the correct date & time, xgen can add NTP support via
      nerves_ntp to automatically synchronise the time through the network.
      """
    )

    yes?("Add NTP support?", :no)
  end

  defp rtc? do
    doc(
      "Real Time Clock support",
      """
      If you need to keep the correct date & time between reboots and do not
      always have a network available, you can use a RTC. Currently, xgen can
      add support for a DS3231 RTC.

      If you have opted-in for the supervision tree generation, enabling this
      option will also add a startup task to automatically set the system time
      from the RTC. If you have opted-in for both the supervision tree and NTP
      support, another task is added to synchronise the RTC 15 seconds after
      startup from system time. This way, the device can first synchronise
      through NTP, then get the RTC synchronised too.
      """
    )

    yes?("Add support for a DS3231 RTC?", :no)
  end

  defp contrib? do
    doc(
      "CONTRIBUTING.md",
      """
      xgen can add a CONTRIBUTING.md with generic instructions for Elixir
      projects hosted on GitHub. It covers all steps from forking to setting
      the environment and creating a pull request.

      Currently, there are no special instructions for Nerves projects.
      """
    )

    yes?("Add a CONTRIBUTING.md?", :no)
  end
end
