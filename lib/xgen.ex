defmodule XGen do
  @moduledoc """
  Helpers for Elixir projects generation.
  """

  import XGen.Templates

  alias XGen.Project

  @typedoc "Project type"
  @type project_type() :: :std | :nerves

  @doc """
  Generates a project of the given `type` at the given `path`.
  """
  @spec generate(project_type(), String.t(), keyword()) :: :ok | no_return()
  def generate(type, path, opts) do
    type
    |> Project.new(path, opts)
    |> validate_project()
    |> build_assigns()
    |> build_collection()
    |> go_to_project_dir()
    |> copy_files()
    |> generate_ssh_keys()
    |> init_git()
    |> prompt_to_build()
    |> print_end_message()
  end

  @spec validate_project(Project.t()) :: Project.t() | no_return()
  defp validate_project(%Project{} = project) do
    check_application_name!(project.app, !project.opts[:app])
    check_mod_name_validity!(project.mod)
    check_mod_name_availability!(project.mod)
    check_directory_existence!(project.path)

    project
  end

  @spec check_application_name!(String.t(), boolean()) :: nil | no_return()
  defp check_application_name!(name, inferred?) do
    unless name =~ Regex.recompile!(~r/^[a-z][a-z0-9_]*$/) do
      Mix.raise(
        "Application name must start with a letter and have only lowercase " <>
          "letters, numbers and underscore. Got #{inspect(name)}." <>
          if inferred? do
            " The application name is inferred from the path, if you'd " <>
              "like to explicitly name the application then use the `--app " <>
              "<app>` option."
          else
            ""
          end
      )
    end
  end

  @spec check_mod_name_validity!(String.t()) :: nil | no_return()
  defp check_mod_name_validity!(name) do
    unless name =~ Regex.recompile!(~r/^[A-Z]\w*(\.[A-Z]\w*)*$/) do
      Mix.raise(
        "Module name must be a valid Elixir alias (for example: Foo.Bar). " <>
          "Got #{inspect(name)}."
      )
    end
  end

  @spec check_mod_name_availability!(String.t()) :: nil | no_return()
  defp check_mod_name_availability!(name) do
    name = Module.concat(Elixir, name)

    if Code.ensure_loaded?(name) do
      Mix.raise(
        "Module name #{inspect(name)} is already taken, please choose " <>
          "another name."
      )
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

  @spec build_assigns(Project.t()) :: Project.t()
  defp build_assigns(
         %Project{type: type, app: app, mod: mod, opts: opts} = project
       ) do
    config = fetch_config_file!(opts)

    assigns = [
      type: type,
      app: app,
      mod: mod,
      cookie: 48 |> :crypto.strong_rand_bytes() |> Base.encode64(),
      sup: !!opts[:sup] or !!opts[:ssh],
      rel: !!opts[:rel],
      net: !!opts[:net],
      push: !!opts[:push],
      ssh: !!opts[:ssh],
      ntp: !!opts[:ntp],
      rtc: !!opts[:rtc],
      contrib: !!opts[:contrib],
      package: !!opts[:package],
      license: opts[:license],
      maintainer: config[:name],
      github_account: config[:github_account]
    ]

    %{project | assigns: assigns}
  end

  @spec fetch_config_file!(keyword()) :: keyword() | no_return()
  defp fetch_config_file!(opts) do
    file = opts[:config] || System.user_home!() |> Path.join(".xgen.exs")

    unless File.regular?(file) do
      Mix.raise("""
      #{file} does not exist.

      You must provide a configuration file. Either create a global one using
      `mix xgen.config.create` or provide one passing the `--config <file>`
      option to the generator.
      """)
    end

    {config, _} = Code.eval_file(file)

    unless Keyword.keyword?(config) do
      Mix.raise("The config file must contain a keyword list.")
    end

    unless config[:name] |> String.valid?() do
      Mix.raise("""
      The configuration file must contain a `:name` key and it must be a string.
      """)
    end

    unless config[:github_account] |> String.valid?() do
      Mix.raise("""
      The configuration file must contain a `:github_account` key and it must be
      a string.
      """)
    end

    config
  end

  @spec build_collection(Project.t()) :: Project.t()
  defp build_collection(%Project{type: type, opts: opts} = project) do
    collection =
      []
      |> add_collection(type, true)
      |> add_collection(:std_sup, !!opts[:sup] and type in [:std])
      |> add_collection(
        :nerves_sup,
        (!!opts[:sup] or !!opts[:ssh]) and type in [:nerves]
      )
      |> add_collection(:std_rel, !!opts[:rel] and type in [:std])
      |> add_collection(:nerves_gen_ssh_keys, !!opts[:push] or !!opts[:ssh])
      |> add_collection(:nerves_ssh, !!opts[:ssh])
      |> add_collection(:contrib, !!opts[:contrib])
      |> add_collection(:license_mit, opts[:license] == "MIT")
      |> add_collection(:gitsetup, !opts[:no_git])
      |> add_collection(:todo, !!opts[:todo])
      |> make_collection()

    %{project | collection: collection}
  end

  @spec go_to_project_dir(Project.t()) :: Project.t()
  defp go_to_project_dir(%Project{} = project) do
    File.mkdir_p!(project.path)
    File.cd!(project.path)
    project
  end

  @spec copy_files(Project.t()) :: Project.t()
  defp copy_files(%Project{} = project) do
    copy(project.collection, project.assigns)
    unless project.opts[:no_git], do: File.chmod!(".gitsetup", 0o755)
    project
  end

  @spec generate_ssh_keys(Project.t()) :: Project.t()
  defp generate_ssh_keys(%Project{opts: opts} = project) do
    if opts[:push] || opts[:ssh] do
      system_dir = "rootfs_overlay/etc/ssh"
      user_dir = "priv/ssh"

      # Generate target host SSH key.
      Mix.shell().info([:green, "* generating target host SSH key", :reset])
      File.mkdir_p!(system_dir)

      _ =
        :os.cmd(
          'ssh-keygen -q -t rsa -b 4096 -N "" -f #{system_dir}/ssh_host_rsa_key'
        )

      # Generate user SSH key.
      Mix.shell().info([:green, "* generating user SSH key", :reset])
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

    project
  end

  @spec init_git(Project.t()) :: Project.t()
  defp init_git(%Project{opts: opts} = project) do
    unless opts[:no_git] do
      Mix.shell().info([
        :green,
        "* initializing an empty Git repository",
        :reset
      ])

      _ = System.cmd("git", ["init"])
      if opts[:todo], do: File.write!(".git/info/exclude", "/TODO\n")
    end

    project
  end

  @spec prompt_to_build(Project.t()) :: Project.t()
  defp prompt_to_build(%Project{type: :std} = project) do
    msg =
      "\nFetch dependencies and build in dev and test environments in parallel?"

    if Mix.shell().yes?(msg) do
      run_command("mix", ["deps.get"])

      build_task =
        Task.async(fn ->
          run_command("mix", ["compile"])
          Mix.shell().info([:green, "=> project compilation complete", :reset])
        end)

      test_task =
        Task.async(fn ->
          run_command("mix", ["compile"], env: [{"MIX_ENV", "test"}])
          Mix.shell().info([:green, "=> tests compilation complete", :reset])
        end)

      Task.await(build_task, :infinity)
      Task.await(test_task, :infinity)
      %{project | build: true}
    else
      %{project | build: false}
    end
  end

  defp prompt_to_build(%Project{type: :nerves} = project) do
    if Mix.shell().yes?("\nFetch dependencies?") do
      run_command("mix", ["deps.get"])
      %{project | build: true}
    else
      %{project | build: false}
    end
  end

  @spec print_end_message(Project.t()) :: :ok
  defp print_end_message(%Project{} = project) do
    []
    |> project_created()
    |> build_instructions(project)
    |> special_instructions(project)
    |> gitsetup_instructions(!project.opts[:no_git])
    |> Enum.reverse()
    |> Mix.shell().info()
  end

  @spec project_created(iolist()) :: iolist()
  defp project_created(messages) do
    [
      """

      Your project has been successfully created.
      """
      | messages
    ]
  end

  @spec build_instructions(iolist(), Project.t()) :: iolist()
  defp build_instructions(messages, %Project{
         type: :std,
         path: path,
         build: false
       }) do
    [
      """

      You can now fetch its dependencies and compile it:

          cd #{path}
          mix deps.get
          mix compile

      You can also run tests:

          mix test
      """
      | messages
    ]
  end

  defp build_instructions(messages, %Project{
         type: :nerves,
         path: path,
         build: false
       }) do
    [
      """

      You can now fetch its dependencies:

          cd #{path}
          mix deps.get
      """
      | messages
    ]
  end

  defp build_instructions(messages, _), do: messages

  @spec special_instructions(iolist(), Project.t()) :: iolist()
  defp special_instructions(messages, %Project{type: :nerves, path: path}) do
    [
      """

      You can then build a firmware image:

          cd #{path}
          direnv allow
          MIX_ENV=prod MIX_TARGET=rpi3 mix do deps.get, firmware
      """
      | messages
    ]
  end

  defp special_instructions(messages, _), do: messages

  @spec gitsetup_instructions(iolist(), boolean()) :: iolist()
  defp gitsetup_instructions(messages, true) do
    [
      """

      After your first commit, you can setup gitflow:

          ./.gitsetup
      """
      | messages
    ]
  end

  defp gitsetup_instructions(messages, false), do: messages

  ## Helpers

  @spec run_command(binary(), [binary()], keyword()) :: :ok
  defp run_command(cmd, args, opts \\ []) do
    env = Enum.map(opts[:env] || [], fn {key, value} -> " #{key}=#{value}" end)
    fmt_args = Enum.join(args, " ")

    Mix.shell().info(
      [:green, "* running", :reset] ++ env ++ [" #{cmd} ", fmt_args]
    )

    _ = System.cmd(cmd, args, opts)
    :ok
  end
end
