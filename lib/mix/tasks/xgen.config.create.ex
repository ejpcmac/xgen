defmodule Mix.Tasks.Xgen.Config.Create do
  use Mix.Task

  @shortdoc "Generates a configuration file for xgen"

  @moduledoc """
  Generates a configuration file for xgen.
  """

  alias XGen.Wizards.ConfigCreator

  @impl true
  def run(_args) do
    ConfigCreator.run()
  end
end
