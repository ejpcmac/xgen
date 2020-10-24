defmodule XGen.Generators.Elixir.Helpers do
  @moduledoc """
  Helpers and callbacks for Elixir projects.
  """

  import XGen.Generator.CallbackHelpers

  @doc """
  Returns the current Elixir version.
  """
  @spec elixir_version :: String.t()
  def elixir_version do
    System.version()
  end

  @doc """
  Returns the current Elixir version requirement.
  """
  @spec elixir_requirement :: String.t()
  def elixir_requirement do
    version = elixir_version() |> Version.parse!()
    "~> #{version.major}.#{version.minor}"
  end

  @doc """
  Generates an Erlang cookie.
  """
  @spec generate_cookie :: String.t()
  def generate_cookie do
    48 |> :crypto.strong_rand_bytes() |> Base.encode64()
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
end
