defmodule ExGen do
  @moduledoc false

  import Mix.Generator

  @type project_type() :: :std | :nerves
  @type template_type() :: :text | :eex | :keep
  @type collection() :: [String.t()]

  @templates %{
    # Base
    "base/README.md" => {:eex, "README.md"},
    "base/CHANGELOG.md" => {:text, "CHANGELOG.md"},
    "base/CONTRIBUTING.md" => {:eex, "CONTRIBUTING.md"},
    "base/LICENSE_MIT" => {:eex, "LICENSE"},
    "base/.editorconfig" => {:text, ".editorconfig"},
    "base/.credo.exs" => {:text, ".credo.exs"},
    "base/.dialyzer_ignore" => {:text, ".dialyzer_ignore"},
    "base/.gitsetup" => {:text, ".gitsetup"},
    "base/.gitignore" => {:eex, ".gitignore"},
    "base/TODO" => {:text, "TODO"},

    # Standard
    "std/.formatter.exs" => {:text, ".formatter.exs"},
    "std/mix.exs" => {:eex, "mix.exs"},
    "std/config/config.exs" => {:text, "config/config.exs"},
    "std/lib/app_name.ex" => {:eex, "lib/:app.ex"},
    "std/lib/app_name/application.ex" => {:eex, "lib/:app/application.ex"},
    "std/test/support" => {:keep, "test/support"},
    "std/test/test_helper.exs" => {:text, "test/test_helper.exs"},
    "std/test/app_name_test.exs" => {:eex, "test/:app_test.exs"},

    # Nerves
    "nerves/.formatter.exs" => {:text, ".formatter.exs"},
    "nerves/mix.exs" => {:eex, "mix.exs"},
    "nerves/config/config.exs" => {:eex, "config/config.exs"},
    "nerves/rel/plugins/.gitignore" => {:text, "rel/plugins/.gitignore"},
    "nerves/rel/config.exs" => {:eex, "rel/config.exs"},
    "nerves/rel/vm.args" => {:eex, "rel/vm.args"},
    "nerves/test/test_helper.exs" => {:text, "test/test_helper.exs"}
  }

  @templates_root Path.expand("../templates", __DIR__)

  # Generates a render/2 function per template.
  @templates
  |> Enum.each(fn {source, {type, _target}} ->
    file = Path.join(@templates_root, source)

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

  ## Collections

  defp collection(:contrib), do: ["base/CONTRIBUTING.md"]
  defp collection(:license_mit), do: ["base/LICENSE_MIT"]
  defp collection(:todo), do: ["base/TODO"]

  defp collection(:std) do
    [
      "base/README.md",
      "base/CHANGELOG.md",
      "base/.editorconfig",
      "std/.formatter.exs",
      "base/.credo.exs",
      "base/.dialyzer_ignore",
      "base/.gitsetup",
      "base/.gitignore",
      "std/mix.exs",
      "std/config/config.exs",
      "std/lib/app_name.ex",
      "std/test/support",
      "std/test/test_helper.exs",
      "std/test/app_name_test.exs"
    ]
  end

  defp collection(:std_sup), do: ["std/lib/app_name/application.ex"]

  defp collection(:nerves) do
    [
      "base/README.md",
      "base/CHANGELOG.md",
      "base/.editorconfig",
      "nerves/.formatter.exs",
      "base/.gitsetup",
      "base/.gitignore",
      "nerves/mix.exs",
      "nerves/config/config.exs",
      "std/lib/app_name.ex",
      "nerves/rel/plugins/.gitignore",
      "nerves/rel/config.exs",
      "nerves/rel/vm.args",
      "nerves/test/test_helper.exs"
    ]
  end

  ## Generator

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

  defp add_collection(names, c, true), do: [c | names]
  defp add_collection(names, _, false), do: names

  defp make_collection(names), do: do_make_collection(names, [])

  defp do_make_collection([], collection), do: List.flatten(collection)

  defp do_make_collection([name | names], collection),
    do: do_make_collection(names, [collection(name) | collection])

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

  @spec copy(collection(), keyword()) :: :ok
  defp copy(templates, assigns) do
    Enum.each(templates, fn template ->
      {type, target} = @templates[template]
      target = String.replace(target, ":app", assigns[:app])

      case type do
        :keep -> create_directory(target)
        _ -> create_file(target, render(template, assigns))
      end
    end)
  end
end
