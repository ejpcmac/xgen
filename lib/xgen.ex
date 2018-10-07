defmodule XGen do
  @moduledoc """
  Helpers for Elixir projects generation.
  """

  import XGen.Wizard

  @spec fetch_config_file!(keyword()) :: map() | no_return()
  def fetch_config_file!(opts) do
    file = opts[:config] || System.user_home!() |> Path.join(".xgen.exs")

    {config, _} = Code.eval_file(file)

    unless is_map(config) do
      halt("The config file must contain a map.")
    end

    config
  end
end
