defmodule XGen.Generators.Elixir.Callbacks do
  @moduledoc """
  Pre and post generation callbacks for Elixir projects.
  """

  @doc """
  Adds the module path name to the options.
  """
  @spec module_path(map()) :: map()
  def module_path(%{module: module} = opts) do
    name = Macro.underscore(module)
    Map.put(opts, :module_file, name)
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

  ##
  ## Helpers
  ##

  @spec generate_cookie :: String.t()
  defp generate_cookie do
    48 |> :crypto.strong_rand_bytes() |> Base.encode64()
  end
end
