defmodule XGen.Templates do
  @moduledoc """
  Helpers for building template collections.
  """

  import XGen.Wizard

  alias __MODULE__.TemplateLister

  @typedoc "A template collection"
  @type collection() :: [String.t()]

  @templates_root Path.expand("../../templates", __DIR__)
  @templates TemplateLister.build_templates_map(@templates_root)

  # Declare each template as @external_resource and define a render/2 function.
  @templates
  |> Enum.each(fn {source, {type, _target}} ->
    file = Path.join(@templates_root, source)

    @external_resource file

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
  defp collection(:contrib), do: ["base/CONTRIBUTING.md.eex"]
  defp collection(:license_mit), do: ["base/LICENSE+MIT.eex"]
  defp collection(:gitsetup), do: ["base/.gitsetup"]
  defp collection(:todo), do: ["base/TODO"]

  # Standard project
  defp collection(:std) do
    [
      "base/README.md.eex",
      "base/CHANGELOG.md",
      "base/shell.nix.eex",
      "base/.envrc",
      "base/.editorconfig",
      "std/.formatter.exs.eex",
      "base/.credo.exs",
      "base/.dialyzer_ignore",
      "base/.gitignore.eex",
      "std/mix.exs.eex",
      "std/config/config.exs",
      "std/lib/@app@.ex.eex",
      "std/test/support/",
      "std/test/test_helper.exs",
      "std/test/@app@_test.exs.eex"
    ]
  end

  # Standard project optionals
  defp collection(:std_sup), do: ["std/lib/@app@/application.ex.eex"]

  defp collection(:std_rel) do
    [
      "std/rel/plugins/.gitignore",
      "std/rel/config.exs.eex"
    ]
  end

  # Nerves project
  defp collection(:nerves) do
    [
      "base/README.md.eex",
      "base/CHANGELOG.md",
      "base/shell.nix.eex",
      "base/.envrc",
      "base/.editorconfig",
      "nerves/.formatter.exs",
      "base/.gitignore.eex",
      "nerves/mix.exs.eex",
      "nerves/config/config.exs.eex",
      "std/lib/@app@.ex.eex",
      "nerves/rel/plugins/.gitignore",
      "nerves/rel/config.exs.eex",
      "nerves/rel/vm.args.eex",
      "nerves/rootfs_overlay/etc/erlinit.config",
      "nerves/rootfs_overlay/etc/iex.exs",
      "nerves/test/test_helper.exs"
    ]
  end

  # Nerves project optionals
  defp collection(:nerves_sup), do: ["nerves/lib/@app@/application.ex.eex"]
  defp collection(:nerves_gen_ssh_keys), do: ["nerves/gen-ssh-keys"]
  defp collection(:nerves_ssh), do: ["nerves/lib/@app@/ssh_server.ex.eex"]

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
  @spec copy(collection(), keyword() | map()) :: :ok
  def copy(collection, assigns) do
    Enum.each(collection, fn template ->
      {type, target} = @templates[template]
      target = String.replace(target, "@app@", assigns[:app])

      case type do
        :keep -> create_directory(target)
        _ -> create_file(target, render(template, assigns))
      end
    end)
  end

  # Helper for generating cookies in templates.
  @spec cookie :: String.t()
  defp cookie, do: 48 |> :crypto.strong_rand_bytes() |> Base.encode64()

  ##
  ## De-Mixed helpers inspired by Mix.Generator
  ##

  @spec create_directory(Path.t()) :: any()
  defp create_directory(path) when is_binary(path) do
    info([:green, "* creating ", :reset, Path.relative_to_cwd(path)])
    File.mkdir_p!(path)
  end

  @spec create_file(Path.t(), iodata()) :: any()
  defp create_file(path, content) when is_binary(path) do
    info([:green, "* creating ", :reset, Path.relative_to_cwd(path)])

    if can_write?(path) do
      File.mkdir_p!(Path.dirname(path))
      File.write!(path, content)
    end
  end

  @spec can_write?(Path.t()) :: boolean()
  defp can_write?(path) do
    if File.exists?(path) do
      path
      |> Path.expand()
      |> Path.relative_to_cwd()
      |> Kernel.<>(" already exists, overwrite?")
      |> yes?(:yes)
    else
      true
    end
  end
end
