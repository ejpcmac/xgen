defmodule XGen.Configuration do
  @moduledoc """
  xgen configuration management.
  """

  import XGen.Prompt

  alias XGen.Option

  defmodule Context do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :file, Path.t(), required: true
      field :options, [Option.t()], required: true
      field :config, map() | term(), default: %{}
      field :first_run, boolean(), default: false
      field :update, boolean(), default: false
      field :write, boolean(), default: false
    end
  end

  @doc """
  Resolves the configuration.

  The configuration is resolved by reading the current configuration from the
  configuration file, merging it with the expected options and optionnally
  prompting the user for an update. If any modification is done to the
  configuration it is saved on the disk.
  """
  @spec resolve(Path.t(), [Option.t()]) :: map() | no_return()
  def resolve(file, options) do
    %Context{file: file, options: options}
    |> get_current_config()
    |> maybe_convert_to_map()
    |> add_missing_options()
    |> check_config_completeness()
    |> maybe_update_config()
    |> maybe_write_config()
  end

  @spec get_current_config(Context.t()) :: Context.t()
  defp get_current_config(%{file: file} = context) do
    if File.regular?(file) do
      %{context | config: file |> Code.eval_file() |> elem(0)}
    else
      info("""
      No configuration has been found. Please configure xgen by answering the
      questions below. Your answers will be used to automatically put some
      information in your projects templates.
      """)

      %{context | first_run: true}
    end
  end

  @spec maybe_convert_to_map(Context.t()) :: Context.t()
  defp maybe_convert_to_map(%Context{config: config} = context)
       when is_map(config),
       do: context

  defp maybe_convert_to_map(%Context{config: config} = context) do
    unless Keyword.keyword?(config) do
      halt("The config file must contain a map or a keyword list.")
    end

    info("Updating the configuration to the new format.\n")

    %{context | config: Enum.into(config, %{}), write: true}
  end

  @spec add_missing_options(Context.t()) :: Context.t()
  defp add_missing_options(
         %Context{
           config: config,
           options: options
         } = context
       ) do
    %{
      context
      | config: options |> Enum.into(%{}, &{&1.key(), nil}) |> Map.merge(config)
    }
  end

  @spec check_config_completeness(Context.t()) :: Context.t()
  defp check_config_completeness(%Context{first_run: true} = context) do
    %{context | update: true, write: true}
  end

  defp check_config_completeness(%Context{first_run: false} = context) do
    if Enum.any?(context.config, &is_nil(&1 |> elem(1))) do
      info("""
      A previous configuration has been found, but it lacks some options. Please
      update your configuration by answering the questions below.
      """)

      %{context | update: true, write: true}
    else
      context
    end
  end

  @spec maybe_update_config(Context.t()) :: Context.t()
  defp maybe_update_config(%Context{update: false} = context), do: context

  defp maybe_update_config(
         %Context{update: true, config: config, options: options} = context
       ) do
    %{context | config: Enum.reduce(options, config, &Option.resolve/2)}
  end

  @spec maybe_write_config(Context.t()) :: map() | no_return()
  defp maybe_write_config(%Context{write: false, config: config}), do: config

  defp maybe_write_config(%Context{write: true, file: file, config: config}) do
    case File.write(file, Macro.to_string(quote(do: unquote(config)))) do
      :ok ->
        green_info("""

        Your configuration has been successfully written to #{file}.
        You can edit this file to update your configuration as needed.
        """)

        config

      {:error, reason} ->
        halt("\nAn error has occured while writing to #{file}: #{reason}")
    end
  end
end
