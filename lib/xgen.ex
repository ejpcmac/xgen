defmodule XGen do
  @moduledoc """
  Helpers for Elixir projects generation.
  """

  import XGen.Wizard

  @spec fetch_config_file!(keyword()) :: keyword() | no_return()
  def fetch_config_file!(opts) do
    file = opts[:config] || System.user_home!() |> Path.join(".xgen.exs")

    unless File.regular?(file) do
      halt("""
      #{file} does not exist.

      You must provide a configuration file. Either create a global one using
      `mix xgen.config.create` or provide one passing the `--config <file>`
      option to the generator.
      """)
    end

    {config, _} = Code.eval_file(file)

    unless Keyword.keyword?(config) do
      halt("The config file must contain a keyword list.")
    end

    unless config[:name] |> String.valid?() do
      halt("""
      The configuration file must contain a `:name` key and it must be a string.
      """)
    end

    unless config[:github_account] |> String.valid?() do
      halt("""
      The configuration file must contain a `:github_account` key and it must be
      a string.
      """)
    end

    config
  end
end
