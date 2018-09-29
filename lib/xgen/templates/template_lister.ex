defmodule XGen.Templates.TemplateLister do
  @moduledoc false

  @typep type() :: :text | :eex | :keep

  @doc false
  @spec build_templates_map(Path.t()) :: map()
  def build_templates_map(templates_root) do
    templates_root
    |> list_templates()
    |> Enum.into(%{}, &parse_path/1)
  end

  @spec list_templates(Path.t()) :: [String.t()]
  @spec list_templates([String.t()], String.t(), Path.t()) :: [String.t()]
  defp list_templates(files \\ [""], current_dir \\ "", templates_root) do
    files
    |> Enum.map(fn file ->
      path = Path.join(current_dir, file)
      full_path = Path.join(templates_root, path)

      if File.dir?(full_path),
        do: full_path |> File.ls!() |> list_templates(path, templates_root),
        else: path
    end)
    |> List.flatten()
  end

  @spec parse_path(String.t()) :: {String.t(), {type(), String.t()}}
  defp parse_path(path) do
    # If the source is a .xgenkeep, it means its directory must be imported as
    # :keep template. The source is then the directory and not the .xgenkeep.
    source = String.trim_trailing(path, ".xgenkeep")

    type =
      case Path.extname(path) do
        ".xgenkeep" -> :keep
        ".eex" -> :eex
        _ -> :text
      end

    # Remove the first directory which represents the generator and special
    # extentions.
    target =
      path
      |> String.replace(~r(^[^/]+/), "")
      |> String.trim_trailing(".eex")
      |> String.trim_trailing(".xgenkeep")
      |> String.replace(~r(\+.*), "")

    {source, {type, target}}
  end
end
