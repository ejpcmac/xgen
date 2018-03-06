defmodule ExGen do
  @moduledoc false

  import ExGen.Templates

  @type project_type() :: :std | :nerves

  @doc false
  @spec generate(project_type(), String.t(), String.t(), keyword()) ::
          :ok | no_return()
  def generate(type, app, mod, opts) do
    check_application_name!(app, !!opts[:app])
    check_mod_name_validity!(mod)
    check_mod_name_availability!(mod)

    config = fetch_config_file!(opts)

    assigns = [
      app: app,
      mod: mod,
      cookie: 48 |> :crypto.strong_rand_bytes() |> Base.encode64(),
      sup: !!opts[:sup],
      net: !!opts[:net],
      contrib: !!opts[:contrib],
      package: !!opts[:package],
      license: opts[:license],
      maintainer: config[:name],
      github_account: config[:github_account]
    ]

    collection =
      []
      |> add_collection(type, true)
      |> add_collection(:std_sup, !!opts[:sup] and type in [:std, :nerves])
      |> add_collection(:contrib, !!opts[:contrib])
      |> add_collection(:license_mit, opts[:license] == "MIT")
      |> add_collection(:todo, !!opts[:todo])
      |> make_collection()

    copy(collection, assigns)
    File.chmod!(".gitsetup", 0o755)

    Mix.shell().info([:green, "* initializing an empty Git repository", :reset])
    System.cmd("git", ["init"])
    if opts[:todo], do: File.write!(".git/info/exclude", "/TODO\n")

    :ok
  end

  @doc false
  @spec build(project_type()) :: boolean()
  def build(:std) do
    msg =
      "\nFetch dependencies and build in dev and test environments in parallel?"

    if Mix.shell().yes?(msg) do
      Mix.shell().info([:green, "* running", :reset, " mix deps.get"])
      System.cmd("mix", ["deps.get"])

      build_task =
        Task.async(fn ->
          Mix.shell().info([:green, "* running", :reset, " mix compile"])
          System.cmd("mix", ["compile"])
          Mix.shell().info([:green, "=> project compilation complete", :reset])
        end)

      test_task =
        Task.async(fn ->
          Mix.shell().info([
            :green,
            "* running",
            :reset,
            " MIX_ENV=test mix compile"
          ])

          System.cmd("mix", ["compile"], env: [{"MIX_ENV", "test"}])
          Mix.shell().info([:green, "=> tests compilation complete", :reset])
        end)

      Task.await(build_task, :infinity)
      Task.await(test_task, :infinity)

      true
    end
  end

  def build(:nerves) do
    msg = "\nFetch dependencies?"

    if Mix.shell().yes?(msg) do
      Mix.shell().info([:green, "* running", :reset, " mix deps.get"])
      System.cmd("mix", ["deps.get"])
      true
    end
  end

  @spec check_application_name!(String.t(), boolean()) :: nil | no_return()
  defp check_application_name!(name, inferred?) do
    unless name =~ Regex.recompile!(~r/^[a-z][a-z0-9_]*$/) do
      Mix.raise(
        "Application name must start with a letter and have only lowercase " <>
          "letters, numbers and underscore, got: #{inspect(name)}" <>
          if inferred? do
            ". The application name is inferred from the path, if you'd " <>
              "like toexplicitly name the application then use the \"--app " <>
              "APP\" option"
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
        "Module name must be a valid Elixir alias (for example: Foo.Bar), " <>
          "got: #{inspect(name)}"
      )
    end
  end

  @spec check_mod_name_availability!(String.t()) :: nil | no_return()
  defp check_mod_name_availability!(name) do
    name = Module.concat(Elixir, name)

    if Code.ensure_loaded?(name) do
      Mix.raise(
        "Module name #{inspect(name)} is already taken, please choose " <>
          "another name"
      )
    end
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
end
