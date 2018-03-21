defmodule ExGen.Templates do
  @moduledoc """
  Helpers for building template collections.
  """

  import Mix.Generator

  @typedoc "A template collection"
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
    "std/.formatter.exs" => {:eex, ".formatter.exs"},
    "std/mix.exs" => {:eex, "mix.exs"},
    "std/config/config.exs" => {:text, "config/config.exs"},
    "std/lib/app_name.ex" => {:eex, "lib/:app.ex"},
    "std/lib/app_name/application.ex" => {:eex, "lib/:app/application.ex"},
    "std/rel/plugins/.gitignore" => {:text, "rel/plugins/.gitignore"},
    "std/rel/config.exs" => {:eex, "rel/config.exs"},
    "std/test/support" => {:keep, "test/support"},
    "std/test/test_helper.exs" => {:text, "test/test_helper.exs"},
    "std/test/app_name_test.exs" => {:eex, "test/:app_test.exs"},

    # Nerves
    "nerves/.formatter.exs" => {:text, ".formatter.exs"},
    "nerves/mix.exs" => {:eex, "mix.exs"},
    "nerves/config/config.exs" => {:eex, "config/config.exs"},
    "nerves/lib/app_name/application.ex" => {:eex, "lib/:app/application.ex"},
    "nerves/rel/plugins/.gitignore" => {:text, "rel/plugins/.gitignore"},
    "nerves/rel/config.exs" => {:eex, "rel/config.exs"},
    "nerves/rel/vm.args" => {:eex, "rel/vm.args"},
    "nerves/test/test_helper.exs" => {:text, "test/test_helper.exs"},
    "nerves/.gitignore" => {:eex, ".gitignore"}
  }

  @templates_root Path.expand("../../templates", __DIR__)

  # Generates a render/2 function per template.
  @templates
  |> Enum.each(fn {source, {type, _target}} ->
    file = Path.join(@templates_root, source)

    case type do
      :text ->
        defp render(unquote(source), _assigns), do: unquote(File.read!(file))

      :eex ->
        defp render(unquote(source), assigns),
          do: unquote(EEx.compile_file(file))

      :keep ->
        nil
    end
  end)

  ## Collections

  # Base optionals
  defp collection(:contrib), do: ["base/CONTRIBUTING.md"]
  defp collection(:license_mit), do: ["base/LICENSE_MIT"]
  defp collection(:gitsetup), do: ["base/.gitsetup"]
  defp collection(:todo), do: ["base/TODO"]

  # Standard project
  defp collection(:std) do
    [
      "base/README.md",
      "base/CHANGELOG.md",
      "base/.editorconfig",
      "std/.formatter.exs",
      "base/.credo.exs",
      "base/.dialyzer_ignore",
      "base/.gitignore",
      "std/mix.exs",
      "std/config/config.exs",
      "std/lib/app_name.ex",
      "std/test/support",
      "std/test/test_helper.exs",
      "std/test/app_name_test.exs"
    ]
  end

  # Standard project optionals
  defp collection(:std_sup), do: ["std/lib/app_name/application.ex"]

  defp collection(:std_rel) do
    [
      "std/rel/plugins/.gitignore",
      "std/rel/config.exs"
    ]
  end

  # Nerves project
  defp collection(:nerves) do
    [
      "base/README.md",
      "base/CHANGELOG.md",
      "base/.editorconfig",
      "nerves/.formatter.exs",
      "nerves/.gitignore",
      "nerves/mix.exs",
      "nerves/config/config.exs",
      "std/lib/app_name.ex",
      "nerves/rel/plugins/.gitignore",
      "nerves/rel/config.exs",
      "nerves/rel/vm.args",
      "nerves/test/test_helper.exs"
    ]
  end

  # Nerves project optionals
  defp collection(:nerves_sup), do: ["nerves/lib/app_name/application.ex"]

  @doc """
  Adds a collection `name` to the list of collections conditionally.
  """
  @spec add_collection([atom()], atom(), boolean()) :: [atom()]
  def add_collection(names, name, add?)
  def add_collection(names, c, true), do: [c | names]
  def add_collection(names, _, false), do: names

  @doc """
  Makes a collection from the `names`.
  """
  @spec make_collection([atom()]) :: collection()
  def make_collection(names), do: do_make_collection(names, [])

  @spec do_make_collection([atom()], list()) :: collection()
  defp do_make_collection([], collection), do: List.flatten(collection)

  defp do_make_collection([name | names], collection),
    do: do_make_collection(names, [collection(name) | collection])

  @doc """
  Copies templates from `collection` to the project directory.
  """
  @spec copy(collection(), keyword()) :: :ok
  def copy(collection, assigns) do
    Enum.each(collection, fn template ->
      {type, target} = @templates[template]
      target = String.replace(target, ":app", assigns[:app])

      case type do
        :keep -> create_directory(target)
        _ -> create_file(target, render(template, assigns))
      end
    end)
  end

  # Helper for generating cookies in templates.
  @spec cookie :: String.t()
  defp cookie, do: 48 |> :crypto.strong_rand_bytes() |> Base.encode64()
end
