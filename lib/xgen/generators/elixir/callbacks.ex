defmodule XGen.Generators.Elixir.Callbacks do
  @moduledoc """
  Pre and post generation callbacks for Elixir projects.
  """

  import XGen.Generator.CallbackHelpers

  @doc """
  Adds the module path name to the options.
  """
  @spec module_path(map()) :: map()
  def module_path(%{module: module} = opts) do
    name = Macro.underscore(module)
    Map.put(opts, :module_path, name)
  end

  @doc """
  Adds a cookie to the options.
  """
  @spec cookie(map()) :: map()
  def cookie(opts) do
    Map.put(opts, :cookie, generate_cookie())
  end

  @doc """
  Adds a cookie generator to the options.
  """
  @spec cookie_generator(map()) :: map()
  def cookie_generator(opts) do
    Map.put(opts, :cookie_generator, &generate_cookie/0)
  end

  @doc """
  Fetches the dependencies.
  """
  @spec fetch_deps(map()) :: map()
  def fetch_deps(opts) do
    run_command("mix", ["deps.get"])
    opts
  end

  @doc """
  Runs the the code formatter.
  """
  @spec run_formatter(map()) :: map()
  def run_formatter(opts) do
    run_command("mix", ["format"])
    opts
  end

  ##
  ## Helpers
  ##

  @spec generate_cookie :: String.t()
  defp generate_cookie do
    48 |> :crypto.strong_rand_bytes() |> Base.encode64()
  end
end
