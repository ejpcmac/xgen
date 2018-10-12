defmodule XGen.Options.Elixir.Nerves do
  @moduledoc false

  use XGen.Option, collection: true

  defoption Networking do
    key :networking?
    type :yesno
    default :yes
    name "Networking"
    prompt "Add networking support?"

    documentation """
    In Nerves applications, network interfaces are configured directly in Elixir
    thanks to nerves_network. xgen can add nerves_network to the project
    dependencies and generate a default configuration.
    """
  end

  defoption SSHFirmwareUpdates do
    key :push?
    type :yesno
    default :no
    name "SSH firmware updates"
    prompt "Add support to pushing firmware updates via SSH?"

    documentation """
    Instead of using `mix firmware.burn` each time you build a new firmware, you
    can push updates through the network using nerves_firmware_ssh. xgen can add
    it to the project dependencies and generate SSH keys. It even adds a shell
    script at the project root to generate them on other computers for the
    development phase. Generate keys are stored in priv/ssh so you can do:

        $ mix firmware.push --user-dir priv/ssh <target_ip>
    """
  end

  defoption SSH do
    key :ssh?
    type :yesno
    default :no
    name "SSH server"
    prompt "Add SSH support with remote IEx sessions?"

    documentation """
    It can sometimes be handy to log onto a device and get an interactive Elixir
    console to help debugging. xgen can generate a little SSH server started on
    application init. It also adds nerves_runtime_shell so you can execute
    non-Elixir command more easily.
    """
  end

  defoption NTP do
    key :ntp?
    type :yesno
    default :no
    name "NTP support"
    prompt "Add NTP support?"

    documentation """
    Some targets like Raspberry Pis do not feature a Real Time Clock. If you
    need to set the correct date & time, xgen can add NTP support via nerves_ntp
    to automatically synchronise the time through the network.
    """
  end

  defoption RTC do
    key :rtc?
    type :yesno
    default :no
    name "Real Time Clock support"
    prompt "Add support for a DS3231 RTC?"

    documentation """
    If you need to keep the correct date & time between reboots and do not
    always have a network available, you can use a RTC. Currently, xgen can add
    support for a DS3231 RTC.

    If you have opted-in for the supervision tree generation, enabling this
    option will also add a startup task to automatically set the system time
    from the RTC. If you have opted-in for both the supervision tree and NTP
    support, another task is added to synchronise the RTC 15 seconds after
    startup from system time. This way, the device can first synchronise through
    NTP, then get the RTC synchronised too.
    """
  end
end
