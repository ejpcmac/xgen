defmodule XGen.Templates do
  @moduledoc """
  Helpers for building template collections.
  """

  import XGen.Wizard

  alias __MODULE__.TemplateLister

  @typedoc "A collection of templates"
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

  @doc """
  Copies templates from `collection` to the project directory.
  """
  @spec copy(collection(), keyword() | map()) :: :ok
  def copy(collection, assigns) do
    Enum.each(collection, fn template ->
      {type, target} = @templates[template]

      target =
        ~r/@(\w*)@/u
        |> Regex.scan(target, capture: :all_but_first)
        |> List.flatten()
        |> Enum.dedup()
        |> Enum.reduce(target, fn assign, path ->
          key = String.to_existing_atom(assign)
          String.replace(path, "@#{assign}@", assigns[key])
        end)

      case type do
        :keep -> create_directory(target)
        _ -> create_file(target, render(template, assigns))
      end
    end)
  end

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
