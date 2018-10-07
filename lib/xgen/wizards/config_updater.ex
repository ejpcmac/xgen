defmodule XGen.Wizards.ConfigUpdater do
  @moduledoc """
  A wizard for configuration management.
  """

  defmodule Context do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :file, Path.t(), required: true
      field :config, map(), required: true
      field :first_run, boolean(), default: false
      field :update, boolean(), default: false
      field :write, boolean(), default: false
    end
  end

  use XGen.Wizard

  alias XGen.Option
  alias XGen.Options.Config

  @config_options [
    Config.Name,
    Config.GitHubAccount
  ]

  @impl true
  @spec run :: :ok | no_return()
  @spec run(keyword()) :: :ok | no_return()
  def run(opts \\ []) do
    opts
    |> Keyword.fetch!(:file)
    |> get_current_config()
    |> maybe_convert_to_map()
    |> add_missing_options()
    |> check_config_completeness()
    |> maybe_update_config()
    |> maybe_write_config()
  end

  @spec get_current_config(Path.t()) :: Context.t()
  defp get_current_config(file) do
    if File.regular?(file) do
      %Context{
        file: file,
        config: file |> Code.eval_file() |> elem(0)
      }
    else
      info("""
      No configuration has been found. Please configure xgen by answering the
      questions below. Your answers will be used to automatically put some
      information in your projects templates.
      """)

      %Context{
        file: file,
        config: %{},
        first_run: true
      }
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
  defp add_missing_options(%Context{config: config} = context) do
    empty_config = Enum.into(@config_options, %{}, &{&1.key(), nil})
    %{context | config: Map.merge(empty_config, config)}
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

  defp maybe_update_config(%Context{update: true, config: config} = context) do
    %{context | config: Enum.reduce(@config_options, config, &Option.resolve/2)}
  end

  @spec maybe_write_config(Context.t()) :: :ok | no_return()
  defp maybe_write_config(%Context{write: false}), do: :ok

  defp maybe_write_config(%Context{write: true, file: file, config: config}) do
    case File.write(file, Macro.to_string(quote(do: unquote(config)))) do
      :ok ->
        green_info("""

        Your configuration has been successfully written to #{file}.
        You can edit this file to update your configuration as needed.
        """)

      {:error, reason} ->
        halt("\nAn error has occured while writing to #{file}: #{reason}")
    end
  end
end
