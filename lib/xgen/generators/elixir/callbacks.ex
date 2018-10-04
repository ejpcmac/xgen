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
    cookie = 48 |> :crypto.strong_rand_bytes() |> Base.encode64()
    Map.put(opts, :cookie, cookie)
  end
end
