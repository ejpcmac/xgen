defmodule XGen.Generators.Elixir.Nerves do
  @moduledoc """
  A generator for Nerves projects.
  """

  use XGen.Generator

  import XGen.Generator.CallbackHelpers
  import XGen.Generator.StandardCallbacks
  import XGen.Generators.Elixir.Callbacks

  alias XGen.Options.Base
  alias XGen.Options.Elixir.Base, as: ElixirBase
  alias XGen.Options.Elixir.Nerves
  alias XGen.Prompt

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
    Nerves.Contributing,
    Base.License,
    Base.Git
  ]

  pregen :module_path
  pregen :cookie
  pregen :supervision_for_ssh

  collection do
    [
      "_base_/README.md.eex",
      "_base_/CHANGELOG.md",
      "_elixir_/_base_/shell.nix.eex",
      "_base_/.envrc",
      "_base_/.editorconfig",
      "_elixir_/_nerves_/.formatter.exs",
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
  collection @contributing?, do: ["_elixir_/_base_/CONTRIBUTING.md.eex"]
  collection @license?, do: ["_base_/LICENSE+#{@license}.eex"]
  collection @git?, do: ["_base_/.gitsetup"]

  postgen :generate_ssh_keys
  postgen :init_git
  postgen :prompt_to_build
  postgen :project_created
  postgen :build_instructions
  postgen :gitsetup_instructions

  ##
  ## Pre-generation callbacks.
  ##

  @spec supervision_for_ssh(map()) :: map()
  defp supervision_for_ssh(%{ssh?: true} = opts), do: %{opts | sup?: true}
  defp supervision_for_ssh(opts), do: opts

  @spec generate_ssh_keys(map()) :: map()
  defp generate_ssh_keys(opts) do
    if opts[:push?] || opts[:ssh?] do
      system_dir = "rootfs_overlay/etc/ssh"
      user_dir = "priv/ssh"

      # Generate target host SSH key.
      Prompt.green_info("* generating target host SSH key")
      File.mkdir_p!(system_dir)

      _ =
        :os.cmd(
          'ssh-keygen -q -t rsa -b 4096 -N "" -f #{system_dir}/ssh_host_rsa_key'
        )

      # Generate user SSH key.
      Prompt.green_info("* generating user SSH key")
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

  ##
  ## Post-generation callbacks
  ##

  @spec prompt_to_build(map()) :: map()
  defp prompt_to_build(opts) do
    if Prompt.yes?("\nFetch dependencies?", :yes) do
      run_command("mix", ["deps.get"])
      Map.put(opts, :built?, true)
    else
      Map.put(opts, :built?, false)
    end
  end

  @spec build_instructions(map()) :: map()
  defp build_instructions(opts) do
    unless opts[:built?] do
      Prompt.info("""
      You can now fetch its dependencies:

          cd #{opts.path}
          mix deps.get
      """)
    end

    Prompt.info("""
    You can then build a firmware image:

        cd #{opts.path}
        direnv allow
        MIX_ENV=prod MIX_TARGET=rpi3 mix do deps.get, firmware
    """)

    opts
  end
end
