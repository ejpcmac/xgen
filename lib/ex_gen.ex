defmodule ExGen do
  @moduledoc false

  import Mix.Generator

  @type project_type() :: :std
  @type template_type() :: :text | :eex | :keep
  @type mapping() :: [{template_type(), String.t(), String.t()}]

  @base [
    {:eex, "base/README.md", "README.md"},
    {:text, "base/CHANGELOG.md", "CHANGELOG.md"},
    {:text, "base/.editorconfig", ".editorconfig"},
    {:text, "base/.formatter.exs", ".formatter.exs"},
    {:text, "base/.credo.exs", ".credo.exs"},
    {:text, "base/.dialyzer_ignore", ".dialyzer_ignore"},
    {:text, "base/.gitsetup", ".gitsetup"},
    {:eex, "base/.gitignore", ".gitignore"}
  ]

  @base_contrib [{:eex, "base/CONTRIBUTING.md", "CONTRIBUTING.md"}]
  @base_license_mit [{:eex, "base/LICENSE_MIT", "LICENSE"}]
  @base_todo [{:text, "base/TODO", "TODO"}]

  @std [
    {:eex, "std/mix.exs", "mix.exs"},
    {:text, "std/config/config.exs", "config/config.exs"},
    {:eex, "std/lib/app_name.ex", "lib/:app.ex"},
    {:keep, "std/test/support", "test/support"},
    {:text, "std/test/test_helper.exs", "test/test_helper.exs"},
    {:eex, "std/test/app_name_test.exs", "test/:app_test.exs"}
  ]

  @std_sup [
    {:eex, "std/lib/app_name/application.ex", "lib/:app/application.ex"}
  ]

  templates = [
    @base,
    @base_contrib,
    @base_license_mit,
    @base_todo,
    @std,
    @std_sup
  ]

  templates_root = Path.expand("../templates", __DIR__)

  templates
  |> List.flatten()
  |> Enum.each(fn {type, source, _target} ->
    file = Path.join(templates_root, source)

    case type do
      :text ->
        def render(unquote(source), _assigns), do: unquote(File.read!(file))

      :eex ->
        def render(unquote(source), assigns),
          do: unquote(EEx.compile_file(file))

      :keep ->
        nil
    end
  end)

  @doc false
  @spec generate(project_type(), String.t(), String.t(), keyword()) ::
          :ok | no_return()
  def generate(:std, app, mod, opts) do
    check_application_name!(app, !!opts[:app])
    check_mod_name_validity!(mod)
    check_mod_name_availability!(mod)

    config = fetch_config_file!(opts)

    assigns = [
      app: app,
      mod: mod,
      sup: !!opts[:sup],
      contrib: !!opts[:contrib],
      package: !!opts[:package],
      license: opts[:license],
      maintainer: config[:name],
      github_account: config[:github_account]
    ]

    # Generate base files.
    copy(@base, assigns)
    File.chmod!(".gitsetup", 0o755)
    if opts[:contrib], do: copy(@base_contrib, assigns)
    if opts[:license] == "MIT", do: copy(@base_license_mit, assigns)
    if opts[:todo], do: copy(@base_todo, assigns)

    # Generate standard project.
    copy(@std, assigns)
    if opts[:sup], do: copy(@std_sup, assigns)

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

  @spec copy(mapping(), keyword()) :: :ok
  defp copy(mapping, assigns) do
    Enum.each(mapping, fn {type, source, target} ->
      target = String.replace(target, ":app", assigns[:app])

      case type do
        :keep -> create_directory(target)
        _ -> create_file(target, render(source, assigns))
      end
    end)
  end
end
