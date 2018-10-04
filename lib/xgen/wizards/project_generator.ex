defmodule XGen.Wizards.ProjectGenerator do
  @moduledoc """
  A wizard to generate projects.
  """

  use XGen.Wizard

  alias XGen.Generator
  alias XGen.Generators.Elixir.{Nerves, Std}

  @project_types [Std, Nerves] |> Enum.map(&{&1.type(), &1.name()})

  @impl true
  @spec run :: :ok
  @spec run(keyword()) :: :ok
  def run(opts \\ []) do
    config = opts |> XGen.fetch_config_file!() |> Enum.into(%{})

    case choose("Which kind of project do you want to start?", @project_types) do
      :elixir_std -> Generator.run(Std, config)
      :nerves -> Generator.run(Nerves, config)
    end
  end
end
