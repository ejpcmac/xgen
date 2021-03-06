defmodule XGen.Generators.Elixir.Nerves do
  @moduledoc """
  A generator for Nerves projects.
  """

  use XGen.Generator

  import Marcus
  import XGen.Generator.StandardCallbacks
  import XGen.Generators.Elixir.Helpers

  alias XGen.Options.Base
  alias XGen.Options.Elixir.Base, as: ElixirBase
  alias XGen.Options.Elixir.Nerves

  type :nerves

  name "Nerves project"

  options [
    ElixirBase.Application,
    ElixirBase.Module,
    ElixirBase.SupervisionTree,
    Nerves.Networking,
    Nerves.SSHFirmwareUpdates,
    Nerves.SSH,
    Nerves.NTP,
    Nerves.RTC,
    Base.Contributing,
    Base.License,
    Base.Git
  ]

  overrides %{
    initial_version: "0.0.1",
    module_path: Macro.underscore(@module),
    cookie: generate_cookie(),
    sup?: @sup? || @ssh?,
    ci?: false
  }

  collection do
    [
      "_base_/README.md.eex",
      "_base_/CHANGELOG.md.eex",
      "_elixir_/_base_/shell.nix.eex",
      "_base_/.envrc",
      "_base_/.editorconfig",
      "_elixir_/_nerves_/.formatter.exs.eex",
      "_elixir_/_base_/.gitignore.eex",
      "_elixir_/_nerves_/mix.exs.eex",
      "_elixir_/_nerves_/config/config.exs.eex",
      "_elixir_/_std_/lib/@module_path@.ex.eex",
      "_elixir_/_nerves_/rel/plugins/.gitignore",
      "_elixir_/_nerves_/rel/config.exs.eex",
      "_elixir_/_nerves_/rel/vm.args.eex",
      "_elixir_/_nerves_/rootfs_overlay/etc/erlinit.config",
      "_elixir_/_nerves_/rootfs_overlay/etc/iex.exs",
      "_elixir_/_nerves_/test/test_helper.exs"
    ]
  end

  collection @sup?,
    do: ["_elixir_/_nerves_/lib/@module_path@/application.ex.eex"]

  collection @ssh?,
    do: ["_elixir_/_nerves_/lib/@module_path@/ssh_server.ex.eex"]

  collection @push? or @ssh?, do: ["_elixir_/_nerves_/gen-ssh-keys"]
  collection @contributing?, do: ["_elixir_/_nerves_/CONTRIBUTING.md.eex"]
  collection @license?, do: ["_base_/LICENSE+#{@license}.eex"]
  collection @git?, do: ["_base_/.gitsetup"]

  postgen :generate_ssh_keys
  postgen :init_git
  postgen :fetch_deps
  postgen :run_formatter
  postgen :project_created
  postgen :build_instructions
  postgen :gitsetup_instructions

  ##
  ## Post-generation callbacks
  ##

  @spec generate_ssh_keys(map()) :: map()
  defp generate_ssh_keys(opts) do
    if opts[:push?] || opts[:ssh?] do
      system_dir = "rootfs_overlay/etc/ssh"
      user_dir = "priv/ssh"

      # Generate target host SSH key.
      green_info("* generating target host SSH key")
      File.mkdir_p!(system_dir)

      _ =
        :os.cmd(
          'ssh-keygen -q -t rsa -b 4096 -N "" -f #{system_dir}/ssh_host_rsa_key'
        )

      # Generate user SSH key.
      green_info("* generating user SSH key")
      File.mkdir_p!(user_dir)
      _ = :os.cmd('ssh-keygen -q -t rsa -b 4096 -N "" -f #{user_dir}/id_rsa')

      # Get the generated user key.
      local_key = user_dir |> Path.join("id_rsa.pub") |> File.read!()

      # Get the global user key.
      global_key =
        System.user_home!() |> Path.join(".ssh/id_rsa.pub") |> File.read!()

      # Add both user keys to the authorized_keys.
      user_dir
      |> Path.join("authorized_keys")
      |> File.write!(local_key <> global_key)

      # Make the generator executable.
      File.chmod!("gen-ssh-keys", 0o755)
    end

    opts
  end

  @spec build_instructions(map()) :: map()
  defp build_instructions(opts) do
    info("""
    You can now build a firmware image:

        cd #{opts.path}
        direnv allow
        MIX_ENV=prod MIX_TARGET=rpi3 mix do deps.get, firmware
    """)

    opts
  end
end
